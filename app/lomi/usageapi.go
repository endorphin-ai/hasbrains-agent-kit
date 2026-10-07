package main

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
)

// Per-model weekly limits (such as "Fable this week") are not in the status
// line data. The only source is the endpoint behind Claude Code's /usage
// command, which needs the Claude login token. This file is used only when
// the user turns the option on in Settings. The token is read for one
// request, kept in memory only, and sent to api.anthropic.com and nowhere else.

const (
	usageEndpoint   = "https://api.anthropic.com/api/oauth/usage"
	keychainService = "Claude Code-credentials"
	usagePollEvery  = 2 * time.Minute
	usagePollMax    = 15 * time.Minute
)

type usageState struct {
	sync.Mutex
	limits   []Limit
	at       int64 // when limits were fetched
	err      string
	nextTry  time.Time
	interval time.Duration
	fetching bool
}

var accountUsage = usageState{interval: usagePollEvery}

// loadToken reads the login Claude Code saved: the macOS Keychain first,
// then <claudeDir>/.credentials.json.
func loadToken(cfg Config) (string, error) {
	var sources [][]byte
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	// `security` is the tool Claude Code itself uses for this item.
	if out, err := exec.CommandContext(ctx, "/usr/bin/security", "find-generic-password", "-s", keychainService, "-w").Output(); err == nil {
		sources = append(sources, out)
	}
	if b, err := os.ReadFile(filepath.Join(cfg.claudeDir(), ".credentials.json")); err == nil {
		sources = append(sources, b)
	}
	for _, raw := range sources {
		if token := parseToken(raw); token != "" {
			return token, nil
		}
	}
	return "", errors.New("no Claude Code login found; run `claude` and log in once")
}

func parseToken(raw []byte) string {
	text := strings.TrimSpace(string(raw))
	// `security -w` prints hex when the stored value is not plain text.
	if !strings.HasPrefix(text, "{") {
		if decoded, err := hex.DecodeString(text); err == nil {
			text = string(decoded)
		}
	}
	var creds struct {
		OAuth struct {
			AccessToken string `json:"accessToken"`
		} `json:"claudeAiOauth"`
	}
	if json.Unmarshal([]byte(text), &creds) != nil {
		return ""
	}
	return creds.OAuth.AccessToken
}

type usageWindow struct {
	Utilization *float64 `json:"utilization"`
	ResetsAt    string   `json:"resets_at"`
}

// parseUsage turns the endpoint's response into limits: the session and the
// week, then one row per model that has its own weekly limit.
func parseUsage(body []byte) ([]Limit, error) {
	var raw struct {
		FiveHour *usageWindow      `json:"five_hour"`
		SevenDay *usageWindow      `json:"seven_day"`
		Limits   []json.RawMessage `json:"limits"`
	}
	if json.Unmarshal(body, &raw) != nil {
		return nil, errors.New("the usage response was not understood; the endpoint may have changed")
	}
	limits := []Limit{}
	add := func(key string, w *usageWindow) {
		if w == nil || w.Utilization == nil {
			return
		}
		label, note := limitLabel(key)
		limits = append(limits, Limit{Key: key, Label: label, Note: note, UsedPct: clampPct(*w.Utilization), ResetsAt: parseTS(w.ResetsAt)})
	}
	add("five_hour", raw.FiveHour)
	add("seven_day", raw.SevenDay)
	for _, item := range raw.Limits {
		var l struct {
			Kind     string   `json:"kind"`
			Percent  *float64 `json:"percent"`
			ResetsAt string   `json:"resets_at"`
			Scope    struct {
				Model struct {
					DisplayName string `json:"display_name"`
				} `json:"model"`
			} `json:"scope"`
		}
		// One bad element must not hide the others.
		if json.Unmarshal(item, &l) != nil || l.Kind != "weekly_scoped" || l.Percent == nil || l.Scope.Model.DisplayName == "" {
			continue
		}
		name := l.Scope.Model.DisplayName
		limits = append(limits, Limit{
			Key:      "weekly_scoped_" + strings.ToLower(strings.ReplaceAll(name, " ", "_")),
			Label:    name + " this week",
			Note:     "Separate weekly limit for " + name,
			UsedPct:  clampPct(*l.Percent),
			ResetsAt: parseTS(l.ResetsAt),
		})
	}
	if len(limits) == 0 {
		return nil, errors.New("the usage response had no limits; the endpoint may have changed")
	}
	return limits, nil
}

func clampPct(v float64) float64 {
	return max(0, min(100, v))
}

// fetchUsage calls the endpoint once. retryAfter is set when it asks to slow down.
func fetchUsage(endpoint, token string) (limits []Limit, retryAfter time.Duration, err error) {
	req, err := http.NewRequest(http.MethodGet, endpoint, nil)
	if err != nil {
		return nil, 0, err
	}
	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("anthropic-beta", "oauth-2025-04-20")
	req.Header.Set("User-Agent", "lomi")
	client := http.Client{Timeout: 20 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, 0, errors.New("cannot reach api.anthropic.com")
	}
	defer resp.Body.Close()
	switch resp.StatusCode {
	case http.StatusOK:
		var body json.RawMessage
		if json.NewDecoder(resp.Body).Decode(&body) != nil {
			return nil, 0, errors.New("the usage response was not understood")
		}
		limits, err = parseUsage(body)
		return limits, 0, err
	case http.StatusUnauthorized, http.StatusForbidden:
		return nil, 0, errors.New("the Claude Code login expired; send a message in Claude Code to refresh it")
	case http.StatusTooManyRequests:
		secs, _ := strconv.Atoi(resp.Header.Get("Retry-After"))
		return nil, time.Duration(secs) * time.Second, errors.New("Anthropic asked to slow down; trying again later")
	}
	return nil, 0, fmt.Errorf("Anthropic returned HTTP %d", resp.StatusCode)
}

// accountLimits returns the last fetched limits and starts a new fetch in the
// background when one is due. It never blocks a snapshot on the network.
func accountLimits(cfg Config) (limits []Limit, at int64, errText string) {
	u := &accountUsage
	u.Lock()
	defer u.Unlock()
	if !u.fetching && time.Now().After(u.nextTry) {
		u.fetching = true
		go func() {
			var fresh []Limit
			var retry time.Duration
			token, err := loadToken(cfg)
			if err == nil {
				fresh, retry, err = fetchUsage(usageEndpoint, token)
			}
			u.Lock()
			defer u.Unlock()
			u.fetching = false
			if err != nil {
				// Back off after a failure, up to the maximum.
				u.err = err.Error()
				u.interval = min(max(u.interval*2, retry), usagePollMax)
			} else {
				u.limits, u.at, u.err, u.interval = fresh, time.Now().Unix(), "", usagePollEvery
			}
			u.nextTry = time.Now().Add(u.interval)
		}()
	}
	return u.limits, u.at, u.err
}

// mergeLimits adds the windows of extra that base does not have. The status
// line values stay, because they are newer than a two-minute poll.
func mergeLimits(base, extra []Limit) []Limit {
	have := map[string]bool{}
	for _, l := range base {
		have[l.Key] = true
	}
	for _, l := range extra {
		if !have[l.Key] {
			base = append(base, l)
		}
	}
	return base
}

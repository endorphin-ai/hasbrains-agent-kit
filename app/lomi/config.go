package main

import (
	"encoding/json"
	"math"
	"os"
	"path/filepath"
	"strings"
)

// Panels toggles which sections the window shows.
type Panels struct {
	Sessions bool `json:"sessions"`
	Limits   bool `json:"limits"`
	Run      bool `json:"run"`
	Agents   bool `json:"agents"`
}

// GitOptions chooses the git details shown for each session.
type GitOptions struct {
	Show     bool `json:"show"`
	Repo     bool `json:"repo"`
	Branch   bool `json:"branch"`
	Worktree bool `json:"worktree"`
}

// Config is the user-editable configuration, stored as JSON in the OS config dir.
type Config struct {
	ClaudeDir      string `json:"claudeDir"`      // "" means ~/.claude
	RefreshSeconds int    `json:"refreshSeconds"` // how often the window re-reads the data
	MaxAgents      int    `json:"maxAgents"`      // subagent rows to show
	WarnAt         int    `json:"warnAt"`         // used % above which a bar turns yellow
	DangerAt       int    `json:"dangerAt"`       // used % above which a bar turns red
	ContextWindow  int    `json:"contextWindow"`  // tokens; only used when the bridge is off
	BarStyle       string `json:"barStyle"`       // "ascii" or "smooth"
	LimitAlertAt   int    `json:"limitAlertAt"`   // used % at which a rate limit is flagged
	AlwaysOnTop    bool   `json:"alwaysOnTop"`
	Compact        bool   `json:"compact"` // sessions and limits only, in one tight block
	Mascot         bool   `json:"mascot"`  // the ring gauge with the character
	Motion         bool   `json:"motion"`  // animations
	// ModelLimits shows the per-model weekly limits, such as "Fable this
	// week". It is off unless the user turns it on.
	ModelLimits bool       `json:"modelLimits"`
	Panels      Panels     `json:"panels"`
	Git         GitOptions `json:"git"`
	// Prices turn token counts into cost. The first matching row is used.
	Prices        []ModelPrice `json:"prices"`
	PricesVersion int          `json:"pricesVersion"`
}

func defaultConfig() Config {
	return Config{
		RefreshSeconds: 2,
		MaxAgents:      8,
		WarnAt:         50,
		DangerAt:       75,
		ContextWindow:  1000000,
		BarStyle:       "ascii",
		LimitAlertAt:   90,
		Mascot:         true,
		Motion:         true,
		Panels:         Panels{Sessions: true, Limits: true, Run: true, Agents: true},
		Git:            GitOptions{Show: true, Repo: true, Branch: true, Worktree: true},
		Prices:         defaultPrices(),
		PricesVersion:  pricesVersion,
	}
}

func clamp(v, lo, hi int) int {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

// normalize keeps a hand-edited or outdated config file from breaking the app.
func (c Config) normalize() Config {
	d := defaultConfig()
	c.ClaudeDir = strings.TrimSpace(c.ClaudeDir)
	c.RefreshSeconds = clamp(c.RefreshSeconds, 1, 60)
	c.MaxAgents = clamp(c.MaxAgents, 1, 50)
	c.WarnAt = clamp(c.WarnAt, 1, 99)
	c.DangerAt = clamp(c.DangerAt, c.WarnAt, 100)
	c.LimitAlertAt = clamp(c.LimitAlertAt, 1, 100)
	if c.ContextWindow < 1000 {
		c.ContextWindow = d.ContextWindow
	}
	if c.BarStyle != "smooth" {
		c.BarStyle = "ascii"
	}
	prices := []ModelPrice{}
	for _, p := range c.Prices {
		p.Match = strings.TrimSpace(p.Match)
		if p.Match == "" {
			continue
		}
		p.In, p.Out = math.Max(0, p.In), math.Max(0, p.Out)
		p.CacheWrite, p.CacheRead = math.Max(0, p.CacheWrite), math.Max(0, p.CacheRead)
		prices = append(prices, p)
	}
	c.Prices, c.PricesVersion = prices, pricesVersion
	return c
}

func configPath() (string, error) {
	dir, err := os.UserConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "lomi", "config.json"), nil
}

func loadConfig() Config {
	c := defaultConfig()
	p, err := configPath()
	if err != nil {
		return c
	}
	b, err := os.ReadFile(p)
	if err != nil {
		// Settings saved when the app was called StatusDeck are carried over.
		legacy := filepath.Join(filepath.Dir(filepath.Dir(p)), "statusdeck", "config.json")
		if b, err = os.ReadFile(legacy); err != nil {
			return c
		}
	}
	// Unmarshal over the defaults so fields missing from an older file keep them.
	c.PricesVersion = 0
	if json.Unmarshal(b, &c) != nil {
		return defaultConfig()
	}
	if c.PricesVersion < pricesVersion {
		c.Prices, c.PricesVersion = defaultPrices(), pricesVersion
	}
	return c.normalize()
}

func saveConfig(c Config) error {
	p, err := configPath()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
		return err
	}
	b, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(p, b, 0o644)
}

func expandHome(p string) string {
	home, err := os.UserHomeDir()
	if err != nil {
		return p
	}
	switch {
	case p == "~" || p == "$HOME":
		return home
	case strings.HasPrefix(p, "~/"):
		return filepath.Join(home, p[2:])
	case strings.HasPrefix(p, "$HOME/"):
		return filepath.Join(home, p[6:])
	}
	return p
}

// claudeDir resolves the configured Claude Code directory.
func (c Config) claudeDir() string {
	if c.ClaudeDir != "" {
		return expandHome(c.ClaudeDir)
	}
	return expandHome("~/.claude")
}

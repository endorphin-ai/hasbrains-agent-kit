package main

import (
	"encoding/hex"
	"encoding/json"
	"math"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"
)

func TestContextPct(t *testing.T) {
	cases := []struct {
		name, in string
		want     int // -1 means unknown
	}{
		{"used", `{"context_window":{"used_percentage":42.7}}`, 42},
		{"remaining", `{"context_window":{"remaining_percentage":80}}`, 20},
		{"usage", `{"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":10000,"cache_read_input_tokens":40000}}}`, 25},
		{"none", `{"context_window":{"current_usage":null}}`, -1},
	}
	for _, c := range cases {
		var in statusInput
		if err := json.Unmarshal([]byte(c.in), &in); err != nil {
			t.Fatalf("%s: %v", c.name, err)
		}
		got := in.contextPct()
		if c.want < 0 {
			if got != nil {
				t.Errorf("%s: want unknown, got %d", c.name, *got)
			}
		} else if got == nil || *got != c.want {
			t.Errorf("%s: want %d, got %v", c.name, c.want, got)
		}
	}
}

func TestParseLimits(t *testing.T) {
	var in statusInput
	src := `{"rate_limits":{
		"seven_day_fable":{"used_percentage":59,"resets_at":"2026-10-11T17:00:00Z"},
		"seven_day":{"used_percentage":51,"resets_at":1791738000},
		"five_hour":{"used_percentage":5.4,"resets_at":1791336600},
		"broken":{"resets_at":1}}}`
	if err := json.Unmarshal([]byte(src), &in); err != nil {
		t.Fatal(err)
	}
	got := parseLimits(in.RateLimits)
	if len(got) != 3 {
		t.Fatalf("want 3 limits, got %d", len(got))
	}
	want := []string{"Current session", "This week", "Fable this week"}
	for i, l := range got {
		if l.Label != want[i] {
			t.Errorf("limit %d: want %q, got %q", i, want[i], l.Label)
		}
		if l.ResetsAt == 0 {
			t.Errorf("limit %d: resets_at not parsed", i)
		}
	}
	if got[2].Note != "Separate weekly limit for Fable" {
		t.Errorf("note: got %q", got[2].Note)
	}
}

func TestTranscriptDedupesAndPrices(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "agent-explore-a0213cdcd294b466a.jsonl")
	line := func(id string, out int, stop string) string {
		return `{"type":"assistant","isSidechain":true,"cwd":"/tmp/proj","timestamp":"2026-10-06T10:00:30.000Z","message":{"id":"` + id +
			`","model":"claude-opus-5-5","stop_reason":` + stop + `,"usage":{"input_tokens":1000,"output_tokens":` + strconv.Itoa(out) +
			`,"cache_creation_input_tokens":2000,"cache_read_input_tokens":7000},"content":[{"type":"tool_use","id":"t-` + id + `"}]}}`
	}
	first := `{"type":"user","timestamp":"2026-10-06T10:00:00.000Z"}` + "\n" +
		line("m1", 10, "null") + "\n" + line("m1", 100, `"tool_use"`) + "\n"
	if err := os.WriteFile(path, []byte(first), 0o644); err != nil {
		t.Fatal(err)
	}
	tr := readTranscript(path, false)
	if got := tr.byModel()["claude-opus-5-5"]; got.Out != 100 || got.In != 1000 {
		t.Fatalf("streaming snapshots of one message must count once, got %+v", got)
	}

	// Appended lines are read without counting the old ones again. A line
	// that has no newline yet is left for the next read.
	fh, _ := os.OpenFile(path, os.O_APPEND|os.O_WRONLY, 0o644)
	fh.WriteString(line("m2", 50, `"end_turn"`) + "\n" + `{"type":"assist`)
	fh.Close()
	tr = readTranscript(path, false)
	use := tr.byModel()["claude-opus-5-5"]
	if use.Out != 150 || use.CacheRead != 14000 || len(tr.tools) != 2 || tr.lastStop != "end_turn" {
		t.Fatalf("after append: %+v tools=%d stop=%q", use, len(tr.tools), tr.lastStop)
	}
	if tr.lastTS-tr.firstTS != 30 || tr.lastCtx != 10000 {
		t.Errorf("duration %d, context %d", tr.lastTS-tr.firstTS, tr.lastCtx)
	}

	cfg := defaultConfig()
	// claude-opus-5-5: 2000 in x $4 + 150 out x $20 + 4000 write x $5 + 14000 read x $0.2, per million.
	want := (2000*4 + 150*20 + 4000*5 + 14000*0.2) / 1e6
	if got, priced := cfg.cost(tr.byModel()); !priced || math.Abs(got-want) > 1e-9 {
		t.Errorf("cost: want %v, got %v (priced %v)", want, got, priced)
	}
	cfg.Prices = []ModelPrice{{Match: "sonnet", In: 3}}
	if _, priced := cfg.cost(tr.byModel()); priced {
		t.Errorf("a model without a price row must not be priced")
	}
	if p, _ := defaultConfig().priceFor("claude-fable-5-1"); p.In != 10 || p.CacheRead != 0.25 {
		t.Errorf("fable-5-1 price row: %+v", p)
	}
	if p, _ := defaultConfig().priceFor("claude-opus-4-8"); p.In != 5 {
		t.Errorf("older opus must use the family row: %+v", p)
	}
	if got := agentName(path); got != "explore" {
		t.Errorf("agent name from file name: got %q", got)
	}
	os.WriteFile(strings.TrimSuffix(path, ".jsonl")+".meta.json", []byte(`{"agentType":"Explore"}`), 0o644)
	if got := agentName(path); got != "Explore" {
		t.Errorf("agent name from meta: got %q", got)
	}
}

func TestParseUsage(t *testing.T) {
	body := `{"five_hour":{"utilization":5,"resets_at":"2026-10-07T08:30:00.914775+00:00"},
		"seven_day":{"utilization":51,"resets_at":"2026-10-12T00:00:00+00:00"},
		"limits":[
			{"kind":"weekly_scoped","percent":59,"resets_at":"2026-10-12T00:00:00+00:00","scope":{"model":{"display_name":"Fable"}}},
			{"kind":"other","percent":1},
			"not an object"]}`
	got, err := parseUsage([]byte(body))
	if err != nil || len(got) != 3 {
		t.Fatalf("want 3 limits, got %d (%v)", len(got), err)
	}
	fable := got[2]
	if fable.Label != "Fable this week" || fable.UsedPct != 59 || fable.ResetsAt == 0 || fable.Note != "Separate weekly limit for Fable" {
		t.Errorf("fable: %+v", fable)
	}
	if got[0].ResetsAt == 0 {
		t.Errorf("fractional-second reset time not parsed")
	}

	// The status line already has the session and the week; only Fable is added.
	base := []Limit{{Key: "five_hour", UsedPct: 7}, {Key: "seven_day", UsedPct: 51}}
	merged := mergeLimits(base, got)
	if len(merged) != 3 || merged[0].UsedPct != 7 || merged[2].Label != "Fable this week" {
		t.Errorf("merge: %+v", merged)
	}
	if _, err := parseUsage([]byte(`{}`)); err == nil {
		t.Errorf("an empty response must be an error")
	}
}

func TestParseToken(t *testing.T) {
	plain := `{"claudeAiOauth":{"accessToken":"fake-for-test"}}`
	if got := parseToken([]byte(plain)); got != "fake-for-test" {
		t.Errorf("plain: got %q", got)
	}
	if got := parseToken([]byte(hex.EncodeToString([]byte(plain)))); got != "fake-for-test" {
		t.Errorf("hex: got %q", got)
	}
	if got := parseToken([]byte("garbage")); got != "" {
		t.Errorf("garbage: got %q", got)
	}
}

func TestFetchUsage(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.Header.Get("Authorization") {
		case "Bearer good":
			w.Write([]byte(`{"five_hour":{"utilization":12,"resets_at":"2026-10-07T08:30:00Z"}}`))
		case "Bearer slow":
			w.Header().Set("Retry-After", "300")
			w.WriteHeader(http.StatusTooManyRequests)
		default:
			w.WriteHeader(http.StatusUnauthorized)
		}
	}))
	defer srv.Close()
	if got, _, err := fetchUsage(srv.URL, "good"); err != nil || len(got) != 1 || got[0].UsedPct != 12 {
		t.Errorf("good: %+v %v", got, err)
	}
	if _, retry, err := fetchUsage(srv.URL, "slow"); err == nil || retry != 300*time.Second {
		t.Errorf("slow: retry %v err %v", retry, err)
	}
	if _, _, err := fetchUsage(srv.URL, "bad"); err == nil || !strings.Contains(err.Error(), "expired") {
		t.Errorf("bad: %v", err)
	}
}

func TestModelName(t *testing.T) {
	for id, want := range map[string]string{
		"claude-opus-5-5":           "Opus 5.5",
		"claude-haiku-4-5-20251001": "Haiku 4.5",
		"claude-fable-5-1":          "Fable 5.1",
	} {
		if got := modelName(id); got != want {
			t.Errorf("%s: want %q, got %q", id, want, got)
		}
	}
}

func TestBridgeInstallAndRemove(t *testing.T) {
	dir := t.TempDir()
	script := filepath.Join(dir, "statusline.sh")
	orig := "#!/bin/bash\ninput=$(cat)\necho hi\n"
	if err := os.WriteFile(script, []byte(orig), 0o755); err != nil {
		t.Fatal(err)
	}
	cfg := Config{ClaudeDir: dir}
	for i := 0; i < 2; i++ { // the second install must not add a second line
		if err := installBridge(cfg); err != nil {
			t.Fatal(err)
		}
	}
	b, _ := os.ReadFile(script)
	if strings.Count(string(b), bridgeMarker) != 1 {
		t.Fatalf("want one bridge line, got:\n%s", b)
	}
	if lines := strings.Split(string(b), "\n"); !strings.Contains(lines[2], bridgeMarker) {
		t.Errorf("bridge line must follow input=$(cat), got:\n%s", b)
	}
	if st := bridgeStatus(cfg); !st.Installed || !st.ScriptFound {
		t.Errorf("status: %+v", st)
	}
	if bak, _ := os.ReadFile(script + ".bak.lomi"); string(bak) != orig {
		t.Errorf("backup differs from the original")
	}
	if err := removeBridge(cfg); err != nil {
		t.Fatal(err)
	}
	if b, _ := os.ReadFile(script); string(b) != orig {
		t.Errorf("remove did not restore the script:\n%s", b)
	}
	// A line installed under the app's first name still counts, is not
	// doubled by a new install, and is removed too.
	old := "#!/bin/bash\ninput=$(cat)\ntrue " + legacyMarker + "\necho hi\n"
	os.WriteFile(script, []byte(old), 0o755)
	if st := bridgeStatus(cfg); !st.Installed {
		t.Errorf("legacy bridge line not recognised")
	}
	installBridge(cfg)
	if b, _ := os.ReadFile(script); string(b) != old {
		t.Errorf("install must leave a legacy bridge alone:\n%s", b)
	}
	removeBridge(cfg)
	if b, _ := os.ReadFile(script); string(b) != orig {
		t.Errorf("remove did not take out the legacy line:\n%s", b)
	}
}

package main

import (
	"encoding/json"
	"math"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"
)

const (
	// An open session refreshes its status line every few seconds. One that
	// has been silent this long was closed, and is not shown.
	closedAfter = 20 * time.Second
	// Without the bridge there is no such signal; a session is shown while
	// its transcript changed this recently.
	transcriptWindow = 30 * time.Minute
	limitsWindow     = 12 * time.Hour // older limit reports are not shown
	pruneAfter       = 48 * time.Hour // older session files are deleted from the bridge dir

	maxTranscriptSessions = 12
	maxSessionAgents      = 200 // newest subagents read per session
)

// Session is one Claude Code session: the "Model | [bar] %" line.
type Session struct {
	ID         string  `json:"id"`
	Name       string  `json:"name"` // the session name, when Claude Code reports one
	Model      string  `json:"model"`
	Project    string  `json:"project"`
	Cwd        string  `json:"cwd"`
	ContextPct *int    `json:"contextPct"` // null until the first message is sent
	CostUSD    float64 `json:"costUsd"`
	// CostEstimated is false when Claude Code reported the cost, and true
	// when this app priced the transcript with the configured prices.
	CostEstimated bool  `json:"costEstimated"`
	UpdatedAt     int64 `json:"updatedAt"`
	Live          bool  `json:"live"`
	// "statusline" is measured by Claude Code. "transcript" is estimated by
	// this app from the transcript when the bridge is off.
	Source string   `json:"source"`
	Git    *GitInfo `json:"git"`
	// Run is this session's own /command run.
	Run *Run `json:"run"`
	// Agents are this session's subagents, most recent first.
	Agents []Agent `json:"agents"`

	transcript string
}

// Limit is one rate-limit window, e.g. the 5-hour session or the week.
type Limit struct {
	Key      string  `json:"key"`
	Label    string  `json:"label"`
	Note     string  `json:"note"`
	UsedPct  float64 `json:"usedPct"`
	ResetsAt int64   `json:"resetsAt"` // epoch seconds, 0 when unknown
}

// Agent is one subagent, read from its own transcript.
type Agent struct {
	Name        string  `json:"name"`
	Project     string  `json:"project"`
	ContextPct  int     `json:"contextPct"`
	Model       string  `json:"model"`
	CostUSD     float64 `json:"costUsd"` // tokens x the configured prices
	HasCost     bool    `json:"hasCost"`
	TokensIn    int64   `json:"tokensIn"` // context size of the last request
	TokensOut   int64   `json:"tokensOut"`
	DurationSec int64   `json:"durationSec"`
	ToolCalls   int     `json:"toolCalls"`
	FinishedAt  int64   `json:"finishedAt"` // last activity while running
	Running     bool    `json:"running"`
}

// Run is a /command run from the hooks' run ledger.
type Run struct {
	Command    string  `json:"command"`
	StartedAt  int64   `json:"startedAt"`
	EndedAt    int64   `json:"endedAt"`
	Done       bool    `json:"done"`
	AgentCount int     `json:"agentCount"`
	CostUSD    float64 `json:"costUsd"`
}

// Snapshot is everything the window shows, read fresh from disk.
type Snapshot struct {
	GeneratedAt int64        `json:"generatedAt"`
	Sessions    []Session    `json:"sessions"`
	Limits      []Limit      `json:"limits"`
	LimitsAt    int64        `json:"limitsAt"`    // when the limits were last reported
	LimitsError string       `json:"limitsError"` // why the per-model limits are missing
	Agents      []Agent      `json:"agents"`      // newest subagents over all sessions
	Bridge      BridgeStatus `json:"bridge"`
}

// flex reads a JSON number that may be written as a number or as a string.
type flex float64

func (f *flex) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), `"`)
	if s == "" || s == "null" {
		return nil
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return nil // a bad value reads as 0 instead of failing the whole file
	}
	*f = flex(v)
	return nil
}

func readJSON(path string, v any) bool {
	b, err := os.ReadFile(path)
	if err != nil {
		return false
	}
	return json.Unmarshal(b, v) == nil
}

func round2(v float64) float64 {
	return math.Round(v*100) / 100
}

// modelFamily is the short label of the status line: opus, sonnet or haiku.
func modelFamily(id string) string {
	for _, f := range []string{"opus", "sonnet", "haiku"} {
		if strings.Contains(id, f) {
			return f
		}
	}
	return strings.TrimPrefix(id, "claude-")
}

// agentName reads the agent type from the .meta.json next to a transcript.
// Without it, the name is the part of the file name that is not the hex id.
func agentName(path string) string {
	var meta struct {
		AgentType string `json:"agentType"`
	}
	if readJSON(strings.TrimSuffix(path, ".jsonl")+".meta.json", &meta) && meta.AgentType != "" {
		return meta.AgentType
	}
	var parts []string
	for _, seg := range strings.Split(strings.TrimPrefix(strings.TrimSuffix(filepath.Base(path), ".jsonl"), "agent-"), "-") {
		if strings.Trim(seg, "0123456789abcdef") != "" {
			parts = append(parts, seg)
		}
	}
	if len(parts) == 0 {
		return "subagent"
	}
	return strings.Join(parts, "-")
}

type agentFile struct {
	path string
	mod  time.Time
}

// newestAgentFiles lists subagent transcripts that match pattern, newest first.
func newestAgentFiles(pattern string, limit int) []agentFile {
	paths, _ := filepath.Glob(pattern)
	files := make([]agentFile, 0, len(paths))
	for _, p := range paths {
		if st, err := os.Stat(p); err == nil {
			files = append(files, agentFile{p, st.ModTime()})
		}
	}
	sort.Slice(files, func(i, j int) bool { return files[i].mod.After(files[j].mod) })
	if len(files) > limit {
		files = files[:limit]
	}
	return files
}

func readAgent(cfg Config, f agentFile, now time.Time) (Agent, bool) {
	t := readTranscript(f.path, false)
	if t == nil || len(t.messages) == 0 {
		return Agent{}, false
	}
	window := int64(cfg.ContextWindow)
	if strings.Contains(t.lastModel, "haiku") {
		window = 200000
	}
	a := Agent{
		Name:        agentName(f.path),
		Project:     filepath.Base(t.cwd),
		ContextPct:  clamp(int(t.lastCtx*100/window), 0, 100),
		Model:       modelFamily(t.lastModel),
		TokensIn:    t.lastCtx,
		DurationSec: max(0, t.lastTS-t.firstTS),
		ToolCalls:   len(t.tools),
		FinishedAt:  t.lastTS,
		// A transcript that stopped on a tool call and went quiet was interrupted.
		Running: t.lastStop != "end_turn" && now.Sub(f.mod) < 10*time.Minute,
	}
	byModel := t.byModel()
	for _, use := range byModel {
		a.TokensOut += use.Out
	}
	cost, priced := cfg.cost(byModel)
	a.CostUSD, a.HasCost = round2(cost), priced
	return a, true
}

func readAgents(cfg Config, pattern string, limit int, now time.Time) []Agent {
	agents := []Agent{}
	for _, f := range newestAgentFiles(pattern, limit) {
		if a, ok := readAgent(cfg, f, now); ok {
			agents = append(agents, a)
		}
	}
	sort.SliceStable(agents, func(i, j int) bool { return agents[i].FinishedAt > agents[j].FinishedAt })
	return agents
}

// readRun returns the run ledger of one session, <claudeDir>/runs/active-<id>.json.
// The ledger gives the command and its times; the agents of the run are the
// session's subagents that were active after the run started.
func readRun(cfg Config, sessionID string, agents []Agent) *Run {
	if sessionID == "" {
		return nil
	}
	var raw struct {
		Command string `json:"command"`
		Start   flex   `json:"start_epoch"`
		End     flex   `json:"end_epoch"`
		Done    bool   `json:"done"`
	}
	path := filepath.Join(cfg.claudeDir(), "runs", "active-"+filepath.Base(sessionID)+".json")
	if !readJSON(path, &raw) || raw.Command == "" || raw.Start <= 0 {
		return nil
	}
	run := &Run{Command: raw.Command, StartedAt: int64(raw.Start), Done: raw.Done}
	// Agents finish in the background after the orchestrator's turn ends, so
	// the run ends at the latest agent finish, as the status line does.
	for _, a := range agents {
		if a.FinishedAt < run.StartedAt {
			continue
		}
		run.AgentCount++
		run.CostUSD += a.CostUSD
		run.EndedAt = max(run.EndedAt, a.FinishedAt)
		if a.Running {
			run.Done = false
		}
	}
	if run.EndedAt == 0 {
		run.EndedAt = int64(raw.End)
	}
	run.CostUSD = round2(run.CostUSD)
	return run
}

// statusInput is the part of the status line stdin JSON this app uses.
type statusInput struct {
	SessionID      string `json:"session_id"`
	TranscriptPath string `json:"transcript_path"`
	SessionName    string `json:"session_name"`
	Model          struct {
		ID          string `json:"id"`
		DisplayName string `json:"display_name"`
	} `json:"model"`
	Workspace struct {
		CurrentDir string `json:"current_dir"`
		ProjectDir string `json:"project_dir"`
	} `json:"workspace"`
	Cwd  string `json:"cwd"`
	Cost struct {
		Total flex `json:"total_cost_usd"`
	} `json:"cost"`
	ContextWindow struct {
		UsedPct      *flex            `json:"used_percentage"`
		RemainingPct *flex            `json:"remaining_percentage"`
		Size         flex             `json:"context_window_size"`
		Usage        *json.RawMessage `json:"current_usage"`
	} `json:"context_window"`
	RateLimits map[string]json.RawMessage `json:"rate_limits"`
}

type usage struct {
	Input         flex `json:"input_tokens"`
	CacheCreation flex `json:"cache_creation_input_tokens"`
	CacheRead     flex `json:"cache_read_input_tokens"`
}

func (u usage) total() float64 {
	return float64(u.Input + u.CacheCreation + u.CacheRead)
}

// contextPct follows the status line: the ready-made field, else the
// remaining %, else a value computed from current_usage.
func (in statusInput) contextPct() *int {
	var pct float64
	cw := in.ContextWindow
	switch {
	case cw.UsedPct != nil:
		pct = float64(*cw.UsedPct)
	case cw.RemainingPct != nil:
		pct = 100 - float64(*cw.RemainingPct)
	case cw.Usage != nil && cw.Size > 0:
		var u usage
		if json.Unmarshal(*cw.Usage, &u) != nil || u.total() <= 0 {
			return nil
		}
		pct = u.total() * 100 / float64(cw.Size)
	default:
		return nil
	}
	p := clamp(int(pct), 0, 100)
	return &p
}

func parseEpoch(raw json.RawMessage) int64 {
	s := strings.Trim(string(raw), `"`)
	if s == "" || s == "null" {
		return 0
	}
	if v, err := strconv.ParseFloat(s, 64); err == nil {
		if v > 1e12 { // milliseconds
			v /= 1000
		}
		return int64(v)
	}
	if t, err := time.Parse(time.RFC3339, s); err == nil {
		return t.Unix()
	}
	return 0
}

var limitOrder = map[string]int{"five_hour": 0, "seven_day": 1}

// limitLabel names a rate-limit window the way Claude's usage page does.
func limitLabel(key string) (label, note string) {
	switch key {
	case "five_hour":
		return "Current session", ""
	case "seven_day":
		return "This week", ""
	}
	if m, ok := strings.CutPrefix(key, "seven_day_"); ok && m != "" {
		name := strings.ToUpper(m[:1]) + strings.ReplaceAll(m[1:], "_", " ")
		return name + " this week", "Separate weekly limit for " + name
	}
	return strings.ReplaceAll(key, "_", " "), ""
}

// parseLimits accepts every window present, so a window this app does not
// know by name still shows.
func parseLimits(raw map[string]json.RawMessage) []Limit {
	limits := []Limit{}
	for key, v := range raw {
		var w struct {
			UsedPct  *flex           `json:"used_percentage"`
			ResetsAt json.RawMessage `json:"resets_at"`
		}
		if json.Unmarshal(v, &w) != nil || w.UsedPct == nil {
			continue
		}
		label, note := limitLabel(key)
		limits = append(limits, Limit{
			Key:      key,
			Label:    label,
			Note:     note,
			UsedPct:  math.Max(0, math.Min(100, float64(*w.UsedPct))),
			ResetsAt: parseEpoch(w.ResetsAt),
		})
	}
	rank := func(k string) int {
		if r, ok := limitOrder[k]; ok {
			return r
		}
		return len(limitOrder)
	}
	sort.Slice(limits, func(i, j int) bool {
		if ri, rj := rank(limits[i].Key), rank(limits[j].Key); ri != rj {
			return ri < rj
		}
		return limits[i].Key < limits[j].Key
	})
	return limits
}

// readBridge reads the per-session files the bridge line writes. The limits
// are account-wide, so they come from the freshest file that reports them.
func readBridge(now time.Time) (sessions []Session, limits []Limit, limitsAt int64) {
	sessions, limits = []Session{}, []Limit{}
	var files []string
	for _, dir := range bridgeDirs() {
		found, _ := filepath.Glob(filepath.Join(dir, "*.json"))
		files = append(files, found...)
	}
	for _, f := range files {
		st, err := os.Stat(f)
		if err != nil {
			continue
		}
		age := now.Sub(st.ModTime())
		if age > pruneAfter {
			os.Remove(f)
			continue
		}
		var in statusInput
		if age > limitsWindow || !readJSON(f, &in) {
			continue
		}
		mod := st.ModTime().Unix()
		// A closed session still holds the last limits Claude Code reported.
		if l := parseLimits(in.RateLimits); len(l) > 0 && mod > limitsAt {
			limits, limitsAt = l, mod
		}
		if age > closedAfter {
			continue
		}
		cwd := in.Workspace.CurrentDir
		if cwd == "" {
			cwd = in.Cwd
		}
		model := in.Model.DisplayName
		if model == "" {
			model = "Claude"
		}
		sessions = append(sessions, Session{
			ID:         strings.TrimSuffix(filepath.Base(f), ".json"),
			Name:       in.SessionName,
			Model:      model,
			Project:    filepath.Base(cwd),
			Cwd:        cwd,
			ContextPct: in.contextPct(),
			CostUSD:    math.Round(float64(in.Cost.Total)*100) / 100,
			UpdatedAt:  mod,
			Live:       true,
			Source:     "statusline",
			transcript: in.TranscriptPath,
		})
	}
	sort.Slice(sessions, func(i, j int) bool { return sessions[i].UpdatedAt > sessions[j].UpdatedAt })
	return sessions, limits, limitsAt
}

// modelName turns "claude-opus-5-5" into "Opus 5.5" for the transcript fallback.
func modelName(id string) string {
	parts := strings.Split(strings.TrimPrefix(id, "claude-"), "-")
	var name, ver []string
	for _, p := range parts {
		if _, err := strconv.Atoi(p); err == nil {
			if len(p) < 6 { // skip date stamps such as 20251001
				ver = append(ver, p)
			}
		} else if p != "" {
			name = append(name, strings.ToUpper(p[:1])+p[1:])
		}
	}
	out := strings.Join(name, " ")
	if len(ver) > 0 {
		out += " " + strings.Join(ver, ".")
	}
	if out == "" {
		return "Claude"
	}
	return out
}

// readTranscriptSessions lists the recent sessions the bridge did not report.
// Their values come from the transcript and are marked "transcript".
func readTranscriptSessions(cfg Config, now time.Time, skip map[string]bool) []Session {
	type file struct {
		path string
		mod  time.Time
	}
	var recent []file
	paths, _ := filepath.Glob(filepath.Join(cfg.claudeDir(), "projects", "*", "*.jsonl"))
	for _, p := range paths {
		id := strings.TrimSuffix(filepath.Base(p), ".jsonl")
		if st, err := os.Stat(p); err == nil && now.Sub(st.ModTime()) <= transcriptWindow && !skip[id] {
			recent = append(recent, file{p, st.ModTime()})
		}
	}
	sort.Slice(recent, func(i, j int) bool { return recent[i].mod.After(recent[j].mod) })
	if len(recent) > maxTranscriptSessions {
		recent = recent[:maxTranscriptSessions]
	}
	var sessions []Session
	for _, f := range recent {
		t := readTranscript(f.path, true)
		if t == nil || len(t.messages) == 0 {
			continue
		}
		pct := clamp(int(t.lastCtx*100/int64(cfg.ContextWindow)), 0, 100)
		cost, _ := cfg.cost(t.byModel())
		sessions = append(sessions, Session{
			ID:            strings.TrimSuffix(filepath.Base(f.path), ".jsonl"),
			Model:         modelName(t.lastModel),
			Project:       filepath.Base(t.cwd),
			Cwd:           t.cwd,
			ContextPct:    &pct,
			CostUSD:       round2(cost),
			CostEstimated: true,
			UpdatedAt:     f.mod.Unix(),
			Live:          now.Sub(f.mod) <= time.Minute,
			Source:        "transcript",
			transcript:    f.path,
		})
	}
	return sessions
}

// subagentPattern matches the subagent transcripts of one session.
func subagentPattern(cfg Config, s Session) string {
	if s.transcript != "" {
		return filepath.Join(strings.TrimSuffix(s.transcript, ".jsonl"), "subagents", "agent-*.jsonl")
	}
	return filepath.Join(cfg.claudeDir(), "projects", "*", filepath.Base(s.ID), "subagents", "agent-*.jsonl")
}

func buildSnapshot(cfg Config) Snapshot {
	now := time.Now()
	snap := Snapshot{GeneratedAt: now.Unix(), Bridge: bridgeStatus(cfg)}
	snap.Sessions, snap.Limits, snap.LimitsAt = readBridge(now)
	if cfg.ModelLimits {
		extra, at, errText := accountLimits(cfg)
		snap.Limits = mergeLimits(snap.Limits, extra)
		snap.LimitsAt, snap.LimitsError = max(snap.LimitsAt, at), errText
	}
	// With the bridge, the open sessions are exactly the ones that report.
	// Without it, recent transcripts are the best signal there is.
	if !snap.Bridge.Installed {
		snap.Sessions = append(snap.Sessions, readTranscriptSessions(cfg, now, nil)...)
	}
	sort.SliceStable(snap.Sessions, func(i, j int) bool { return snap.Sessions[i].UpdatedAt > snap.Sessions[j].UpdatedAt })
	for i := range snap.Sessions {
		s := &snap.Sessions[i]
		agents := readAgents(cfg, subagentPattern(cfg, *s), maxSessionAgents, now)
		s.Run = readRun(cfg, s.ID, agents)
		s.Agents = agents[:min(len(agents), cfg.MaxAgents)]
		if cfg.Git.Show {
			s.Git = gitInfo(s.Cwd)
		}
	}
	all := filepath.Join(cfg.claudeDir(), "projects", "*", "*", "subagents", "agent-*.jsonl")
	snap.Agents = readAgents(cfg, all, cfg.MaxAgents, now)
	return snap
}

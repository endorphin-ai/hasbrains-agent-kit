package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// The status line script is the only place Claude Code hands out live session
// data (model, context %, rate limits). The bridge is one marked line in that
// script that saves its stdin JSON where this app can read it.
const bridgeMarker = "# lomi-bridge"

// The app was first called StatusDeck. A bridge line installed under that
// name keeps working: its marker and its directory are still recognised.
const (
	legacyMarker    = "# statusdeck-bridge"
	legacyBridgeDir = "~/.claude/statusdeck"
)

const bridgeLine = `{ _sd="$HOME/.claude/lomi"; _id=$(printf '%s' "$input" | jq -r '.session_id // "session"'); mkdir -p "$_sd" && printf '%s' "$input" > "$_sd/.$_id.tmp" && mv "$_sd/.$_id.tmp" "$_sd/$_id.json"; } 2>/dev/null ` + bridgeMarker

// BridgeStatus tells the UI whether live session data can arrive.
type BridgeStatus struct {
	ScriptPath  string `json:"scriptPath"`
	ScriptFound bool   `json:"scriptFound"`
	Installed   bool   `json:"installed"`
	Line        string `json:"line"` // for a manual install
}

// bridgeDir is where the bridge line writes; it must match bridgeLine.
func bridgeDir() string {
	return expandHome("~/.claude/lomi")
}

// bridgeDirs lists every directory a bridge line may write to.
func bridgeDirs() []string {
	return []string{bridgeDir(), expandHome(legacyBridgeDir)}
}

func hasBridge(script string) bool {
	return strings.Contains(script, bridgeMarker) || strings.Contains(script, legacyMarker)
}

// statuslineScript finds the script named by statusLine.command in settings.json.
func statuslineScript(cfg Config) string {
	fallback := filepath.Join(cfg.claudeDir(), "statusline.sh")
	b, err := os.ReadFile(filepath.Join(cfg.claudeDir(), "settings.json"))
	if err != nil {
		return fallback
	}
	var s struct {
		StatusLine struct {
			Command string `json:"command"`
		} `json:"statusLine"`
	}
	if json.Unmarshal(b, &s) != nil {
		return fallback
	}
	// The command is usually "bash ~/.claude/statusline.sh": take the first
	// word that names an existing file.
	for _, f := range strings.Fields(s.StatusLine.Command) {
		p := expandHome(strings.Trim(f, `"'`))
		if st, err := os.Stat(p); err == nil && !st.IsDir() && filepath.IsAbs(p) {
			return p
		}
	}
	return fallback
}

func bridgeStatus(cfg Config) BridgeStatus {
	st := BridgeStatus{ScriptPath: statuslineScript(cfg), Line: bridgeLine}
	b, err := os.ReadFile(st.ScriptPath)
	if err != nil {
		return st
	}
	st.ScriptFound = true
	st.Installed = hasBridge(string(b))
	return st
}

// installBridge adds the bridge line after the script's `input=$(cat)` line.
// It keeps a one-time backup next to the script.
func installBridge(cfg Config) error {
	path := statuslineScript(cfg)
	info, err := os.Stat(path)
	if err != nil {
		return fmt.Errorf("status line script not found at %s", path)
	}
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	src := string(b)
	if hasBridge(src) {
		return nil
	}
	lines := strings.Split(src, "\n")
	at := -1
	for i, l := range lines {
		if strings.HasPrefix(strings.TrimSpace(l), "input=$(cat)") {
			at = i
			break
		}
	}
	if at < 0 {
		return errors.New("the script has no `input=$(cat)` line; add the bridge line by hand after the script reads stdin into $input")
	}
	backup := path + ".bak.lomi"
	if _, err := os.Stat(backup); errors.Is(err, os.ErrNotExist) {
		if err := os.WriteFile(backup, b, info.Mode().Perm()); err != nil {
			return err
		}
	}
	out := append([]string{}, lines[:at+1]...)
	out = append(out, bridgeLine)
	out = append(out, lines[at+1:]...)
	return os.WriteFile(path, []byte(strings.Join(out, "\n")), info.Mode().Perm())
}

// removeBridge deletes the bridge line and leaves the rest of the script alone.
func removeBridge(cfg Config) error {
	path := statuslineScript(cfg)
	info, err := os.Stat(path)
	if err != nil {
		return nil
	}
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	if !hasBridge(string(b)) {
		return nil
	}
	var out []string
	for _, l := range strings.Split(string(b), "\n") {
		if !hasBridge(l) {
			out = append(out, l)
		}
	}
	return os.WriteFile(path, []byte(strings.Join(out, "\n")), info.Mode().Perm())
}

package main

import (
	"errors"
	"fmt"
	"math"
	"os"
	"sync"
	"time"

	"github.com/wailsapp/wails/v3/pkg/application"
)

// DeckService is the API the frontend calls. It only reads Claude Code's
// files; the two bridge methods are the only ones that change one, and only
// when the user asks.
type DeckService struct {
	mu     sync.Mutex
	cfg    Config
	window *application.WebviewWindow
	tray   *application.SystemTray
	last   *Snapshot
}

func NewDeckService() *DeckService {
	return &DeckService{cfg: loadConfig()}
}

func (d *DeckService) config() Config {
	d.mu.Lock()
	defer d.mu.Unlock()
	return d.cfg
}

// Snapshot returns the current data. The menu bar loop refreshes it; a
// call that finds it older than the refresh interval reads it again.
func (d *DeckService) Snapshot() Snapshot {
	cfg := d.config()
	d.mu.Lock()
	last := d.last
	d.mu.Unlock()
	if last != nil && time.Now().Unix()-last.GeneratedAt < int64(cfg.RefreshSeconds) {
		return *last
	}
	return d.refresh()
}

func (d *DeckService) refresh() Snapshot {
	snap := buildSnapshot(d.config())
	d.mu.Lock()
	d.last = &snap
	tray := d.tray
	d.mu.Unlock()
	if tray != nil {
		tray.SetLabel(trayLabel(snap))
	}
	return snap
}

// watch keeps the menu bar label current while the window is closed.
func (d *DeckService) watch() {
	for {
		d.refresh()
		time.Sleep(time.Duration(d.config().RefreshSeconds) * time.Second)
	}
}

// trayLabel is the number beside the menu bar icon: the session limit when
// Claude Code reports it, else the fullest context window of a live session.
func trayLabel(s Snapshot) string {
	if len(s.Limits) > 0 {
		return fmt.Sprintf(" %d%%", int(math.Round(s.Limits[0].UsedPct)))
	}
	fullest := -1
	for _, sess := range s.Sessions {
		if sess.Live && sess.ContextPct != nil {
			fullest = max(fullest, *sess.ContextPct)
		}
	}
	if fullest < 0 {
		return ""
	}
	return fmt.Sprintf(" %d%%", fullest)
}

func (d *DeckService) GetConfig() Config {
	return d.config()
}

// SaveConfig validates, stores and applies the configuration.
func (d *DeckService) SaveConfig(c Config) (Config, error) {
	c = c.normalize()
	if st, err := os.Stat(c.claudeDir()); err != nil || !st.IsDir() {
		return d.config(), errors.New("Claude directory not found: " + c.claudeDir())
	}
	if err := saveConfig(c); err != nil {
		return d.config(), err
	}
	d.mu.Lock()
	d.cfg = c
	d.last = nil // prices or paths may have changed
	w := d.window
	d.mu.Unlock()
	if w != nil {
		w.SetAlwaysOnTop(c.AlwaysOnTop)
	}
	return c, nil
}

func (d *DeckService) ResetConfig() (Config, error) {
	return d.SaveConfig(defaultConfig())
}

// InstallBridge adds the bridge line to the status line script.
func (d *DeckService) InstallBridge() (BridgeStatus, error) {
	cfg := d.config()
	err := installBridge(cfg)
	return bridgeStatus(cfg), err
}

// RemoveBridge takes the bridge line out again.
func (d *DeckService) RemoveBridge() (BridgeStatus, error) {
	cfg := d.config()
	err := removeBridge(cfg)
	return bridgeStatus(cfg), err
}

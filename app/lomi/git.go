package main

import (
	"context"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

// GitInfo is the repository state of a session's working directory.
type GitInfo struct {
	Repo     string `json:"repo"`
	Branch   string `json:"branch"`
	Worktree string `json:"worktree"` // "" in the main working tree
}

var gitCache = struct {
	sync.Mutex
	byDir map[string]gitEntry
}{byDir: map[string]gitEntry{}}

type gitEntry struct {
	at   time.Time
	info *GitInfo
}

// gitInfo asks git about dir. The answer is kept for a few seconds, so many
// sessions do not start a git process on every refresh.
func gitInfo(dir string) *GitInfo {
	if dir == "" {
		return nil
	}
	gitCache.Lock()
	defer gitCache.Unlock()
	if e, ok := gitCache.byDir[dir]; ok && time.Since(e.at) < 10*time.Second {
		return e.info
	}
	info := readGit(dir)
	gitCache.byDir[dir] = gitEntry{at: time.Now(), info: info}
	return info
}

func readGit(dir string) *GitInfo {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	out, err := exec.CommandContext(ctx, "git", "-C", dir, "rev-parse",
		"--path-format=absolute", "--show-toplevel", "--git-common-dir", "--abbrev-ref", "HEAD").Output()
	if err != nil {
		return nil
	}
	lines := strings.Split(strings.TrimSpace(string(out)), "\n")
	if len(lines) < 3 {
		return nil
	}
	top, common, branch := lines[0], lines[1], lines[2]
	// The common dir is <main repo>/.git, also from inside a linked worktree.
	main := filepath.Dir(common)
	info := &GitInfo{Repo: filepath.Base(main), Branch: branch}
	if top != main {
		info.Worktree = filepath.Base(top)
	}
	return info
}

# Claude Code status-line kit

A status line for Claude Code that shows, live:

- the active `/command` run — name, a ticking timer that **freezes** when the run ends, agent count, and estimated cost;
- skills Claude loads **on its own** (not typed as `/…`) — as a run of their own, or listed on the open `/command` run;
- the whole session's cost (from the harness);
- the current model + context-window usage bar;
- the last 8 subagents — each with a context bar, model, estimated cost, tokens in/out, duration, **tool-call count**, and finish time.
  A batch of same-name agents in one session is one row with totals: `mine-bugs ×42`.

```
⚡ /review-pr  ✓ 1h 11m  · 5 agents  · $21.68  · session $33.8
Opus 5.5 (1M context)  |  [#---------] 16%
· test-investigator  [##--------] 29% sonnet $4.19  ↓294.3k ↑53.0k · 12m 2s 38 tools  - Sep 22 3:37 PM
· risk-validator     [##--------] 27% sonnet $5.74  ↓278.9k ↑79.6k · 19m 51s 41 tools - Sep 22 1:25 PM
...
```

Skill runs look like this:

```
⚡ claude-api (skill)  ⏱ 1m 4s  · session $2.1                           ← Claude loaded a skill, no /command open
⚡ /fix-bug  ⏱ 3m 10s  · 2 agents  · $1.84  · skills gh-cli, jira-mcp +1  ← skills loaded during /fix-bug
⚡ /mine-bugs  ⏱ 41m 2s  · 30 agents (12 running)  · $287.40                 ← background batch still working
```

It also writes a per-run report (`~/.claude/runs/<command>-<stamp>.json` + `.md`) each time a
`/command` dispatches agents: totals, a per-agent-name summary, and every agent run.

### How runs are tracked

- A run is **complete** only when its turn has ended **and** every agent it launched has finished.
  Background agents keep the timer running; the report is rewritten as each one finishes.
- Every agent is counted separately (keyed by agent id, not name), so 42 agents of one type are 42 rows.
- A new `/command` or skill never erases the previous run: it is finalized and kept as
  `runs/prev-<session>.json`, and its late agents still land in it (matched by the launching tool call).
- Launches with no finish after 2 hours are treated as lost, so a run can't stay open forever.

## Install

Needs `jq` (`brew install jq` or `apt install jq`). Then:

```bash
git clone --depth 1 https://github.com/endorphin-ai/hasbrains-agent-kit.git
cd hasbrains-agent-kit/utils/statusline-kit
./install.sh
```

Restart Claude Code. That is all.

The installer:

1. Checks `jq`, the `date` flavor and `prices.json`. If `prices.json` is broken, it stops before it copies anything.
2. Copies `statusline.sh`, the four hooks and `prices.json` into `~/.claude/`.
3. Merges the settings into `~/.claude/settings.json`: it sets `statusLine` and **adds** the four hooks.
   Your other settings and hooks stay. A re-run adds no duplicates.

Every changed file is backed up as `*.bak.<stamp>` first. Unchanged files are skipped, so a re-run is safe.
You can keep the kit folder anywhere; nothing links back to it after install.

### Manual install (if you prefer)

1. Copy `statusline.sh` → `~/.claude/statusline.sh` and the four files in `hooks/` → `~/.claude/hooks/`.
   `chmod +x` all five.
2. Copy `prices.json` → `~/.claude/statusline-prices.json`.
3. Merge `settings-snippet.json` into `~/.claude/settings.json` (the `statusLine` and `hooks` blocks).

## Update prices

`prices.json` in this kit is the **only** place to change prices.

1. Edit `prices.json`. (To take the maintainer's new prices instead: `git pull`.)
2. Run:

   ```bash
   ./install.sh --prices
   ```

   It validates the file and copies it to `~/.claude/statusline-prices.json`. No restart needed.
   A full `./install.sh` does the same, plus the scripts and settings.

Do not edit `~/.claude/statusline-prices.json` — the next install overwrites it (it keeps a `.bak`).

New rates apply to agents that finish **after** the update. To re-price the rows already shown,
rebuild the history (next section).

## Rebuild the history

The `· agent …` rows are stored when each agent finishes. After a kit update that changes how agents
are counted or priced — or after a price change — old rows keep their old values. Rebuild them from
the saved transcripts:

```bash
./rebuild-history.sh            # last 7 days
./rebuild-history.sh --days 30  # a longer window
```

It replays every subagent transcript in `~/.claude/projects`, in the order the agents finished, through
the kit's own hook. It backs up the current history first and never touches the run ledgers or reports.

### How an agent is priced

Each message in the agent's transcript is priced at the rate of **the model that wrote it**, then summed.
An agent that switches model mid-run is billed at each model's own rate, and its label shows both
(e.g. `sonnet+opus`). The model of the last message sets the context-window size for the `%` bar.

### `prices.json` format

Rates are USD per 1M tokens.

```json
{
  "default": "opus-5-5",
  "models": [
    { "match": "fable-5-1", "label": "fable", "input": 10, "output": 50, "cache_write": 12.5, "cache_read": 0.25 },
    { "match": "opus-5-5",  "label": "opus",  "input": 4,  "output": 20, "cache_write": 5.00, "cache_read": 0.20 },
    { "match": "opus",      "label": "opus",  "input": 5,  "output": 25, "cache_write": 6.25, "cache_read": 0.50 }
  ]
}
```

| Field | Meaning |
|-------|---------|
| `match` | Substring of the model id (e.g. `claude-opus-5-5`). The **first** match wins — keep specific ids (`opus-5-5`) above generic ones (`opus`). |
| `label` | Short name shown in the status line. |
| `input` / `output` | Rate for input and output tokens. Required. |
| `cache_write` / `cache_read` | Rate for cache writes and reads. Optional: default to `1.25 × input` and `0.10 × input`. |
| `default` | The `match` of the entry used when no entry matches the model. |

To add a model, add an entry above any generic entry it would also match. Then run `./install.sh --prices`.

To test a price file without installing it, point the hook at it: `export CLAUDE_STATUSLINE_PRICES=/path/to/prices.json`.

## What's in the box

| File | Role |
|------|------|
| `statusline.sh` | Renders the status line (reads the ledgers below). |
| `hooks/user-prompt-submit.sh` | On a `/command`, opens a run ledger `runs/active-<sid>.json`. |
| `hooks/subagent-stop.sh` | Appends each finished subagent (tokens, cost, tool count) to the ledger + `subagent-history.json`. |
| `hooks/stop.sh` | Finalizes the ledger, freezes the timer, writes the run report. |
| `hooks/pre-tool-use.sh` | `PreToolUse` on `Skill\|Agent\|Task`: opens a run for a skill Claude loads itself (or adds it to the open run), and records each agent launch so the run stays open until it finishes. |
| `prices.json` | Per-model rates (USD / 1M tokens) — the single price source. Installed as `~/.claude/statusline-prices.json`. |
| `settings-snippet.json` | The `statusLine` + `hooks` wiring to merge into `settings.json`. |
| `rebuild-history.sh` | Rebuilds the agent rows from saved transcripts (after an update or a price change). |
| `install.sh` | Copies files + merges settings, with backups. `--prices` re-installs only the prices. |

Runtime files (`runs/`, `subagent-history.json`) are created automatically — don't copy anyone else's.

## Requirements & caveats

- **`jq` 1.7+** — the date column uses `strflocaltime`; on 1.6 rows still render but the date drops.
- **Cross-platform** — the hooks detect GNU (Linux/WSL) vs BSD (macOS) `date` automatically.
- **Cost is an estimate** at the list rates in `prices.json` (see [Update prices](#update-prices)).
  It is **not** billed cost; the `session $…` figure (from the harness) is the closest to actually billed.
- **Context %** assumes a 1M-token window for fable/opus/sonnet. On a standard 200k window, set
  `CLAUDE_AGENT_CTX_WINDOW=200000` or edit the `case` block in `hooks/subagent-stop.sh`.

## Uninstall

Remove the `statusLine` and `hooks` blocks from `~/.claude/settings.json` (or restore a
`settings.json.bak.*`), delete `~/.claude/statusline.sh`, `~/.claude/statusline-prices.json` and the four `~/.claude/hooks/*.sh`, and
optionally `rm -rf ~/.claude/runs ~/.claude/subagent-history.json`.

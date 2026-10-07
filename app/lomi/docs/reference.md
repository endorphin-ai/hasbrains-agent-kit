# Lomi reference

How Lomi works in detail. For install and use, see the [README](../README.md).

The Claude Code status line in the macOS menu bar. Built with [Wails v3](https://v3.wails.io) (Go) and Svelte 5.

Lomi has no Dock icon. Its icon sits in the menu bar with one number beside it: the used % of the session limit, or the fullest context window when Claude Code reports no limits. Click the icon to open the window; press Escape or click elsewhere to close it. Right-click the icon to quit.

```
USAGE LIMITS
 (ring +     Current session   Resets Wed 1:30 AM · in 1h 59m      [#-------------------]   5%
  mascot)    This week         Resets Sunday 5:00 PM · in 4d 15h   [##########----------]  51%

 All 4 | ● hb | ○ speech_buddy | ● lomi | ○ endorphin-ai-dev

Opus 5.5 | [#####-----] 51%  hb  /reflect                                    live
⚡ /reflect ✓ 5m 19s · 3 agents · $10.09

AGENTS OF THIS RUN   3 agents · $10.09 est. · ↓651.0k ↑3.4k · 132 tools · sonnet $8.95 · opus $1.14
· general-purpose  [#---------] 13% opus    $1.14  ↓132.6k  ↑458   1m 26s   9 tools  Oct 6 10:15 PM
· security-phx     [##--------] 29% sonnet  $6.46  ↓298.1k  ↑2.7k  23m 1s  86 tools  Oct 5 10:19 AM
```

Each open Claude Code session gets a tab with its own context bar, git details, `/command` run and subagents. A subagent that is still working shows a turning clock. The **All** tab lists every session and the newest subagents over all sessions. The usage limits are for the whole account, so they stay above the tabs.

The ring gauge follows the session limit; without limit data it follows the fullest context window. The character in it has one mood for each range of use, and the ring takes the colour of the mood:

| Used | Mood | Colour | Motion |
|---|---|---|---|
| 0–19% | Fresh | green | floats, blinks |
| 20–39% | Normal | blue | floats, blinks |
| 40–59% | Working | purple | breathes |
| 60–74% | Getting heavy | yellow | sags, worried brows |
| 75–89% | Tired | orange | pants, a sweat drop falls |
| 90–99% | Almost out | red | shakes, sweats, the ring glows |
| 100% | Out of tokens | grey | melted, smoke rises |

The character pops in each time the mood changes. With no data it is grey and asleep. The same character is the app icon and the menu bar icon.

## Run it

Requirements: Go, Node, and the Wails v3 CLI.

```sh
go install github.com/wailsapp/wails/v3/cmd/wails3@latest
wails3 dev        # development, with hot reload
wails3 package    # builds bin/lomi.app
go test .         # backend tests
```

## Where the data comes from

Lomi reads Claude Code's own files. With the default settings it makes no network request and reads no credential; the one exception is the opt-in per-model limits (see below). It does not need the status line hooks, except for the command run line.

| Panel | Source | Written by |
|---|---|---|
| Sessions, usage limits | `~/.claude/lomi/<session>.json` | the bridge line (see below) |
| Sessions, fallback | recent `~/.claude/projects/*/<session>.jsonl` | Claude Code |
| Subagents | `~/.claude/projects/*/<session>/subagents/agent-*.jsonl` and `.meta.json` | Claude Code |
| Command run, per session | `~/.claude/runs/active-<session>.json` | the run-ledger hook |
| Git details | `git rev-parse` in the session's directory | git |

### Which sessions are shown

An open session refreshes its status line every few seconds, and the bridge records each refresh. A session that has been silent for 20 seconds was closed, so its tab goes away. Without the bridge there is no such signal: a session is shown while its transcript changed in the last 30 minutes.

### Cost

Claude Code reports one cost: the total of a session, through the bridge. Lomi shows that number as it is.

Every other cost (each subagent, a command run, a session without the bridge) is an estimate: the tokens in the transcript times the prices in **Settings → Prices**. Tokens are counted once per API response, split into input, output, cache write and cache read. The default prices are Anthropic's API list prices for Fable, Opus, Sonnet and Haiku (cache write at the 5-minute rate); change a row when a price changes, and add a row for a new model. The rows are tried in order, so a specific id (`fable-5-1`) goes above its family (`fable`). An estimated session cost is marked `~` and covers the main loop only.

### The bridge

Claude Code gives the model name, the context % and the rate limits to one place only: the stdin of the status line script. **Settings → Install bridge** adds one marked line to that script, after `input=$(cat)`. The line saves the stdin JSON to `~/.claude/lomi/`. A backup of the script is kept as `statusline.sh.bak.lomi`. **Remove bridge** deletes the line again.

Without the bridge, each session row is an estimate from its transcript (shown with `~`), and the usage limits are empty.

The limits panel shows every window in `rate_limits` that Claude Code reports: `five_hour` is "Current session" and `seven_day` is "This week". Claude Code sends them after the first reply of a session, on subscription plans only. It sends these two windows only.

A per-model weekly limit, such as "Fable this week", is not in the status line data. **Settings → Per-model weekly limits** adds it as a further row. This option is off by default, because it works differently from the rest of the app: every 2 minutes Lomi reads the Claude Code login from the macOS Keychain and asks `https://api.anthropic.com/api/oauth/usage` for the usage, as the `/usage` command does. The login is the full Claude login, not a usage-only key. Lomi keeps it in memory for the one request and sends it to no other address. The endpoint is not documented and can change; after an error the app waits longer, up to 15 minutes, and shows the reason under the limits.

## Configuration

Settings are in the window and are stored in `~/Library/Application Support/lomi/config.json`.

| Setting | Default | Purpose |
|---|---|---|
| Panels | all on | Show or hide sessions, usage limits, command run, subagents |
| Compact | off | Sessions and limits only |
| Bar style | `ascii` | `[###-------]` like the status line, or `smooth` |
| Subagent rows | 8 | Rows of subagent history |
| Refresh every | 2 s | How often the files are read again |
| Yellow / red above | 50 / 75 | Bar colour thresholds, the same as the status line |
| Flag a limit at | 90 | Used % at which a rate limit turns red and bold |
| Ring gauge and character | on | The mascot beside the limits |
| Animations | on | Off stops all motion; the system "reduce motion" setting does the same |
| Keep the window open and on top | off | Do not close the window when it loses focus (restart to apply) |
| Git | all on | Show the repository, branch and worktree of each session |
| Prices | API list prices | USD per 1M tokens per model: input, output, cache write, cache read |
| Claude directory | `~/.claude` | Where the files above are |
| Context window | 1,000,000 | Used only for the transcript estimate |

## Learnings applied

From [claude-flightdeck](https://github.com/scasella/claude-flightdeck):

- **Observe only.** The app never changes a session. The bridge is the one opt-in write.
- **Every number comes from a real event, and estimates say so.** Subagent cost is an estimate from the hook, so it is labelled `est.`; the transcript fallback is labelled `~`.
- **Missing fields never break the view.** The parser accepts numbers written as strings, absent fields and unknown rate-limit windows. A failed read keeps the last good snapshot on screen.
- **Panels are configuration.** Each panel can be turned off, and there is a compact layout.

From [claude-usage-pop-up](https://github.com/gulnuravci/claude-usage-pop-up):

- Session, weekly and per-model limits are shown together, each with the reset time and a countdown.
- A threshold flags a limit that is nearly used up.
- A minimized (compact) mode.
- A ring gauge with a character whose mood follows the usage level, drawn as inline SVG.
- Its source for per-model limits (the Keychain login and `api.anthropic.com/api/oauth/usage`) is used only for the opt-in per-model rows. The session and week limits come from the status line data, which needs no login.

From [agents-observe](https://github.com/simple10/agents-observe):

- **State is derived, not stored.** Each refresh rebuilds the snapshot from the files; the app keeps no database.
- **The collection hook is fire-and-forget.** The bridge line writes one file, atomically, and sends its errors to `/dev/null`, so it cannot slow down or break the status line.
- Several sessions are listed at once, each with its project, and the subagent list has a filter.

From [opik](https://github.com/comet-ml/opik):

- Totals above the detail rows: cost, tokens in and out, tool calls.
- Cost split by model.

## Not built yet

- macOS notifications when a limit crosses a threshold.
- History and trends over time (this needs a store; the current design has none).

#!/bin/bash
# Installer for the Claude Code status-line + agent-telemetry kit.
# Copies the scripts and the price table into ~/.claude and merges the
# settings snippet into ~/.claude/settings.json WITHOUT clobbering the rest
# of your config.
#
# Usage:  ./install.sh                                full install (first time, or after any kit change)
#         ./install.sh statusline --git               full install + show git repo, branch and worktree
#         ./install.sh statusline --git branch        ... only some parts: a comma list of
#         ./install.sh statusline --git repo,branch       repo, branch, worktree
#         ./install.sh statusline --no-git            full install + hide the git info
#         ./install.sh --prices                       only re-install prices.json (after editing prices)
#
# Options are grouped by the area of the kit they change: the ones after "statusline"
# set the status line. Without "statusline --git/--no-git", a re-run keeps the current
# git setting (off on a first install).
# Safe to re-run: unchanged files are skipped, changed ones are backed up first.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
SNIPPET="$KIT_DIR/settings-snippet.json"
PRICES_SRC="$KIT_DIR/prices.json"
PRICES_DST="$CLAUDE_DIR/statusline-prices.json"
STAMP="$(date +%Y%m%d-%H%M%S)"

MODE="full"
GIT=""    # statusline --git/--no-git: the statusline.sh arg ("--git", "--git branch"),
          # "off", or "" (keep the current setting)
AREA=""   # the kit area the options that follow apply to
GIT_PARTS_RE='^(repo|branch|worktree)(,(repo|branch|worktree))*$'
while [ $# -gt 0 ]; do
  case "$AREA:$1" in
    *:--prices)          MODE="prices" ;;
    *:-h|*:--help)       sed -n '2,17p' "$0"; exit 0 ;;
    *:statusline)        AREA="statusline" ;;
    statusline:--git)
      GIT="--git"
      # An optional parts list follows: --git branch, --git repo,worktree
      if [ $# -gt 1 ] && [[ "$2" != -* ]] && [ "$2" != statusline ]; then
        [[ "$2" =~ $GIT_PARTS_RE ]] || {
          printf 'Unknown git part list: %s (use a comma list of repo, branch, worktree)\n' "$2" >&2; exit 1; }
        GIT="--git $2"; shift
      fi ;;
    statusline:--no-git) GIT="off" ;;
    :--git|:--no-git)
      printf '%s is a status line option: ./install.sh statusline %s\n' "$1" "$1" >&2; exit 1 ;;
    *) printf 'Unknown option: %s (use statusline --git [parts], statusline --no-git, --prices or --help)\n' "$1" >&2; exit 1 ;;
  esac
  shift
done

say()  { printf '  %s\n' "$*"; }
ok()   { printf '  \033[38;5;78m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[38;5;221m!\033[0m %s\n' "$*"; }
die()  { printf '  \033[38;5;203m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# Copy src → dst. Skip if identical; back up dst if it differs.
install_file() {
  local src="$1" dst="$2" mode="${3:-755}"
  if [ -f "$dst" ] && [ ! -L "$dst" ] && cmp -s "$src" "$dst"; then   # a symlink is always replaced by a real copy
    ok "$(basename "$dst") — up to date"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    cp -P "$dst" "$dst.bak.$STAMP"; rm -f "$dst"
    warn "backed up old $(basename "$dst") → $(basename "$dst").bak.$STAMP"
  fi
  cp "$src" "$dst"; chmod "$mode" "$dst"
  ok "$(basename "$dst") — installed"
}

# Fail early on a broken price table, before anything is copied.
validate_prices() {
  jq -e . "$PRICES_SRC" >/dev/null 2>&1 || die "prices.json is not valid JSON — nothing was installed."
  local err
  err=$(jq -r '
    def num: type == "number" and . >= 0;
    [ (if (.models | type) != "array" or (.models | length) == 0 then "\"models\" must be a non-empty list" else empty end),
      (.models[]? | select((.match | type) != "string" or (.match | length) == 0) | "an entry has no \"match\""),
      (.models[]? | select((.input | num | not) or (.output | num | not)) | "\(.match): input/output must be numbers"),
      (.models[]? | select((.cache_write != null and (.cache_write | num | not)) or (.cache_read != null and (.cache_read | num | not))) | "\(.match): cache_write/cache_read must be numbers"),
      (.default as $d | if [.models[]?.match] | index($d) then empty else "\"default\" (\($d)) is not the match of any entry" end)
    ] | .[]' "$PRICES_SRC" 2>/dev/null)
  [ -z "$err" ] || die "prices.json: $(printf '%s' "$err" | head -1) — nothing was installed."
}

command -v jq >/dev/null 2>&1 || die "jq is required. Install it: brew install jq  (or) apt install jq"

# --- Prices only -----------------------------------------------------------
if [ "$MODE" = "prices" ]; then
  echo "Updating prices → $PRICES_DST"
  validate_prices
  install_file "$PRICES_SRC" "$PRICES_DST" 644
  say "New rates apply to agents that finish from now on. No restart needed."
  exit 0
fi

echo "Installing Claude Code status-line kit → $CLAUDE_DIR"

# --- 1. Dependency check ---------------------------------------------------
jqver="$(jq --version 2>/dev/null | sed 's/^jq-//')"
case "$jqver" in
  1.[0-6]|1.[0-6].*) warn "jq $jqver detected — the date column needs jq 1.7+ (strflocaltime). Rows still show; the date just drops." ;;
  *) ok "jq $jqver" ;;
esac
if ! date --version >/dev/null 2>&1; then
  ok "BSD/macOS date detected — using native date syntax."
else
  ok "GNU/Linux date detected — cross-platform shim active."
fi
validate_prices
ok "prices.json is valid"

# --- 2. Copy scripts + prices ----------------------------------------------
mkdir -p "$CLAUDE_DIR/hooks"
install_file "$KIT_DIR/statusline.sh"               "$CLAUDE_DIR/statusline.sh"
install_file "$KIT_DIR/hooks/user-prompt-submit.sh" "$CLAUDE_DIR/hooks/user-prompt-submit.sh"
install_file "$KIT_DIR/hooks/subagent-stop.sh"      "$CLAUDE_DIR/hooks/subagent-stop.sh"
install_file "$KIT_DIR/hooks/stop.sh"               "$CLAUDE_DIR/hooks/stop.sh"
install_file "$KIT_DIR/hooks/pre-tool-use.sh"       "$CLAUDE_DIR/hooks/pre-tool-use.sh"
install_file "$PRICES_SRC"                          "$PRICES_DST" 644

# --- 3. Merge settings -----------------------------------------------------
# statusLine is set to ours. Hooks are ADDED: each snippet hook is appended to
# its event only if that command is not already there, so your other hooks
# stay and a re-run adds no duplicates.
# Hook commands from older kit versions are removed first (they were replaced).
# The statusline git option is a "--git [parts]" argument on the statusLine command;
# with no "statusline --git/--no-git", the one on the current command is kept.
merge='
  $snip[0] as $s
  | ["bash ~/.claude/hooks/skill-load.sh"] as $legacy
  | (if $git == "" then ([.statusLine.command // "" | capture("(^| )(?<a>--git( [a-z,]+)?)( |$)").a] | first // "")
     elif $git == "off" then "" else $git end) as $git_arg
  | .statusLine = $s.statusLine
  | if $git_arg != "" then .statusLine.command += " " + $git_arg else . end
  | if .hooks then .hooks |= (map_values(map(.hooks |= map(select(.command | IN($legacy[]) | not)))
                                        | map(select((.hooks | length) > 0))))
    else . end
  | reduce ($s.hooks | to_entries[]) as $e (.;
      reduce $e.value[] as $entry (.;
        [$entry.hooks[].command] as $cmds
        | .hooks[$e.key] = ((.hooks[$e.key] // []) as $cur
            | if any($cur[].hooks[]?.command; IN($cmds[])) then $cur else $cur + [$entry] end)))'
if [ -f "$SETTINGS" ]; then
  jq -e . "$SETTINGS" >/dev/null 2>&1 || die "$SETTINGS is not valid JSON — fix it first, nothing was merged."
  tmp="$(mktemp)"
  jq --slurpfile snip "$SNIPPET" --arg git "$GIT" "$merge" "$SETTINGS" > "$tmp"
  if [ "$(jq -S . "$tmp")" = "$(jq -S . "$SETTINGS")" ]; then
    rm -f "$tmp"; ok "settings.json — already wired"
  else
    cp "$SETTINGS" "$SETTINGS.bak.$STAMP"
    mv "$tmp" "$SETTINGS"
    ok "settings.json — merged (backup: settings.json.bak.$STAMP)"
  fi
else
  jq -n --slurpfile snip "$SNIPPET" --arg git "$GIT" "{} | $merge" > "$SETTINGS"
  ok "settings.json — created from snippet"
fi
git_shown=$(jq -r '[.statusLine.command // "" | capture("(^| )--git( (?<p>[a-z,]+))?( |$)")
  | .p // "repo,branch,worktree"] | first // "" | gsub(","; ", ")' "$SETTINGS" 2>/dev/null)
if [ -n "$git_shown" ]; then
  ok "git info — shows $git_shown (change: ./install.sh statusline --git [parts] | --no-git)"
else
  ok "git info — hidden (show with: ./install.sh statusline --git [repo,branch,worktree])"
fi

[ -f "$CLAUDE_DIR/hooks/skill-load.sh" ] && mv "$CLAUDE_DIR/hooks/skill-load.sh" "$CLAUDE_DIR/hooks/skill-load.sh.bak.$STAMP" \
  && warn "retired old hook skill-load.sh (now pre-tool-use.sh) → skill-load.sh.bak.$STAMP"

echo
ok "Done. Restart Claude Code (or start a new session) to load the status line."
echo
say "Notes:"
say "• Change prices: edit $PRICES_SRC, then run: $KIT_DIR/install.sh --prices"
say "  Do not edit ~/.claude/statusline-prices.json — the installer overwrites it."
say "• Updated the kit or prices? Re-price old rows: $KIT_DIR/rebuild-history.sh"
say "• Cost is an ESTIMATE at list rates, not billed cost."
say "• Context % assumes a 1M window for fable/opus/sonnet. On a 200k window, export"
say "  CLAUDE_AGENT_CTX_WINDOW=200000."

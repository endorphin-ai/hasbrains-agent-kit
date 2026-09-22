#!/bin/bash
# UserPromptSubmit — when the user invokes a slash command, open a "run" ledger
# keyed by session id. SubagentStop appends each agent to it; Stop finalizes a
# report. Non-command prompts are ignored (an in-flight run keeps its ledger).

input=$(cat)

prompt=$(echo "$input" | jq -r '.prompt // empty' 2>/dev/null)
sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$sid" ] && exit 0

# Only act on slash commands (prompt starts with "/" + a letter).
case "$prompt" in
  /[a-zA-Z]*) : ;;
  *) exit 0 ;;
esac
# First token of the FIRST line only — a prompt like "/cmd\npasted\nlines" must
# record just "/cmd" (awk '{print $1}' would emit $1 of every line).
cmd=${prompt%%$'\n'*}          # drop everything from the first newline
cmd=${cmd%%[[:space:]]*}       # then drop everything from the first space/tab

run_dir="$HOME/.claude/runs"
mkdir -p "$run_dir"
active="$run_dir/active-$sid.json"
now=$(date +%s)
now_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Atomic write: readers never see a half-written or empty file (mv is atomic).
put() { local t="$1.tmp.$$"; printf '%s\n' "$2" > "$t" && mv -f "$t" "$1"; }
# Never lose the previous run: finalize it (writes its report) and keep it as
# prev-<sid>.json, so its agents that are still running land in it when done.
[ -f "$active" ] && bash "$HOME/.claude/hooks/stop.sh" --refresh "$active" "$sid" </dev/null

# Atomic-ish lock (macOS has no flock): mkdir succeeds for exactly one writer.
lock="$run_dir/.lock-$sid"
i=0; until mkdir "$lock" 2>/dev/null; do i=$((i+1)); [ $i -gt 100 ] && break; sleep 0.05; done
[ -f "$active" ] && mv -f "$active" "$run_dir/prev-$sid.json"

new=$(jq -n --arg c "$cmd" --arg cwd "$cwd" --argjson s "$now" --arg si "$now_iso" \
  '{command:$c, source:"command", cwd:$cwd, start_epoch:$s, start_iso:$si, done:false, turn_ended:false,
    end_epoch:null, agents:[], launched:[], skills:[]}' 2>/dev/null)
[ -n "$new" ] && put "$active" "$new"

rmdir "$lock" 2>/dev/null
exit 0

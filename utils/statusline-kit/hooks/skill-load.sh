#!/bin/bash
# PreToolUse (matcher "Skill") — Claude loaded a skill on its own (not via a
# typed /command). Show it on the status line like a /command run:
#   - no open run  → open a run ledger named after the skill (source "skill");
#   - an open run  → add the skill to that run's "skills" list.
# SubagentStop then appends agents to the ledger; Stop finalizes it.
# Never blocks the tool: prints nothing and always exits 0.

input=$(cat)

sid=$(echo "$input"   | jq -r '.session_id // empty' 2>/dev/null)
skill=$(echo "$input" | jq -r '.tool_input.skill // .tool_input.name // empty' 2>/dev/null)
cwd=$(echo "$input"   | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$sid" ] || [ -z "$skill" ] && exit 0
skill=${skill#/}   # store the bare name; the command form keeps its "/"

run_dir="$HOME/.claude/runs"
mkdir -p "$run_dir"
active="$run_dir/active-$sid.json"
now=$(date +%s)
now_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

lock="$run_dir/.lock-$sid"
i=0; until mkdir "$lock" 2>/dev/null; do i=$((i+1)); [ $i -gt 40 ] && break; sleep 0.05; done

if [ -f "$active" ] && [ "$(jq -r '.done // false' "$active" 2>/dev/null)" = "false" ]; then
  # Open run: record the skill once (skip the skill the run is named after).
  upd=$(jq --arg k "$skill" '
    if (.command | ltrimstr("/")) == $k or ((.skills // []) | index([$k])) then .
    else .skills = ((.skills // []) + [$k]) end' "$active" 2>/dev/null)
  [ -n "$upd" ] && printf '%s\n' "$upd" > "$active"
else
  # No open run: this skill starts one.
  jq -n --arg c "$skill" --arg cwd "$cwd" --argjson s "$now" --arg si "$now_iso" \
    '{command:$c, source:"skill", cwd:$cwd, start_epoch:$s, start_iso:$si, done:false, end_epoch:null, agents:[], skills:[]}' \
    > "$active" 2>/dev/null
fi

rmdir "$lock" 2>/dev/null
exit 0

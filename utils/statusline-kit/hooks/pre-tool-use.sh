#!/bin/bash
# PreToolUse (matcher "Skill|Agent|Task") — keeps the run ledger accurate.
#
#   Skill       Claude loaded a skill on its own (not a typed /command):
#               - an open run → add the skill to its "skills" list;
#               - no open run → start a run named after the skill (source "skill").
#   Agent/Task  an agent is being launched: record its tool_use_id in the open
#               run's "launched" list, so the run stays open until it finishes
#               (background agents finish long after the turn ends).
#
# Starting a new run never loses the old one: it is finalized (report written)
# and kept as prev-<sid>.json, so its late agents still land in it.
# Never blocks the tool: prints nothing and always exits 0.

input=$(cat)

sid=$(echo "$input"  | jq -r '.session_id // empty' 2>/dev/null)
tool=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)
cwd=$(echo "$input"  | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$sid" ] && exit 0

run_dir="$HOME/.claude/runs"
mkdir -p "$run_dir"
active="$run_dir/active-$sid.json"
lock="$run_dir/.lock-$sid"
now=$(date +%s)
# Atomic write: readers never see a half-written or empty file (mv is atomic).
put() { local t="$1.tmp.$$"; printf '%s\n' "$2" > "$t" && mv -f "$t" "$1"; }
take_lock() { local i=0; until mkdir "$lock" 2>/dev/null; do i=$((i+1)); [ $i -gt 100 ] && break; sleep 0.05; done; }

case "$tool" in
  Agent|Task)
    tu=$(echo "$input" | jq -r '.tool_use_id // empty' 2>/dev/null)
    [ -n "$tu" ] && [ -f "$active" ] || exit 0          # no run open = plain chat turn
    take_lock
    # Record the launch; a finished run that launches again is open again.
    upd=$(jq --arg tu "$tu" --argjson at "$now" '
      .launched = ([.launched[]? | select(.id != $tu)] + [{id: $tu, at: $at}])
      | if .done == true then .done = false | .turn_ended = false else . end' "$active" 2>/dev/null)
    [ -n "$upd" ] && put "$active" "$upd"
    rmdir "$lock" 2>/dev/null
    ;;

  Skill)
    skill=$(echo "$input" | jq -r '.tool_input.skill // .tool_input.name // empty' 2>/dev/null)
    [ -n "$skill" ] || exit 0
    skill=${skill#/}   # store the bare name; the command form keeps its "/"
    if [ -f "$active" ] && [ "$(jq -r '.done // false' "$active" 2>/dev/null)" = "false" ]; then
      take_lock
      # Open run: record the skill once (skip the skill the run is named after).
      upd=$(jq --arg k "$skill" '
        if (.command | ltrimstr("/")) == $k or ((.skills // []) | index([$k])) then .
        else .skills = ((.skills // []) + [$k]) end' "$active" 2>/dev/null)
      [ -n "$upd" ] && put "$active" "$upd"
      rmdir "$lock" 2>/dev/null
    else
      # No open run: archive the finished one, then this skill starts a new run.
      [ -f "$active" ] && bash "$HOME/.claude/hooks/stop.sh" --refresh "$active" "$sid" </dev/null
      take_lock
      [ -f "$active" ] && mv -f "$active" "$run_dir/prev-$sid.json"
      new=$(jq -n --arg c "$skill" --arg cwd "$cwd" --argjson s "$now" --arg si "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{command:$c, source:"skill", cwd:$cwd, start_epoch:$s, start_iso:$si, done:false, turn_ended:false,
          end_epoch:null, agents:[], launched:[], skills:[]}' 2>/dev/null)
      [ -n "$new" ] && put "$active" "$new"
      rmdir "$lock" 2>/dev/null
    fi
    ;;
esac
exit 0

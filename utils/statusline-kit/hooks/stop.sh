#!/bin/bash
# Stop — the main agent finished a turn. Finalize the active run ledger:
# compute totals, freeze the timer once the run is complete, and (if it
# dispatched agents) write a per-run report to ~/.claude/runs/<command>-<stamp>.{json,md}.
#
# A run is complete only when its turn has ended AND every agent it launched
# has finished — background agents often finish long after the turn ends.
# Until then the report is rewritten each time, so it never misses a late agent.
#
# Usage:  (Stop hook)                     reads the hook input on stdin
#         stop.sh --refresh <ledger> <sid>  re-check one ledger (called by the other hooks)

# Portable epoch → stamp (GNU/Linux `date -d @` vs BSD/macOS `date -r`).
if date --version >/dev/null 2>&1; then
  epoch_to_stamp() { date -d "@$1" +%Y%m%d-%H%M%S 2>/dev/null; }   # GNU
else
  epoch_to_stamp() { date -r "$1" +%Y%m%d-%H%M%S 2>/dev/null; }    # BSD
fi

run_dir="$HOME/.claude/runs"

# Atomic write: readers never see a half-written or empty file (mv is atomic).
put() { local t="$1.tmp.$$"; printf '%s\n' "$2" > "$t" && mv -f "$t" "$1"; }
# finalize LEDGER SID TURN_ENDED(true|false)
finalize() {
  local active="$1" sid="$2" turn_end="$3" lock now fin
  [ -f "$active" ] || return 0
  lock="$run_dir/.lock-$sid"
  local i=0; until mkdir "$lock" 2>/dev/null; do i=$((i+1)); [ $i -gt 100 ] && break; sleep 0.05; done

  now=$(date +%s)
  # Launches older than 2h with no finish are treated as lost (e.g. a denied
  # launch), so a run can't stay open forever.
  fin=$(jq --argjson e "$now" --argjson te "$turn_end" '
    (if $te then .turn_ended = true else . end)
    | ([.agents[]?.tool_use_id // empty | select(. != "")]) as $fin_ids
    | ([.launched[]? | select(.at > ($e - 7200)) | .id
        | select(. as $x | $fin_ids | index($x) | not)] | length) as $pending
    | .pending = $pending
    | ([.agents[]?.finished_epoch // 0 | numbers] | max // 0) as $last_agent
    | if (.turn_ended == true) and $pending == 0 then
        (if .done != true then .end_epoch = $e else . end)
        | .done = true
        | .end_epoch = ([.end_epoch // 0, $last_agent] | max)
      else .done = false end
    | .duration_sec = (if .start_epoch and .end_epoch then (.end_epoch - .start_epoch) else null end)
    | .totals = {
        agent_count: (.agents | length),
        tokens_in:  (.agents | map(.tokens_in  // 0) | add // 0),
        tokens_out: (.agents | map(.tokens_out // 0) | add // 0),
        cost_usd:   ((.agents | map((.cost_usd // "0") | if . == "" then 0 else tonumber end) | add // 0) * 100 | round / 100)
      }' "$active" 2>/dev/null)
  [ -n "$fin" ] && put "$active" "$fin"
  rmdir "$lock" 2>/dev/null
  [ -n "$fin" ] || return 0

  # Only write a report if the run actually dispatched agents.
  local count cmd slug start_epoch stamp base
  count=$(printf '%s' "$fin" | jq -r '.totals.agent_count // 0' 2>/dev/null)
  [ "${count:-0}" -gt 0 ] 2>/dev/null || return 0

  cmd=$(printf '%s' "$fin" | jq -r '.command // "command"')
  slug=$(printf '%s' "$cmd" | sed 's#^/##; s#[^a-zA-Z0-9_-]#_#g'); [ -z "$slug" ] && slug="command"
  start_epoch=$(printf '%s' "$fin" | jq -r '.start_epoch // 0')
  stamp=$(epoch_to_stamp "$start_epoch"); [ -z "$stamp" ] && stamp="run"
  base="$run_dir/${slug}-${stamp}"

  # JSON report = the finalized ledger.
  put "$base.json" "$fin"

  # Human-readable markdown report.
  {
    printf '# %s — run report\n\n' "$cmd"
    printf '%s' "$fin" | jq -r '
      def human: if . >= 1000000 then ((.*10/1000000|floor)/10|tostring)+"M"
                 elif . >= 1000 then ((.*10/1000|floor)/10|tostring)+"k"
                 else tostring end;
      def dur: (if . >= 3600 then "\(./3600|floor)h \((.%3600)/60|floor)m"
                elif . >= 60 then "\(./60|floor)m \(.%60)s" else "\(.)s" end);
      "- Project: \(.cwd // "?")",
      "- Started: \(.start_iso // "?")",
      "- Status: \(if .done then "complete" else "running — \(.pending // 0) agent(s) still working" end)",
      "- Duration: \(.duration_sec // 0 | dur) (wall-clock)",
      "- Agents: \(.totals.agent_count)",
      "- Total tokens: down \(.totals.tokens_in | human) / up \(.totals.tokens_out | human)",
      "- Est. cost: $\(.totals.cost_usd)",
      (if (.skills // []) | length > 0 then "- Skills loaded: \(.skills | join(", "))" else empty end),
      "",
      "## By agent",
      "",
      "| Agent | Runs | Model | ctx in | out | Tools | Est. $ |",
      "|-------|------|-------|--------|-----|-------|--------|",
      (.agents | group_by(.agent_name)[]
        | "| \(.[0].agent_name) | \(length) | \([.[].model] | unique | join("+")) | \(map(.tokens_in // 0) | add | human) | \(map(.tokens_out // 0) | add | human) | \(map(.tool_calls // 0) | add) | $\(map(.cost_usd | tonumber? // 0) | add | . * 100 | round / 100) |"),
      "",
      "## Every run",
      "",
      "| Agent | Model | ctx in | out | Duration | Tools | Est. $ |",
      "|-------|-------|--------|-----|----------|-------|--------|",
      (.agents[] | "| \(.agent_name) | \(.model // "?") | \(.tokens_in|human) | \(.tokens_out|human) | \(.duration_sec|dur) | \(.tool_calls // 0) | $\(.cost_usd) |")
    '
  } > "$base.md" 2>/dev/null
}

if [ "${1:-}" = "--refresh" ]; then
  [ -n "${2:-}" ] && [ -n "${3:-}" ] && finalize "$2" "$3" false
  exit 0
fi

input=$(cat)

# Avoid re-entrancy: if a Stop hook is already running, let this one pass.
[ "$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ] && exit 0

sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
[ -z "$sid" ] && exit 0

finalize "$run_dir/active-$sid.json" "$sid" true
exit 0

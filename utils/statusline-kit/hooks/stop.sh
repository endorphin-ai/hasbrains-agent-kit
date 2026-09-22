#!/bin/bash
# Stop — the main agent finished a turn. Finalize the active run ledger:
# freeze its timer, compute totals, and (if it dispatched agents) write a
# per-run report to ~/.claude/runs/<command>-<timestamp>.{json,md}.

# Portable epoch → stamp (GNU/Linux `date -d @` vs BSD/macOS `date -r`).
if date --version >/dev/null 2>&1; then
  epoch_to_stamp() { date -d "@$1" +%Y%m%d-%H%M%S 2>/dev/null; }   # GNU
else
  epoch_to_stamp() { date -r "$1" +%Y%m%d-%H%M%S 2>/dev/null; }    # BSD
fi

input=$(cat)

# Avoid re-entrancy: if a Stop hook is already running, let this one pass.
[ "$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ] && exit 0

sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
[ -z "$sid" ] && exit 0

run_dir="$HOME/.claude/runs"
active="$run_dir/active-$sid.json"
[ -f "$active" ] || exit 0
# Already finalized (Stop fires every turn) — nothing to do.
[ "$(jq -r '.done // false' "$active" 2>/dev/null)" = "true" ] && exit 0

lock="$run_dir/.lock-$sid"
i=0; until mkdir "$lock" 2>/dev/null; do i=$((i+1)); [ $i -gt 40 ] && break; sleep 0.05; done

now=$(date +%s)
fin=$(jq --argjson e "$now" '
  .done = true | .end_epoch = $e
  | .duration_sec = (if .start_epoch then ($e - .start_epoch) else 0 end)
  | .totals = {
      agent_count: (.agents | length),
      tokens_in:  (.agents | map(.tokens_in  // 0) | add // 0),
      tokens_out: (.agents | map(.tokens_out // 0) | add // 0),
      cost_usd:   ((.agents | map((.cost_usd // "0") | if . == "" then 0 else tonumber end) | add // 0) * 100 | round / 100)
    }' "$active" 2>/dev/null)
[ -n "$fin" ] && printf '%s\n' "$fin" > "$active"
rmdir "$lock" 2>/dev/null

# Only write a report if the run actually dispatched agents.
count=$(printf '%s' "$fin" | jq -r '.totals.agent_count // 0' 2>/dev/null)
[ "${count:-0}" -gt 0 ] 2>/dev/null || exit 0

cmd=$(printf '%s' "$fin" | jq -r '.command // "command"')
slug=$(printf '%s' "$cmd" | sed 's#^/##; s#[^a-zA-Z0-9_-]#_#g'); [ -z "$slug" ] && slug="command"
start_epoch=$(printf '%s' "$fin" | jq -r '.start_epoch // 0')
stamp=$(epoch_to_stamp "$start_epoch"); [ -z "$stamp" ] && stamp="run"
base="$run_dir/${slug}-${stamp}"

# JSON report = the finalized ledger.
printf '%s\n' "$fin" > "$base.json"

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
    "- Duration: \(.duration_sec // 0 | dur) (wall-clock)",
    "- Agents: \(.totals.agent_count)",
    "- Total tokens: down \(.totals.tokens_in | human) / up \(.totals.tokens_out | human)",
    "- Est. cost: $\(.totals.cost_usd)",
    "",
    "| Agent | Model | ctx in | out | Duration | Est. $ |",
    "|-------|-------|--------|-----|----------|--------|",
    (.agents[] | "| \(.agent_name) | \(.model // "?") | \(.tokens_in|human) | \(.tokens_out|human) | \(.duration_sec|dur) | $\(.cost_usd) |")
  '
} > "$base.md" 2>/dev/null

exit 0

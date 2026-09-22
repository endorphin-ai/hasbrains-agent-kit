#!/bin/bash
# Rebuild the subagent history (the "· agent …" rows) from saved transcripts.
#
# Use it after a kit update that changes how agents are counted or priced, or
# after a price change: rows recorded earlier keep their old values until you
# rebuild. It replays every subagent transcript under ~/.claude/projects, in the
# order the agents finished, through the kit's own hooks/subagent-stop.sh.
#
# Usage:  ./rebuild-history.sh            last 7 days
#         ./rebuild-history.sh --days 30  a longer window
#
# Safe: builds into a temp file, backs up the current history, then swaps.
# Run ledgers and reports (~/.claude/runs) are not touched.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$KIT_DIR/hooks/subagent-stop.sh"
PROJECTS="$HOME/.claude/projects"
HISTORY="$HOME/.claude/subagent-history.json"
STAMP="$(date +%Y%m%d-%H%M%S)"

DAYS=7
case "${1:-}" in
  "") ;;
  --days) [[ "${2:-}" =~ ^[0-9]+$ ]] || { echo "Usage: $0 [--days N]" >&2; exit 1; }; DAYS="$2" ;;
  -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
  *) echo "Usage: $0 [--days N]" >&2; exit 1 ;;
esac

command -v jq >/dev/null 2>&1 || { echo "jq is required." >&2; exit 1; }
[ -d "$PROJECTS" ] || { echo "No transcripts found in $PROJECTS." >&2; exit 1; }

# Collect transcripts from the window, oldest finish first:
#   <last-timestamp> <session-id> <agent-type> <transcript>
list=$(mktemp); tmp_hist=$(mktemp)
trap 'rm -f "$list" "$tmp_hist"' EXIT
find "$PROJECTS" -path '*/subagents/agent-*.jsonl' -mtime "-$DAYS" 2>/dev/null | while read -r t; do
  last=$(tail -1 "$t" | jq -r '.timestamp // empty' 2>/dev/null)
  [ -n "$last" ] || continue
  sid=$(basename "$(dirname "$(dirname "$t")")")                      # <project>/<session>/subagents/agent-x.jsonl
  type=$(jq -r '.agentType // empty' "${t%.jsonl}.meta.json" 2>/dev/null)
  printf '%s\t%s\t%s\t%s\n' "$last" "$sid" "${type:-}" "$t"
done | sort > "$list"

total=$(wc -l < "$list" | tr -d ' ')
[ "$total" -gt 0 ] || { echo "No subagent transcripts in the last $DAYS days — nothing to rebuild."; exit 0; }
echo "Replaying $total subagent transcripts from the last $DAYS days…"

echo '[]' > "$tmp_hist"
n=0
while IFS=$'\t' read -r _ sid type t; do
  jq -n -c --arg s "$sid" --arg a "$type" --arg t "$t" \
    '{session_id: $s, agent_transcript_path: $t} + (if $a != "" then {agent_type: $a} else {} end)' \
  | STATUSLINE_REPLAY=1 STATUSLINE_HISTORY_FILE="$tmp_hist" bash "$HOOK" || true
  n=$((n+1)); (( n % 20 == 0 )) && echo "  $n / $total"
done < "$list"

jq -e 'type == "array"' "$tmp_hist" >/dev/null 2>&1 || { echo "Rebuild failed — history left unchanged." >&2; exit 1; }
[ -f "$HISTORY" ] && cp "$HISTORY" "$HISTORY.bak.$STAMP"
mv -f "$tmp_hist" "$HISTORY"
echo "Done. $(jq length "$HISTORY") rows rebuilt (backup: $(basename "$HISTORY").bak.$STAMP)."
jq -r '.[] | "  \(.agent_name)\(if (.count // 1) > 1 then " ×\(.count)" else "" end)  \(.model)  $\(.cost_usd)"' "$HISTORY"

#!/bin/bash
# Runs on SubagentStop — extracts context usage from subagent transcript
# and caches it for the statusline to display.

# Portable ISO-8601 → epoch (GNU/Linux `date -d` vs BSD/macOS `date -j -f`).
if date --version >/dev/null 2>&1; then
  iso_to_epoch() { date -u -d "$1" +%s 2>/dev/null; }                                   # GNU
else
  iso_to_epoch() { date -j -u -f "%Y-%m-%dT%H:%M:%S" "${1%.*}" +%s 2>/dev/null; }        # BSD
fi

input=$(cat)

# agent_type is the agent name (e.g. "Explore", "e2e-cherry-picker")
agent_name=$(echo "$input" | jq -r '.agent_type // .agent_name // empty' 2>/dev/null)
transcript_path=$(echo "$input" | jq -r '.subagent_transcript // .agent_transcript_path // .transcript_path // empty' 2>/dev/null)

# Fallback: derive agent name from transcript filename.
# Format: agent-{id}.jsonl or agent-{name}-{id}.jsonl
# The name segment contains non-hex chars; pure-hex segment = ID only.
if [ -z "$agent_name" ] && [ -n "$transcript_path" ]; then
  base=$(basename "$transcript_path" .jsonl)          # agent-acompact-2acd852...
  stem="${base#agent-}"                               # acompact-2acd852...
  # Split on '-', collect segments that are NOT pure hex (those are name parts)
  name_parts=""
  IFS='-' read -ra segs <<< "$stem"
  for seg in "${segs[@]}"; do
    if ! [[ "$seg" =~ ^[0-9a-f]+$ ]]; then
      name_parts="${name_parts:+$name_parts-}$seg"
    fi
  done
  [ -n "$name_parts" ] && agent_name="$name_parts"
fi
[ -z "$agent_name" ] && agent_name="subagent"

# Bail out if no transcript
[ -z "$transcript_path" ] || [ ! -f "$transcript_path" ] && exit 0

# Find last assistant message with usage data (skip zero-usage lines, e.g.
# "<synthetic>" error messages, which would read as 0 context and drop the agent)
last_line=$(grep '"type":"assistant"' "$transcript_path" 2>/dev/null | jq -c '
  select(((.message.usage.input_tokens // 0) + (.message.usage.cache_creation_input_tokens // 0)
          + (.message.usage.cache_read_input_tokens // 0)) > 0)' 2>/dev/null | tail -1)
[ -z "$last_line" ] && exit 0

# Total context used = input + cache_creation + cache_read tokens
input_tok=$(echo "$last_line"    | jq -r '.message.usage.input_tokens // 0' 2>/dev/null)
cache_create=$(echo "$last_line" | jq -r '.message.usage.cache_creation_input_tokens // 0' 2>/dev/null)
cache_read=$(echo "$last_line"   | jq -r '.message.usage.cache_read_input_tokens // 0' 2>/dev/null)

total=$(( ${input_tok:-0} + ${cache_create:-0} + ${cache_read:-0} ))
[ "$total" -le 0 ] && exit 0

# Tokens, cost and model label — priced PER MESSAGE by the model that wrote it,
# so an agent that switches model mid-run is billed at each model's own rate.
# Prices live in JSON, not here: edit the kit's prices.json and run
# ./install.sh --prices (or point CLAUDE_STATUSLINE_PRICES at another file).
# For each message, the first price entry whose "match" is a substring of the
# model id wins; else the "default" entry.
# IMPORTANT: Claude Code logs each assistant message as several JSONL lines
# (streaming snapshots) that all repeat the SAME usage. Summing every line
# counts cache/tokens 2-5x over. Dedupe by message.id first — keep the final
# snapshot per id (max output_tokens) — then sum.
prices_file="${CLAUDE_STATUSLINE_PRICES:-$HOME/.claude/statusline-prices.json}"
prices_json=$(jq -c . "$prices_file" 2>/dev/null); [ -n "$prices_json" ] || prices_json='{}'   # no price file → $0.00
priced=$(grep '"type":"assistant"' "$transcript_path" 2>/dev/null | jq -s -r --argjson p "$prices_json" '
  def rate($id):
    ($id | ascii_downcase) as $lid
    | ([$p.models[]? | select(.match as $k | $lid | contains($k | ascii_downcase))] | first) as $hit
    | ($hit // ([$p.models[]? | select(.match == $p.default)] | first) // {}) as $r
    | { label: ($hit.label // (if $id == "" then "?" else $id end)),
        i: ($r.input // 0), o: ($r.output // 0),
        w: ($r.cache_write // (($r.input // 0) * 1.25)),
        c: ($r.cache_read  // (($r.input // 0) * 0.10)) };
  # one row per message, in the order the messages were written
  [ to_entries[] | {n: .key, m: .value.message} ]
  | group_by(.m.id)
  | map((max_by(.m.usage.output_tokens // 0).m) + {first: (map(.n) | min)})
  | sort_by(.first)
  | map((.usage // {}) as $u | rate(.model // "") as $r
        | { label: $r.label,
            out: ($u.output_tokens // 0),
            used: (($u.input_tokens // 0) + ($u.output_tokens // 0)
                   + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)),
            usd: ((($u.input_tokens // 0) * $r.i + ($u.output_tokens // 0) * $r.o
                   + ($u.cache_creation_input_tokens // 0) * $r.w
                   + ($u.cache_read_input_tokens // 0) * $r.c) / 1000000) })
  | map(select(.used > 0)) as $rows                       # drop empty/synthetic messages
  | [ ($rows | map(.out) | add // 0),
      ($rows | map(.usd) | add // 0),
      ($rows | reduce .[].label as $l ([]; if index([$l]) then . else . + [$l] end) | join("+")),
      ($rows | last | .label // "?") ]
  | map(tostring) | join("|")' 2>/dev/null)
IFS='|' read -r out usd model ctx_model <<< "$priced"
[[ "$out" =~ ^[0-9]+$ ]] || out=0
[ -n "$model" ] || model="?"                # e.g. "opus", or "sonnet+opus" when it switched
[ -n "$ctx_model" ] || ctx_model="$model"   # the model at the end sets the context window
cost=$(awk -v u="${usd:-0}" 'BEGIN { printf "%.2f", u + 0 }' 2>/dev/null)
[[ "$cost" =~ ^[0-9]+\.[0-9]+$ ]] || cost="0.00"   # an estimate at list rates, not billed cost

# Count tool calls: unique tool_use block ids across the agent's assistant
# messages. Streaming snapshots repeat the same ids, so unique-by-id dedupes.
tool_calls=$(grep '"type":"assistant"' "$transcript_path" 2>/dev/null | jq -s '
  [ .[] | .message.content[]? | select(.type? == "tool_use") | .id ] | unique | length' 2>/dev/null)
[[ "$tool_calls" =~ ^[0-9]+$ ]] || tool_calls=0

# Context window used to compute the % — this environment runs Claude with the
# 1M-token window, so Fable/Opus/Sonnet default to 1M (Haiku is 200k). Override with
# the CLAUDE_AGENT_CTX_WINDOW env var if you ever need a different size.
ctx_size="${CLAUDE_AGENT_CTX_WINDOW:-}"
if ! [[ "$ctx_size" =~ ^[0-9]+$ ]]; then
  case "$ctx_model" in
    fable|opus|sonnet) ctx_size=1000000 ;;   # all run the 1M-token window here
    haiku)       ctx_size=200000  ;;   # Haiku is 200k
    *)           ctx_size=1000000 ;;   # unknown → assume 1M
  esac
fi
# Safety: usage can't exceed the window.
[ "$total" -gt "$ctx_size" ] 2>/dev/null && ctx_size=1000000

pct=$(( total * 100 / ctx_size ))
(( pct > 100 )) && pct=100

# Duration = last activity minus first activity in the transcript (seconds).
# Timestamps are ISO-8601 UTC (e.g. 2026-06-24T19:08:38.584Z); strip the
# fractional seconds + trailing Z and parse as UTC on macOS `date`.
first_ts=$(head -1 "$transcript_path" | jq -r '.timestamp // empty' 2>/dev/null)
last_ts=$(tail -1 "$transcript_path"  | jq -r '.timestamp // empty' 2>/dev/null)
dur=0
if [ -n "$first_ts" ] && [ -n "$last_ts" ]; then
  fs=$(iso_to_epoch "$first_ts")
  ls=$(iso_to_epoch "$last_ts")
  if [ -n "$fs" ] && [ -n "$ls" ] && [ "$ls" -ge "$fs" ] 2>/dev/null; then
    dur=$(( ls - fs ))
  fi
fi

# Skip utility/background agents that aren't user-initiated
case "$agent_name" in
  claude-code-guide|statusline-setup) exit 0 ;;
esac

finished_epoch=$(date +%s)   # when this agent completed (for the row's date/time)

# Maintain a rolling history of the last 8 UNIQUE agents (most recent first).
# Re-running an agent moves it to the top instead of creating a duplicate.
history_file=~/.claude/subagent-history.json
[ -f "$history_file" ] || echo '[]' > "$history_file"
updated=$(jq \
  --arg n "$agent_name" \
  --argjson p "$pct" \
  --arg m "$model" \
  --arg c "$cost" \
  --argjson ti "$total" \
  --argjson to "$out" \
  --argjson d "$dur" \
  --argjson tc "$tool_calls" \
  --argjson fe "$finished_epoch" \
  '[{agent_name:$n, context_pct:$p, model:$m, cost_usd:$c, tokens_in:$ti, tokens_out:$to, duration_sec:$d, tool_calls:$tc, finished_epoch:$fe}]
     + [.[] | select(.agent_name != $n)]
   | .[0:8]' \
  "$history_file" 2>/dev/null)
[ -n "$updated" ] && printf '%s\n' "$updated" > "$history_file"

# --- Append this agent to the active /command run ledger (for run reports) ---
# Only track agents that belong to an OPEN command run (opened by the
# UserPromptSubmit hook). No active ledger = a normal chat turn, not a command
# run, so we skip it (the agent still shows in the last-5 history above).
sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
active="$HOME/.claude/runs/active-$sid.json"
if [ -n "$sid" ] && [ -f "$active" ]; then
  lock="$HOME/.claude/runs/.lock-$sid"
  i=0; until mkdir "$lock" 2>/dev/null; do i=$((i+1)); [ $i -gt 40 ] && break; sleep 0.05; done

  # Append this agent (dedupe by name, latest wins), preserving chronological order.
  upd=$(jq \
    --arg n "$agent_name" --argjson p "$pct" --arg m "$model" --arg c "$cost" \
    --argjson ti "$total" --argjson to "$out" --argjson d "$dur" --argjson tc "$tool_calls" --argjson fe "$finished_epoch" \
    '.agents = ([ .agents[] | select(.agent_name != $n) ]
                + [{agent_name:$n, context_pct:$p, model:$m, cost_usd:$c, tokens_in:$ti, tokens_out:$to, duration_sec:$d, tool_calls:$tc, finished_epoch:$fe}])' \
    "$active" 2>/dev/null)
  [ -n "$upd" ] && printf '%s\n' "$upd" > "$active"
  rmdir "$lock" 2>/dev/null
fi

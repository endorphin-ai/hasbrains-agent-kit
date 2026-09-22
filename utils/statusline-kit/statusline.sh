#!/bin/bash
# Claude Code status line — minimal: model + context bar

input=$(cat)

# ANSI colors
CLR_MODEL='\033[38;5;147m'   # light purple
CLR_GREEN='\033[38;5;78m'    # green  (context healthy)
CLR_YELLOW='\033[38;5;221m'  # yellow (context <40%)
CLR_RED='\033[38;5;203m'     # red    (context <20%)
CLR_DIM='\033[38;5;245m'     # dim gray (brackets / separators)
CLR_COST='\033[38;5;179m'    # gold (per-agent $ cost)
CLR_CMD='\033[38;5;215m'     # warm orange (command name)
RST='\033[0m'

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null)

# Context USED %. Prefer the pre-calculated field; else derive from the
# remaining %, else compute manually from current_usage.
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)

if [ -z "$used_pct" ]; then
  remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty' 2>/dev/null)
  if [ -n "$remaining_pct" ]; then
    used_pct=$(( 100 - remaining_pct ))
  else
    # No pre-calculated value yet — try to derive from current_usage
    ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0' 2>/dev/null)
    current_usage=$(echo "$input" | jq '.context_window.current_usage' 2>/dev/null)
    if [ "$current_usage" != "null" ] && [ -n "$current_usage" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
      used=$(echo "$current_usage" | jq \
        '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' \
        2>/dev/null)
      [ -n "$used" ] && [ "$used" -ge 0 ] 2>/dev/null && used_pct=$(( used * 100 / ctx_size ))
    fi
  fi
fi
if [ -n "$used_pct" ]; then
  (( used_pct < 0 ))   && used_pct=0
  (( used_pct > 100 )) && used_pct=100
fi

# Build the 10-char progress bar representing a percentage (0-100)
build_bar() {
  local pct="${1:-100}"
  local width=10
  [[ "$pct" =~ ^[0-9]+$ ]] || pct=100
  (( pct < 0 ))   && pct=0
  (( pct > 100 )) && pct=100
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  printf '%*s' "$filled" '' | tr ' ' '#'
  printf '%*s' "$empty"  '' | tr ' ' '-'
}

# Choose bar color by context USED %: <=50 green, <=75 yellow, >75 red.
if [ -n "$used_pct" ]; then
  if (( used_pct <= 50 )); then
    bar_color="$CLR_GREEN"
  elif (( used_pct <= 75 )); then
    bar_color="$CLR_YELLOW"
  else
    bar_color="$CLR_RED"
  fi
  bar=$(build_bar "$used_pct")
  ctx_part="${bar_color}[${bar}]${RST} ${CLR_DIM}${used_pct}%${RST}"
else
  # No context data yet (first message not sent)
  ctx_part="${CLR_DIM}[----------] --%${RST}"
fi

# Format seconds -> "2h 05m", "4m 33s", or "45s"
fmt_dur() {
  local s="${1:-0}"
  [[ "$s" =~ ^[0-9]+$ ]] || s=0
  if (( s >= 3600 )); then
    printf '%dh %02dm' $(( s / 3600 )) $(( (s % 3600) / 60 ))
  elif (( s >= 60 )); then
    printf '%dm %ds' $(( s / 60 )) $(( s % 60 ))
  else
    printf '%ds' "$s"
  fi
}

# --- Top line: active /command run (command · timer · agents · $) ---
# Data comes from the run ledger the hooks maintain at ~/.claude/runs/.
# The timer ticks live while running and FREEZES once the run is done.
sid=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
active="$HOME/.claude/runs/active-$sid.json"
if [ -n "$sid" ] && [ -f "$active" ]; then
  r_cmd=$(jq -r '.command // empty' "$active" 2>/dev/null)
  r_cmd=${r_cmd%%$'\n'*}   # never render more than the first line of the command
  r_done=$(jq -r '.done // false' "$active" 2>/dev/null)
  r_start=$(jq -r '.start_epoch // 0' "$active" 2>/dev/null)
  # Run end = latest agent finish time (agents finish in the background, after
  # the orchestrator's turn ends), falling back to the recorded end_epoch.
  r_end=$(jq -r '(([.agents[].finished_epoch // empty] | max) // .end_epoch // 0)' "$active" 2>/dev/null)
  r_n=$(jq -r '.agents | length' "$active" 2>/dev/null)
  r_cost=$(jq -r '([.agents[] | (.cost_usd // "0") | if . == "" then 0 else tonumber end] | add // 0) * 100 | round / 100' "$active" 2>/dev/null)

  r_src=$(jq -r '.source // "command"' "$active" 2>/dev/null)
  # Skills Claude loaded on its own during this run: first 2 names, then +N.
  r_skills=$(jq -r '(.skills // []) as $k | if ($k | length) == 0 then ""
    else ($k[0:2] | join(", ")) + (if ($k | length) > 2 then " +\(($k | length) - 2)" else "" end) end' "$active" 2>/dev/null)

  if [ -n "$r_cmd" ] && [ "${r_start:-0}" -gt 0 ] 2>/dev/null; then
    if [ "$r_done" = "true" ] && [ "${r_end:-0}" -gt 0 ] 2>/dev/null; then
      r_elapsed=$(( r_end - r_start ))
      time_chunk="${CLR_GREEN}✓ $(fmt_dur "$r_elapsed")${RST}"
    else
      r_now=$(date +%s); r_elapsed=$(( r_now - r_start ))
      (( r_elapsed < 0 )) && r_elapsed=0
      time_chunk="${CLR_DIM}⏱${RST} ${CLR_GREEN}$(fmt_dur "$r_elapsed")${RST}"
    fi
    run_extra=""
    if [ "${r_n:-0}" -gt 0 ] 2>/dev/null; then
      run_extra="  ${CLR_DIM}·${RST} ${r_n} agents  ${CLR_DIM}·${RST} ${CLR_COST}\$${r_cost}${RST}"
    fi
    # This whole session's own spend (main loop + subagents), from the harness.
    sess_cost=$(echo "$input" | jq -r '(.cost.total_cost_usd // 0) | .*100 | round / 100' 2>/dev/null)
    if [ -n "$sess_cost" ] && [ "$sess_cost" != "0" ]; then
      run_extra="${run_extra}  ${CLR_DIM}· session${RST} ${CLR_COST}\$${sess_cost}${RST}"
    fi
    [ -n "$r_skills" ] && run_extra="${run_extra}  ${CLR_DIM}· skills${RST} ${r_skills}"
    r_label="${CLR_CMD}${r_cmd}${RST}"
    [ "$r_src" = "skill" ] && r_label="${CLR_CMD}${r_cmd}${RST} ${CLR_DIM}(skill)${RST}"
    printf "${CLR_DIM}⚡${RST} %b  %b%b\n" "$r_label" "$time_chunk" "$run_extra"
  fi
fi

# Render: model name  |  context bar
printf "${CLR_MODEL}%s${RST}  ${CLR_DIM}|${RST}  %b\n" "$model" "$ctx_part"

# Humanize a token count: 98309 -> 98.3k, 1234567 -> 1.2M, 812 -> 812
fmt_tokens() {
  local n="${1:-0}"
  [[ "$n" =~ ^[0-9]+$ ]] || n=0
  if (( n >= 1000000 )); then
    printf '%d.%dM' $(( n / 1000000 )) $(( (n % 1000000) / 100000 ))
  elif (( n >= 1000 )); then
    printf '%d.%dk' $(( n / 1000 )) $(( (n % 1000) / 100 ))
  else
    printf '%d' "$n"
  fi
}

# Show the last 8 unique subagents, most recent first.
history_file="${HOME}/.claude/subagent-history.json"
if [ -f "$history_file" ]; then
  while IFS='|' read -r sname spct smodel scost s_in s_out sdur stools sdate; do
    [ -z "$sname" ] && continue
    if (( spct <= 50 )); then
      sub_color="$CLR_GREEN"
    elif (( spct <= 75 )); then
      sub_color="$CLR_YELLOW"
    else
      sub_color="$CLR_RED"
    fi
    sub_bar=$(build_bar "$spct")
    name_pad=$(printf '%-18.18s' "$sname")
    # model + $cost, shown only when recorded for the agent
    meta=""
    [ -n "$smodel" ] && meta="${meta} ${CLR_DIM}${smodel}${RST}"
    [ -n "$scost" ]  && meta="${meta} ${CLR_COST}\$${scost}${RST}"
    # completion date/time, shown only when recorded
    datechunk=""
    [ -n "$sdate" ] && datechunk="  ${CLR_DIM}- ${sdate}${RST}"
    # tool-call count, shown only when recorded (>0)
    toolchunk=""
    [[ "$stools" =~ ^[0-9]+$ ]] && [ "$stools" -gt 0 ] 2>/dev/null && toolchunk=" ${stools} tools"
    printf "${CLR_DIM}·${RST} ${CLR_MODEL}%s${RST} %b%b  ${CLR_DIM}↓%s ↑%s · %s%s${RST}%b\n" \
      "$name_pad" \
      "${sub_color}[${sub_bar}]${RST} ${CLR_DIM}${spct}%${RST}" \
      "$meta" \
      "$(fmt_tokens "$s_in")" \
      "$(fmt_tokens "$s_out")" \
      "$(fmt_dur "$sdur")" \
      "$toolchunk" \
      "$datechunk"
  done < <(jq -r '.[] | [.agent_name, ((.context_pct // 0)|tostring), (.model // ""), (.cost_usd // ""), ((.tokens_in // .tokens // 0)|tostring), ((.tokens_out // 0)|tostring), ((.duration_sec // 0)|tostring), ((.tool_calls // 0)|tostring), (if .finished_epoch then (.finished_epoch | strflocaltime("%b %e %l:%M %p") | gsub("  +";" ")) else "" end)] | join("|")' "$history_file" 2>/dev/null)
fi

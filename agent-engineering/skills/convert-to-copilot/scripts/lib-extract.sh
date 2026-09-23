#!/usr/bin/env bash
# lib-extract.sh — shared helpers for convert-agents.sh
# Source this file before calling any conversion function.

G='\033[0;32m'; Y='\033[0;33m'; B='\033[0;34m'; R='\033[0;31m'; NC='\033[0m'

norm() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed 's/[^a-z0-9._-]//g'
}

# extract_fm <file> <key> — read a scalar value from YAML frontmatter
extract_fm() {
  sed -n '/^---$/,/^---$/p' "$1" \
    | grep "^${2}:" | head -1 \
    | sed "s/^${2}:[[:space:]]*//" | tr -d '"' | tr -d "'"
}

# extract_skills <file> — print one skill name per line from skills: list
extract_skills() {
  local in_skills=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^skills: ]]; then in_skills=true; continue; fi
    if $in_skills; then
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.*) ]]; then
        echo "${BASH_REMATCH[1]}" | tr -d '"' | tr -d "'" | xargs
      else
        break
      fi
    fi
  done < "$1"
}

# map_model_to_copilot <alias> — expand Claude alias to full Copilot model name
map_model_to_copilot() {
  local m; m=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case "$m" in
    *opus*)   echo "Claude Opus 4.5" ;;
    *sonnet*) echo "Claude Sonnet 4.5" ;;
    *haiku*)  echo "Claude Haiku 4.5" ;;
    *)        echo "" ;;  # omit — let Copilot choose
  esac
}

# classify_skill <file> — returns "trees" or "context"
classify_skill() {
  if grep -qiE 'decision.tree|classification|diagnosis|if.*then|when.*see|category.*map' "$1" 2>/dev/null; then
    echo "trees"
  else
    echo "context"
  fi
}

# short_name <agent-name> — derive command short name (last two words reversed)
# pr-code-reviewer → reviewer-code
short_name() {
  local parts=()
  IFS='-' read -ra parts <<< "$1"
  local n=${#parts[@]}
  if [[ $n -ge 2 ]]; then
    echo "${parts[$((n-1))]}-${parts[$((n-2))]}"
  else
    echo "$1"
  fi
}

#!/usr/bin/env bash
# pipeline-state.sh — durable squad-wide handoff-bus state (all worker agents + el-capitan)
# Usage: pipeline-state.sh <init|set|append|get|clear> <session_id> [field] [value]
#
# State file (PER-SESSION, git-ignored): .ai_log/session-<session_id>.json  (one per run; el-capitan
#   `init`s it at session start and passes its PATH as state_file to every agent). It lives under
#   .ai_log/, so it is git-ignored (never committed) by the /.ai_log/* rule — the ephemeral machine
#   handoff bus, NOT a durable record (durable records live in docs/, R7/R8).
# <session_id> is the run LABEL (convention: <YYYY-MM-DD>-<epic-slug> = <id>-<name>); the file PATH is
#   DERIVED from it (session-<session_id>.json), so every command resolves the same per-session file.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
AI_LOG="$REPO_ROOT/.ai_log"

CMD="${1:-}"
SESSION="${2:-}"
FIELD="${3:-}"
VALUE="${4:-}"

if [ -z "$CMD" ] || [ -z "$SESSION" ]; then
  echo "Usage: $0 <init|set|append|get|clear> <session_id> [field] [value]" >&2
  exit 1
fi

# Per-session, git-ignored state file under .ai_log/ — DERIVED from the session label.
# el-capitan `init`s it and passes this exact PATH as state_file to every agent.
FILE="$AI_LOG/session-${SESSION}.json"

case "$CMD" in
  init)
    mkdir -p "$AI_LOG"
    # Clean stale .ai_log/ artifacts from prior runs (R15: .ai_log/ is temporary-only).
    # Preserve the tracked .gitkeep so the folder stays committed. Runs BEFORE writing $FILE,
    # so the fresh per-session state file is written into a clean .ai_log/.
    find "$AI_LOG" -mindepth 1 ! -name .gitkeep -exec rm -rf {} + 2>/dev/null || true
    jq -n --arg s "$SESSION" '{session: $s, phases: {}}' > "$FILE"
    echo "pipeline-state: initialized $FILE (session=$SESSION)"
    ;;

  set)
    [ -z "$FIELD" ] && { echo "Error: field required" >&2; exit 1; }
    [ -f "$FILE" ] || { mkdir -p "$AI_LOG"; echo '{}' > "$FILE"; }
    tmp=$(mktemp)
    jq --arg k "$FIELD" --arg v "$VALUE" '.[$k] = $v' "$FILE" > "$tmp" && mv "$tmp" "$FILE"
    ;;

  append)
    [ -z "$FIELD" ] && { echo "Error: field required" >&2; exit 1; }
    [ -f "$FILE" ] || { mkdir -p "$AI_LOG"; echo '{}' > "$FILE"; }
    tmp=$(mktemp)
    jq --arg k "$FIELD" --arg v "$VALUE" '.[$k] = ((.[$k] // []) + [$v])' "$FILE" > "$tmp" && mv "$tmp" "$FILE"
    ;;

  get)
    [ ! -f "$FILE" ] && { echo "Error: no state file at $FILE (run 'init' first)" >&2; exit 1; }
    if [ -z "$FIELD" ]; then
      jq . "$FILE"
    else
      jq -r --arg k "$FIELD" '.[$k] // empty' "$FILE"
    fi
    ;;

  clear)
    rm -f "$FILE"
    echo "pipeline-state: cleared $FILE"
    ;;

  *)
    echo "Unknown command: $CMD" >&2
    echo "Usage: $0 <init|set|append|get|clear> <session_id> [field] [value]" >&2
    exit 1
    ;;
esac

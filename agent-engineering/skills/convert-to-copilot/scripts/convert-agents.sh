#!/usr/bin/env bash
# convert-agents.sh — scaffold conversion dispatcher
# Usage:
#   ./convert-agents.sh claude-to-copilot <agent-file> [command-file]
#   ./convert-agents.sh copilot-to-claude <agent-file>
#
# Reference: skills/convert-to-copilot/SKILL.md

set -euo pipefail

DIR="${1:-}"; AGENT_FILE="${2:-}"; CMD_FILE="${3:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib-extract.sh"

usage() {
  cat <<'EOF'
Usage:
  convert-agents.sh claude-to-copilot <claude-agent-file> [command-file]
  convert-agents.sh copilot-to-claude <copilot-agent-file>

Examples:
  ./convert-agents.sh claude-to-copilot ~/.claude/agents/pr-reviewer.md ~/.claude/commands/review-pr.md
  ./convert-agents.sh copilot-to-claude .github/agents/pr-reviewer.agent.md

After scaffolding, run /convert-to-copilot or /convert-from-copilot
in Claude Code for full content transformation.
EOF
  exit 1
}

[[ -z "$DIR" || -z "$AGENT_FILE" ]] && usage
[[ ! -f "$AGENT_FILE" ]] && echo -e "${R}Error: $AGENT_FILE not found${NC}" && exit 1

case "$DIR" in
  claude-to-copilot)
    source "${SCRIPT_DIR}/claude-to-copilot.sh"
    claude_to_copilot
    ;;
  copilot-to-claude)
    source "${SCRIPT_DIR}/copilot-to-claude.sh"
    copilot_to_claude
    ;;
  *)
    usage
    ;;
esac

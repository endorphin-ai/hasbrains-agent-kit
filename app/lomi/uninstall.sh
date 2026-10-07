#!/bin/sh
# Removes Lomi and everything it added.
#
#   curl -fsSL https://raw.githubusercontent.com/endorphin-ai/hasbrains-agent-kit/main/app/lomi/uninstall.sh | sh
set -eu

pkill -x lomi 2>/dev/null || true

# Take Lomi's bridge line out of the Claude Code status line scripts.
for f in "$HOME"/.claude/*.sh; do
  [ -f "$f" ] || continue
  if grep -q -e '# lomi-bridge' -e '# statusdeck-bridge' "$f"; then
    sed -i '' -e '/# lomi-bridge/d' -e '/# statusdeck-bridge/d' "$f"
    echo "Removed the bridge line from $f"
  fi
done

if command -v brew >/dev/null 2>&1 && brew list --cask lomi >/dev/null 2>&1; then
  brew uninstall --cask lomi
else
  rm -rf "${LOMI_DIR:-/Applications}/Lomi.app"
fi

# Saved session data and settings.
rm -rf "$HOME/.claude/lomi" "$HOME/.claude/statusdeck" "$HOME/Library/Application Support/lomi"

echo "Lomi is removed."

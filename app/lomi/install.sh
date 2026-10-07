#!/bin/sh
# Installs Lomi, the Claude Code usage app for the macOS menu bar.
#
#   curl -fsSL https://raw.githubusercontent.com/endorphin-ai/hasbrains-agent-kit/main/app/lomi/install.sh | sh
#
# LOMI_VERSION picks a release; LOMI_DIR picks the folder (default /Applications).
set -eu

VERSION="${LOMI_VERSION:-0.1.2}"
DEST="${LOMI_DIR:-/Applications}"
URL="https://github.com/endorphin-ai/hasbrains-agent-kit/releases/download/lomi-v${VERSION}/Lomi-macos-universal.zip"

if [ "$(uname)" != "Darwin" ]; then
  echo "Lomi runs on macOS only." >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading Lomi ${VERSION}..."
curl -fsSL "$URL" -o "$tmp/lomi.zip"
ditto -x -k "$tmp/lomi.zip" "$tmp"

# Replace a running or older copy.
pkill -x lomi 2>/dev/null || true
rm -rf "$DEST/Lomi.app"
mv "$tmp/Lomi.app" "$DEST/"
open "$DEST/Lomi.app"
echo "Lomi is installed in $DEST and running. Look for its face in the menu bar."

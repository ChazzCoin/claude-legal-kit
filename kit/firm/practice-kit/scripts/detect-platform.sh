#!/usr/bin/env bash
#
# detect-platform.sh — record which operating system this firm home is
# currently open on, so Claude knows which script flavor to run.
#
# Writes .claude/platform.json in the firm home. Claude reads that file
# (see conduct/running-scripts.md) and runs the .ps1 scripts on Windows,
# the .sh scripts on macOS/Linux.
#
# Run automatically by the SessionStart hook in .claude/settings.json,
# and once by bin/init at install time. Safe to run by hand at any time.
# POSIX sh compatible — no bashisms.
#
# Usage:
#   detect-platform.sh [firm-home-dir]
#
# If [firm-home-dir] is omitted, the current working directory is used
# (the SessionStart hook runs with the firm home as the working dir).

set -eu

HOME_DIR="${1:-$PWD}"
OUT_DIR="$HOME_DIR/.claude"
OUT="$OUT_DIR/platform.json"

# ─── Detect the OS family ──────────────────────────────────────────────────
uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  Darwin)               platform=macos;   family=unix ;;
  Linux)                platform=linux;   family=unix ;;
  MINGW*|MSYS*|CYGWIN*) platform=windows; family=windows ;;
  *)                    platform=unknown; family=unix ;;
esac

if [ "$family" = "windows" ]; then
  ext=".ps1"
  shell="powershell"
else
  ext=".sh"
  shell="bash"
fi

now="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)"

# ─── Write the config ──────────────────────────────────────────────────────
mkdir -p "$OUT_DIR"
cat > "$OUT" <<JSON
{
  "platform": "$platform",
  "family": "$family",
  "scriptExtension": "$ext",
  "scriptShell": "$shell",
  "detectedAt": "$now",
  "detectedBy": "detect-platform.sh"
}
JSON

echo "platform: $platform ($family) — kit scripts: *$ext — wrote .claude/platform.json"

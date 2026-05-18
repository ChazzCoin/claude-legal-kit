#!/usr/bin/env bash
#
# new-matter.sh — scaffold a new matter folder under firm/matters/<matter>/.
#
# STATUS: NOT YET IMPLEMENTED — skeleton stub. See scripts/README.md.
#
# Planned behavior:
#   - Create firm/matters/<matter>/ with the structured subfolder pattern.
#   - Copy new-matter-templates/ in.
#   - Sync shared-library/ into the matter's .claude/.
#   - Stamp foundation.json with the current kit revision.
#   - Walk through intake placeholders interactively.
#
# Windows counterpart: new-matter.ps1. Claude picks the right flavor from
# .claude/platform.json — see conduct/running-scripts.md.

set -eu
echo "new-matter.sh is not yet implemented — see firm/practice-kit/scripts/README.md" >&2
exit 1

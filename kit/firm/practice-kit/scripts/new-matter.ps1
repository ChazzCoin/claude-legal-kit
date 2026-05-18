#!/usr/bin/env pwsh
#
# new-matter.ps1 — scaffold a new matter folder under firm/matters/<matter>/.
#
# STATUS: NOT YET IMPLEMENTED — skeleton stub. See scripts/README.md.
#
# Windows-native counterpart of new-matter.sh. Planned behavior:
#   - Create firm/matters/<matter>/ with the structured subfolder pattern.
#   - Copy new-matter-templates/ in.
#   - Sync shared-library/ into the matter's .claude/.
#   - Stamp foundation.json with the current kit revision.
#   - Walk through intake placeholders interactively.
#
# Claude picks the right flavor (.sh vs .ps1) from .claude/platform.json —
# see conduct/running-scripts.md.

[CmdletBinding()]
param()
Write-Error "new-matter.ps1 is not yet implemented — see firm/practice-kit/scripts/README.md"
exit 1

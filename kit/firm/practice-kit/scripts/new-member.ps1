#!/usr/bin/env pwsh
#
# new-member.ps1 — copy members/_template/ into a new member workspace.
#
# STATUS: NOT YET IMPLEMENTED — skeleton stub. See scripts/README.md.
#
# Windows-native counterpart of new-member.sh. Planned behavior:
#   - Copy members/_template/ into a new member folder.
#   - Prompt for the member's name and role.
#   - Populate that member's CLAUDE.md.
#
# Claude picks the right flavor (.sh vs .ps1) from .claude/platform.json —
# see conduct/running-scripts.md.

[CmdletBinding()]
param()
Write-Error "new-member.ps1 is not yet implemented — see firm/practice-kit/scripts/README.md"
exit 1

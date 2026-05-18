#!/usr/bin/env pwsh
#
# sync-matter.ps1 — pull updated shared-library/ content into an existing matter.
#
# STATUS: NOT YET IMPLEMENTED — skeleton stub. See scripts/README.md.
#
# Windows-native counterpart of sync-matter.sh. Planned behavior:
#   - Pull updated shared-library/ content into an existing matter.
#   - Surface any locally-overridden files; never overwrite silently.
#
# Claude picks the right flavor (.sh vs .ps1) from .claude/platform.json —
# see conduct/running-scripts.md.

[CmdletBinding()]
param()
Write-Error "sync-matter.ps1 is not yet implemented — see firm/practice-kit/scripts/README.md"
exit 1

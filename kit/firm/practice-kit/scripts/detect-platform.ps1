#!/usr/bin/env pwsh
#
# detect-platform.ps1 — record which operating system this firm home is
# currently open on, so Claude knows which script flavor to run.
#
# Windows-native counterpart of detect-platform.sh. Writes the same
# .claude/platform.json. Claude reads that file (see conduct/running-scripts.md)
# and runs the .ps1 scripts on Windows, the .sh scripts on macOS/Linux.
#
# Run automatically by the SessionStart hook in .claude/settings.json, and
# once by bin/init.ps1 at install time. Safe to run by hand at any time.
# Works under both Windows PowerShell 5.1 (ships with Windows) and PowerShell 7+.
#
# Usage:
#   detect-platform.ps1 [-HomeDir <firm-home-dir>]
#
# If -HomeDir is omitted, the current working directory is used (the
# SessionStart hook runs with the firm home as the working dir).

[CmdletBinding()]
param(
  [string]$HomeDir = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$outDir = Join-Path $HomeDir '.claude'
$out    = Join-Path $outDir 'platform.json'

# ─── Detect the OS family ────────────────────────────────────────────────────
# $IsWindows/$IsMacOS/$IsLinux are automatic in PowerShell 7+. Windows
# PowerShell 5.1 does not define them — but 5.1 only runs on Windows.
if (Get-Variable -Name IsWindows -Scope Global -ErrorAction SilentlyContinue) {
  $onWindows = $IsWindows
  $onMac     = $IsMacOS
} else {
  $onWindows = $true
  $onMac     = $false
}

if ($onWindows) {
  $platform = 'windows'; $family = 'windows'; $ext = '.ps1'; $shell = 'powershell'
} elseif ($onMac) {
  $platform = 'macos';   $family = 'unix';    $ext = '.sh';  $shell = 'bash'
} else {
  $platform = 'linux';   $family = 'unix';    $ext = '.sh';  $shell = 'bash'
}

$now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

# ─── Write the config ────────────────────────────────────────────────────────
if (-not (Test-Path -LiteralPath $outDir)) {
  New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$json = @"
{
  "platform": "$platform",
  "family": "$family",
  "scriptExtension": "$ext",
  "scriptShell": "$shell",
  "detectedAt": "$now",
  "detectedBy": "detect-platform.ps1"
}
"@

# Write UTF-8 without a BOM so the JSON parses cleanly everywhere.
[System.IO.File]::WriteAllText($out, $json, (New-Object System.Text.UTF8Encoding $false))

Write-Host "platform: $platform ($family) — kit scripts: *$ext — wrote .claude/platform.json"

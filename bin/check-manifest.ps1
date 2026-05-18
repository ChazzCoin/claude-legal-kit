#!/usr/bin/env pwsh
#
# bin/check-manifest.ps1 — Windows-native counterpart of bin/check-manifest.
#
# Verify MANIFEST.json is a complete inventory of the kit.
#
# bin/init and /sync are MANIFEST-driven: they install exactly what
# MANIFEST.json declares. If a file is committed to kit/ or bootstrap/
# but never registered in MANIFEST.json, it silently never ships — and
# nothing else catches it. This script does.
#
# Two checks, both directions:
#   1. Coverage — every git-tracked file under kit/ and bootstrap/ is
#      registered in MANIFEST.json (matched by an exact kit.files /
#      bootstrap.files 'from', or by an ancestor directory entry).
#   2. Dangling — every MANIFEST 'from' points at a path that exists.
#
# Run it before tagging a kit release, or wire it into CI.
#
# Needs no python3 — PowerShell parses MANIFEST.json natively. Requires git.
#
# Exit: 0 if the manifest is a complete, accurate inventory; 1 otherwise.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$Manifest = Join-Path $RepoRoot 'MANIFEST.json'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "bin/check-manifest.ps1 requires git."
  exit 1
}
if (-not (Test-Path -LiteralPath $Manifest)) {
  Write-Error "MANIFEST.json not found at $Manifest"
  exit 1
}
& git -C $RepoRoot rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Error "bin/check-manifest.ps1 must run inside the claude-legal-kit git repo."
  exit 1
}

try {
  $manifest = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
} catch {
  Write-Host "ERROR: could not parse MANIFEST.json: $($_.Exception.Message)"
  exit 1
}

# Every 'from' the manifest declares (kit-managed + bootstrap), slash-stripped.
$froms = @()
foreach ($section in @('kit', 'bootstrap')) {
  if ($manifest.$section -and $manifest.$section.files) {
    foreach ($entry in $manifest.$section.files) {
      $froms += ($entry.from).TrimEnd('/')
    }
  }
}
$fromSet = @{}
foreach ($f in $froms) { $fromSet[$f] = $true }

# The real inventory: git-tracked files under kit/ and bootstrap/.
$tracked = @(& git -C $RepoRoot ls-files kit bootstrap | Where-Object { $_ })

function Test-Covered {
  param([string]$Path)
  # True if $Path equals a 'from', or any ancestor directory is a 'from'.
  if ($fromSet.ContainsKey($Path)) { return $true }
  $parts = $Path.Split('/')
  for ($i = 1; $i -lt $parts.Count; $i++) {
    $ancestor = ($parts[0..($i - 1)] -join '/')
    if ($fromSet.ContainsKey($ancestor)) { return $true }
  }
  return $false
}

$uncovered = @($tracked | Where-Object { -not (Test-Covered $_) } | Sort-Object)
$dangling  = @($froms | Where-Object {
                -not (Test-Path -LiteralPath (Join-Path $RepoRoot ($_ -replace '/', [IO.Path]::DirectorySeparatorChar)))
              } | Sort-Object -Unique)
$problems  = $uncovered.Count + $dangling.Count

Write-Host "bin/check-manifest.ps1 — MANIFEST.json coverage"
Write-Host ""

if ($uncovered.Count -gt 0) {
  Write-Host "UNREGISTERED — committed under kit/ or bootstrap/, absent from MANIFEST.json:"
  foreach ($p in $uncovered) { Write-Host "  x  $p" }
  Write-Host ""
}

if ($dangling.Count -gt 0) {
  Write-Host "DANGLING — a MANIFEST.json 'from' points at a path that does not exist:"
  foreach ($f in $dangling) { Write-Host "  x  $f" }
  Write-Host ""
}

if ($problems -eq 0) {
  Write-Host "OK   MANIFEST.json is a complete inventory."
  Write-Host "     $($tracked.Count) tracked files under kit/ + bootstrap/, all registered."
  exit 0
}

Write-Host "FAIL $problems problem(s) — MANIFEST.json and the kit tree have drifted."
exit 1

#!/usr/bin/env pwsh
#
# claude-legal-kit sync-report (PowerShell flavor) — the reconciliation
# engine behind the /sync skill ("load the latest kit updates").
#
# Windows-native counterpart of bin/sync-report, with identical behavior
# and identical output. A firm home does NOT contain the kit. The /sync
# skill first fetches the kit (a fresh, COMPLETE clone), then runs THIS
# script from inside that clone. The script is READ-ONLY: it inspects,
# classifies, and prints a report — it changes nothing. The skill is what
# applies changes, with the firm's permission, file by file.
#
# Usage:
#   <kit-clone>\bin\sync-report.ps1 <firm-home-dir>
#
# It compares every kit-managed file (the kit.files[] entries in
# MANIFEST.json, minus opt-in) three ways:
#
#   base   the file in the kit at the commit the firm last loaded
#          (the firm's .claude/foundation.json -> "pinned_sha")
#   kit    the file in the kit now (this clone)
#   firm   the firm's installed copy
#
# and classifies the drift:
#
#   UPDATE       kit changed it, firm copy untouched      -> safe to load
#   NEW          kit added it, firm has no copy           -> safe to load
#   REMOVE       kit dropped it, firm copy untouched      -> safe to remove
#   OVERRIDE     firm changed it, kit did not             -> keep firm's copy
#   CONFLICT     BOTH changed it                          -> needs a decision
#   MISSING      kit has it, firm copy is gone            -> needs a decision
#   GONE-EDITED  kit dropped it, but firm had edited it   -> needs a decision
#   (files that match all three ways are not reported)
#
# Bootstrap files (CLAUDE.md, FIRM.md, .gitignore, foundation.json) are
# the firm's own — never kit-managed, never reported here.
#
# Output is grouped and human-readable; every data line is also
# TAB-separated — "<TOKEN><TAB><firm-path><TAB><kit-path>" — for the skill
# to parse, alongside KIT-CLONE / PINNED-SHA / HEAD-SHA / PIN-CAN-ADVANCE /
# SUMMARY metadata lines. Exit 0 on a successful report (conflicts
# included); exit 1 only on an operational error.
#
# Pure PowerShell — needs only git (no python3). Content comparison is by
# git blob hash (git hash-object --no-filters), which is a byte-exact
# content comparison. Works under Windows PowerShell 5.1 and PowerShell 7+.

[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$FirmHome
)

$ErrorActionPreference = 'Stop'
# PowerShell 7.4+ can turn a native command's non-zero exit into a
# terminating error under 'Stop'. We check $LASTEXITCODE ourselves.
$PSNativeCommandUseErrorActionPreference = $false

function Fail([string]$msg) {
  Write-Output "ERROR: $msg"
  exit 1
}

# ─── Resolve firm home + kit location ──────────────────────────────────────
if (-not $FirmHome) {
  [Console]::Error.WriteLine("usage: bin\sync-report.ps1 <firm-home-dir>")
  exit 1
}
if (-not (Test-Path -LiteralPath $FirmHome -PathType Container)) {
  [Console]::Error.WriteLine("ERROR: firm home not found: $FirmHome")
  exit 1
}
$firm = (Resolve-Path -LiteralPath $FirmHome).Path

$kit      = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$manifest = Join-Path $kit 'MANIFEST.json'

# ─── Preflight ─────────────────────────────────────────────────────────────
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  [Console]::Error.WriteLine("ERROR: bin\sync-report.ps1 requires git — install it and re-run.")
  exit 1
}
if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
  [Console]::Error.WriteLine("ERROR: MANIFEST.json not found at $manifest")
  exit 1
}
$foundationPath = Join-Path (Join-Path $firm '.claude') 'foundation.json'
if (-not (Test-Path -LiteralPath $foundationPath -PathType Leaf)) {
  [Console]::Error.WriteLine("ERROR: $firm is not a firm home — no record of which kit it tracks.")
  [Console]::Error.WriteLine("       (expected .claude/foundation.json — run bin/init there first.)")
  exit 1
}
& git -C $kit rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
  [Console]::Error.WriteLine("ERROR: bin\sync-report.ps1 must run from inside a kit clone (a git repo).")
  exit 1
}

# ─── foundation.json: which kit, and the commit the firm last loaded ───────
try {
  $foundation = Get-Content -LiteralPath $foundationPath -Raw | ConvertFrom-Json
} catch {
  Fail("could not read the firm's kit record (.claude/foundation.json): $_")
}

$pinned = ''
if ($foundation.pinned_sha) { $pinned = ([string]$foundation.pinned_sha).Trim() }
$kitRepo    = if ($foundation.kit.repo) { $foundation.kit.repo } else { '(unknown)' }
$kitBranch  = if ($foundation.kit.branch) { $foundation.kit.branch } else { '(unknown)' }
$lastSynced = if ($foundation.last_synced) { $foundation.last_synced } else { '(unknown)' }
$unpinned   = (-not $pinned) -or ($pinned -eq 'unpinned')

# ─── this clone's current version ──────────────────────────────────────────
$head = (& git -C $kit rev-parse HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $head) {
  Fail("could not read the kit's current version.")
}
$head = $head.Trim()

# ─── the pinned commit must be reachable in this clone ─────────────────────
if (-not $unpinned) {
  & git -C $kit cat-file -e "$pinned^{commit}" 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) {
    $short = if ($pinned.Length -ge 12) { $pinned.Substring(0, 12) } else { $pinned }
    Fail("this kit copy does not reach back to the version the firm last " +
         "loaded ($short) — fetch the kit's full history and retry.")
  }
}

# ─── MANIFEST: the kit-managed files (kit.files, minus opt-in) ─────────────
try {
  $m = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
} catch {
  Fail("could not read MANIFEST.json: $_")
}
$entries = @()
foreach ($e in @($m.kit.files)) {
  if ($e.policy -in @('directory-mirror', 'file-replace')) {
    $entries += [pscustomobject]@{ policy = $e.policy; from = $e.from; to = $e.to }
  }
}

# ─── content / enumeration helpers ─────────────────────────────────────────
function Base-Sha([string]$rel) {
  # Blob SHA of the file as it stood at the pinned commit, or $null.
  if ($unpinned) { return $null }
  $sha = (& git -C $kit rev-parse --verify --quiet "${pinned}:$rel") 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $sha) { return $null }
  return $sha.Trim()
}

function File-Sha([string]$path) {
  # Blob SHA of an on-disk file (byte-exact content hash), or $null.
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
  $sha = & git -C $kit hash-object --no-filters -- $path
  if ($LASTEXITCODE -ne 0 -or -not $sha) { return $null }
  return ([string]$sha).Trim()
}

function Split-Nul($raw) {
  $joined = ($raw -join '')
  if (-not $joined) { return @() }
  return $joined.Split([char]0) | Where-Object { $_ }
}

function Ls-Now([string]$fromRel) {
  $raw = (& git -C $kit ls-files -z -- $fromRel.TrimEnd('/')) 2>$null
  return Split-Nul $raw
}

function Ls-Base([string]$fromRel) {
  if ($unpinned) { return @() }
  $raw = (& git -C $kit ls-tree -r -z --name-only $pinned -- $fromRel.TrimEnd('/')) 2>$null
  if ($LASTEXITCODE -ne 0) { return @() }
  return Split-Nul $raw
}

$SKIP = @('.gitkeep', '.DS_Store')

function To-Path([string]$policy, [string]$fromRel, [string]$toRel, [string]$fileRel) {
  # Map a kit-side file path to the firm-side path it installs to.
  if ($policy -eq 'file-replace') { return $toRel }
  $fr = $fromRel.TrimEnd('/')
  $tr = $toRel.TrimEnd('/')
  return $tr + '/' + $fileRel.Substring($fr.Length).TrimStart('/')
}

# ─── classify every managed file ───────────────────────────────────────────
$order = @('UPDATE', 'NEW', 'REMOVE', 'OVERRIDE', 'CONFLICT', 'MISSING', 'GONE-EDITED')
$results = @{}
foreach ($s in $order) { $results[$s] = New-Object System.Collections.ArrayList }
$seen = New-Object System.Collections.Generic.HashSet[string]

foreach ($entry in $entries) {
  if ($entry.policy -eq 'file-replace') {
    $files = @($entry.from)
  } else {
    $files = @(Ls-Now $entry.from) + @(Ls-Base $entry.from) | Sort-Object -Unique
  }
  foreach ($fr in $files) {
    if (-not $fr) { continue }
    if (($SKIP -contains [System.IO.Path]::GetFileName($fr)) -or $seen.Contains($fr)) { continue }
    [void]$seen.Add($fr)
    $tr = To-Path $entry.policy $entry.from $entry.to $fr
    $b = Base-Sha $fr
    $k = File-Sha (Join-Path $kit $fr)
    $f = File-Sha (Join-Path $firm $tr)

    if ($null -eq $k) {
      # kit no longer has this file
      if (($null -ne $b) -and ($null -ne $f)) {
        $bucket = if ($f -eq $b) { 'REMOVE' } else { 'GONE-EDITED' }
        [void]$results[$bucket].Add([pscustomobject]@{ firm = $tr; kit = $fr })
      }
      continue
    }
    if ($null -eq $f) {
      # firm has no copy
      $bucket = if ($null -eq $b) { 'NEW' } else { 'MISSING' }
      [void]$results[$bucket].Add([pscustomobject]@{ firm = $tr; kit = $fr })
      continue
    }
    if ($null -eq $b) {
      # no base to compare against (new since the pin, or unpinned)
      if ($f -ne $k) { [void]$results['CONFLICT'].Add([pscustomobject]@{ firm = $tr; kit = $fr }) }
      continue
    }
    if ($b -eq $k) {
      # kit unchanged since the pin
      if ($f -ne $b) { [void]$results['OVERRIDE'].Add([pscustomobject]@{ firm = $tr; kit = $fr }) }
    } else {
      # kit changed since the pin
      if ($f -eq $b) {
        [void]$results['UPDATE'].Add([pscustomobject]@{ firm = $tr; kit = $fr })
      } elseif ($f -ne $k) {
        [void]$results['CONFLICT'].Add([pscustomobject]@{ firm = $tr; kit = $fr })
      }
    }
    # f == b == k (untouched) or f == k (firm already converged): silent
  }
}

# ─── report ────────────────────────────────────────────────────────────────
$HEADERS = @{
  'UPDATE'      = 'Kit improvements ready to load (firm copy untouched)'
  'NEW'         = 'New in the kit (firm has no copy yet)'
  'REMOVE'      = 'Dropped by the kit (firm copy untouched — safe to remove)'
  'OVERRIDE'    = 'Firm customizations (kit unchanged here — keep firm''s copy)'
  'CONFLICT'    = 'Disagreements (kit AND firm both changed it — needs a decision)'
  'MISSING'     = 'Gone from the firm (kit still has it — needs a decision)'
  'GONE-EDITED' = 'Dropped by the kit, but the firm had edited it (needs a decision)'
}
$needsDecision = @('CONFLICT', 'MISSING', 'GONE-EDITED')
$TAB = "`t"

Write-Output "claude-legal-kit sync-report"
Write-Output ("  firm home:  {0}" -f $firm)
Write-Output ("  kit:        {0} (branch: {1})" -f $kitRepo, $kitBranch)
if ($unpinned) {
  Write-Output "  pinned at:  (unpinned — no base to compare against; files that"
  Write-Output "              differ from the kit are reported as disagreements)"
} else {
  $pinShort = if ($pinned.Length -ge 12) { $pinned.Substring(0, 12) } else { $pinned }
  Write-Output ("  pinned at:  {0}  (last loaded {1})" -f $pinShort, $lastSynced)
}
Write-Output ("  kit now at: {0}" -f $head.Substring(0, [Math]::Min(12, $head.Length)))
Write-Output ""
Write-Output ("KIT-CLONE{0}{1}" -f $TAB, $kit)
Write-Output ("PINNED-SHA{0}{1}" -f $TAB, $(if ($unpinned) { 'unpinned' } else { $pinned }))
Write-Output ("HEAD-SHA{0}{1}" -f $TAB, $head)

$total = 0
foreach ($s in $order) { $total += $results[$s].Count }
if ($total -eq 0) {
  Write-Output ""
  Write-Output "This firm is already on the latest kit. Nothing to load."
  Write-Output ("PIN-CAN-ADVANCE{0}yes" -f $TAB)
  Write-Output ("SUMMARY{0}0" -f $TAB)
  exit 0
}

foreach ($s in $order) {
  if ($results[$s].Count -eq 0) { continue }
  Write-Output ""
  Write-Output ("-> {0}" -f $HEADERS[$s])
  $sorted = $results[$s] | Sort-Object firm, kit
  foreach ($pair in $sorted) {
    Write-Output ("{0}{1}{2}{1}{3}" -f $s, $TAB, $pair.firm, $pair.kit)
  }
}

$pending = 0
foreach ($s in $needsDecision) { $pending += $results[$s].Count }
$parts = foreach ($s in $order) {
  if ($results[$s].Count -gt 0) { "{0} {1}" -f $results[$s].Count, $s.ToLower() }
}
Write-Output ""
Write-Output ("Summary: " + ($parts -join ', ') + ".")
Write-Output ("PIN-CAN-ADVANCE{0}{1}" -f $TAB, $(if ($pending) { 'no' } else { 'yes' }))
Write-Output ("SUMMARY{0}{1}" -f $TAB, $total)
exit 0

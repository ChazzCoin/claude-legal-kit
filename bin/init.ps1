#!/usr/bin/env pwsh
#
# claude-legal-kit init (PowerShell) — Windows-native counterpart of bin/init.
#
# Bootstrap a law firm's home folder with the claude-legal-kit foundation.
#
# Usage:
#   claude-legal-kit\bin\init.ps1 [-Target <firm-home-dir>]
#   pwsh claude-legal-kit/bin/init.ps1 -Target C:\path\to\firm-home
#
# If -Target is omitted, the current working directory is used.
#
# This is a faithful port of the bash bin/init: it installs exactly what
# MANIFEST.json declares, applying each entry by its policy:
#
#   kit.files[]              files the kit owns (updated later via /sync)
#     directory-mirror       overlay a directory's contents into the firm home
#     file-replace           copy a single file (overwrites)
#     opt-in                 registered but NOT installed — added manually
#   bootstrap.files[]        one-time files, never overwritten by /sync
#     skip-if-exists         copy only if the target is absent
#     init-only-with-sha     copy + stamp {{KIT_SHA}} {{KIT_BRANCH}} {{TODAY}}
#   scaffold.directories[]   empty directories created with a .gitkeep
#
# Unlike the bash version, this script needs NO python3 — PowerShell parses
# MANIFEST.json natively with ConvertFrom-Json. The only external requirement
# is git (used, if present, to pin foundation.json to the kit commit).
#
# Runs under Windows PowerShell 5.1 (ships with every Windows install) and
# PowerShell 7+. The kit must already be on disk — clone it first. No network.

[CmdletBinding()]
param(
  [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

# ─── Resolve target + kit location ─────────────────────────────────────────
if (-not (Test-Path -LiteralPath $Target)) {
  New-Item -ItemType Directory -Path $Target -Force | Out-Null
}
$Target = (Resolve-Path -LiteralPath $Target).Path

$KitDir     = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$KitRepoUrl = 'https://github.com/ChazzCoin/claude-legal-kit'
$Manifest   = Join-Path $KitDir 'MANIFEST.json'

# ─── Preflight ─────────────────────────────────────────────────────────────
if (-not (Test-Path -LiteralPath $Manifest)) {
  Write-Error "MANIFEST.json not found at $Manifest"
  exit 1
}
try {
  $m = Get-Content -LiteralPath $Manifest -Raw | ConvertFrom-Json
} catch {
  Write-Error "MANIFEST.json is not valid JSON: $Manifest"
  exit 1
}

# ─── Resolve kit identity (for the foundation.json pin) ────────────────────
$KitSha    = 'unpinned'
$KitBranch = 'main'
if (Get-Command git -ErrorAction SilentlyContinue) {
  $sha = (& git -C $KitDir rev-parse HEAD 2>$null)
  if ($LASTEXITCODE -eq 0 -and $sha) {
    $KitSha    = $sha.Trim()
    $KitBranch = ((& git -C $KitDir rev-parse --abbrev-ref HEAD) 2>$null).Trim()
  }
}
# Kit downloaded as a zip — /sync still works, treats files as drifted.
$Today = (Get-Date -Format 'yyyy-MM-dd')

$shaShort = if ($KitSha.Length -ge 12) { $KitSha.Substring(0, 12) } else { $KitSha }
Write-Host "claude-legal-kit init (PowerShell)"
Write-Host "  source:   $KitDir (sha: $shaShort, branch: $KitBranch)"
Write-Host "  target:   $Target"
Write-Host "  manifest: MANIFEST.json"
Write-Host ""

# ─── Manifest reader ───────────────────────────────────────────────────────
# Build one ordered list of file records (kit.files then bootstrap.files).
$fileRecords = @()
foreach ($section in @('kit', 'bootstrap')) {
  if ($m.$section -and $m.$section.files) {
    foreach ($e in $m.$section.files) {
      $fileRecords += [pscustomobject]@{ policy = $e.policy; from = $e.from; to = $e.to }
    }
  }
}

$failures = 0

# ─── 1. Install files (kit.files + bootstrap.files) ────────────────────────
Write-Host "→ Installing files (per MANIFEST.json)"

foreach ($r in $fileRecords) {
  $src = Join-Path $KitDir ($r.from -replace '/', [IO.Path]::DirectorySeparatorChar)
  $dst = Join-Path $Target ($r.to   -replace '/', [IO.Path]::DirectorySeparatorChar)

  switch ($r.policy) {

    'directory-mirror' {
      if (-not (Test-Path -LiteralPath $src -PathType Container)) {
        Write-Host "    ERROR:   $($r.from) — source directory missing"
        $failures++
        continue
      }
      New-Item -ItemType Directory -Path $dst -Force | Out-Null
      # Copy the directory's *contents* into $dst (overlay), like `cp -R src/. dst`.
      Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force
      Write-Host "    mirror:  $($r.to)"
    }

    'file-replace' {
      if (-not (Test-Path -LiteralPath $src -PathType Leaf)) {
        Write-Host "    ERROR:   $($r.from) — source file missing"
        $failures++
        continue
      }
      New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
      Copy-Item -LiteralPath $src -Destination $dst -Force
      Write-Host "    file:    $($r.to)"
    }

    'opt-in' {
      Write-Host "    opt-in:  $($r.to)  (registered, not installed — see $($r.from))"
    }

    'skip-if-exists' {
      if (Test-Path -LiteralPath $dst) {
        Write-Host "    skip:    $($r.to)  (exists)"
      } elseif (-not (Test-Path -LiteralPath $src)) {
        Write-Host "    ERROR:   $($r.from) — source missing"
        $failures++
      } else {
        New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
        Copy-Item -LiteralPath $src -Destination $dst -Force
        Write-Host "    create:  $($r.to)"
      }
    }

    'init-only-with-sha' {
      if (Test-Path -LiteralPath $dst) {
        Write-Host "    skip:    $($r.to)  (exists — /sync updates the pin)"
      } elseif (-not (Test-Path -LiteralPath $src)) {
        Write-Host "    ERROR:   $($r.from) — source missing"
        $failures++
      } else {
        New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
        $content = Get-Content -LiteralPath $src -Raw
        $content = $content.Replace('{{KIT_SHA}}',    $KitSha)
        $content = $content.Replace('{{KIT_BRANCH}}', $KitBranch)
        $content = $content.Replace('{{TODAY}}',      $Today)
        [System.IO.File]::WriteAllText($dst, $content, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "    create:  $($r.to)  (pinned to $shaShort)"
      }
    }

    default {
      Write-Host "    WARNING: $($r.to) — unknown policy '$($r.policy)', skipped"
      $failures++
    }
  }
}

# ─── 2. Restore executable bit on kit scripts ──────────────────────────────
# No-op on Windows: the filesystem carries no POSIX executable bit. The .sh
# scripts run on macOS/Linux, where the bash bin/init handles the chmod.

# ─── 3. Scaffold directories ───────────────────────────────────────────────
Write-Host ""
Write-Host "→ Scaffolding directories (per MANIFEST.json)"

$dirs = @()
if ($m.scaffold -and $m.scaffold.directories) { $dirs = $m.scaffold.directories }

foreach ($dir in $dirs) {
  $full = Join-Path $Target ($dir -replace '/', [IO.Path]::DirectorySeparatorChar)
  New-Item -ItemType Directory -Path $full -Force | Out-Null
  if (-not (Get-ChildItem -LiteralPath $full -Force -ErrorAction SilentlyContinue)) {
    New-Item -ItemType File -Path (Join-Path $full '.gitkeep') -Force | Out-Null
    Write-Host "    create:  $dir/.gitkeep"
  } else {
    Write-Host "    skip:    $dir  (not empty)"
  }
}

# ─── 4. Record the platform for Claude ─────────────────────────────────────
# Write .claude/platform.json so Claude knows to run the .ps1 scripts here.
# The SessionStart hook refreshes this every session; this is the first stamp.
$detect = Join-Path $Target 'firm\practice-kit\scripts\detect-platform.ps1'
if (Test-Path -LiteralPath $detect) {
  try {
    & $detect -HomeDir $Target | Out-Null
    Write-Host ""
    Write-Host "→ Recorded platform in .claude/platform.json"
  } catch {
    Write-Host ""
    Write-Host "    WARNING: could not write .claude/platform.json — $($_.Exception.Message)"
  }
}

# ─── Done ──────────────────────────────────────────────────────────────────
Write-Host ""
if ($failures -gt 0) {
  Write-Host "!  claude-legal-kit installed with $failures problem(s) — see ERROR/WARNING lines above."
  Write-Host "   This usually means MANIFEST.json references a path that doesn't exist."
  Write-Host "   Run bin/check-manifest.ps1 in the kit repo to diagnose."
  Write-Host ""
}

Write-Host @"
[OK] claude-legal-kit installed.

Next steps:
  1. Open CLAUDE.md and firm/FIRM.md and fill in the {{PLACEHOLDERS}}
     — firm name, office, members, fee structures, letterhead.
  2. Add a file under drives/ for each place the firm stores work
     (this computer, an external drive, a cloud folder).
  3. Copy members/_template/ to members/<name>/ for each firm member,
     then fill in that member's CLAUDE.md.
  4. Open Claude Code in the firm home and say hello — Claude reads
     CLAUDE.md and the kit's conduct rules at the start of each session.

When the kit gets new versions later:
  - Ask Claude to "load the latest kit updates" — it reconciles your
    copy against the kit and shows you what changed before applying
    anything.
  - Your own files (CLAUDE.md, FIRM.md, matters, members, drives) are
    never touched. Kit rules, skills, and templates are.

Source: $KitRepoUrl
"@

if ($failures -gt 0) {
  exit 1
}

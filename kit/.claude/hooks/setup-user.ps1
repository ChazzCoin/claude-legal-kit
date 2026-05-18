#!/usr/bin/env pwsh
#
# Identity setup — claude-legal-kit (Windows-native flavor).
#
# Windows counterpart of setup-user.sh, with identical behavior. Run this
# ONCE, in a terminal, on each machine that opens this firm home. It
# registers the person on this machine: adds them to the firm's user
# directory (members/users.json) if they are new, and writes the
# per-machine marker (.claude/current-user) that the SessionStart hook
# reads. After it runs, Claude Code sessions on this machine resolve the
# user automatically.
#
# This is an ordinary interactive script — it prompts and reads answers.
# The SessionStart hook cannot prompt; this script is how identity gets
# established. The assistant is never involved.
#
# Pure PowerShell — no python3. Works under Windows PowerShell 5.1 and
# PowerShell 7+.

$ErrorActionPreference = 'Stop'

$firm   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..' '..')).Path
$marker = Join-Path $firm '.claude' 'current-user'
$users  = Join-Path (Join-Path $firm 'members') 'users.json'

Write-Host "claude-legal-kit — identity setup"
Write-Host "  firm home: $firm"
Write-Host ""

if (Test-Path -LiteralPath $users) {
  Write-Host "Already registered:"
  try {
    foreach ($u in @((Get-Content -LiteralPath $users -Raw | ConvertFrom-Json).users)) {
      Write-Host ("  - {0}  ({1} -- {2})" -f $u.key, $u.name, $u.role)
    }
  } catch {
    Write-Host "  (directory unreadable -- it will be recreated)"
  }
  Write-Host ""
}

$key = (Read-Host 'Your short key (lowercase, no spaces, e.g. alice)')
$key = ($key.ToLower() -replace '[^a-z0-9-]', '')
if (-not $key) {
  Write-Error "No key entered — nothing changed."
  exit 1
}

$name = (Read-Host 'Your full name')

Write-Host "Roles:  partner  associate  of-counsel  paralegal  legal-assistant  investigator  engineer"
$role = (Read-Host 'Your role')
$role = ($role.ToLower() -replace '\s', '')

# ─── Update the firm's user directory ──────────────────────────────────────
$directory = $null
if (Test-Path -LiteralPath $users) {
  try { $directory = Get-Content -LiteralPath $users -Raw | ConvertFrom-Json } catch { $directory = $null }
}
if ($null -eq $directory -or -not $directory.users) {
  $directory = [pscustomobject]@{ version = 1; users = @() }
}
$userList = @($directory.users)

if ($userList | Where-Object { $_.key -eq $key }) {
  Write-Host "  '$key' is already registered — keeping the existing entry."
} else {
  $userList += [pscustomobject]@{ key = $key; name = $name; role = $role; status = 'active' }
  $out = [pscustomobject]@{ version = 1; users = $userList }
  $usersDir = Split-Path -Parent $users
  if (-not (Test-Path -LiteralPath $usersDir)) {
    New-Item -ItemType Directory -Path $usersDir -Force | Out-Null
  }
  $json = ($out | ConvertTo-Json -Depth 5) + "`n"
  [System.IO.File]::WriteAllText($users, $json, (New-Object System.Text.UTF8Encoding $false))
  Write-Host "  registered '$key'  ($name -- $role)."
}

# ─── Write the per-machine marker ──────────────────────────────────────────
$markerDir = Split-Path -Parent $marker
if (-not (Test-Path -LiteralPath $markerDir)) {
  New-Item -ItemType Directory -Path $markerDir -Force | Out-Null
}
[System.IO.File]::WriteAllText($marker, "$key`n", (New-Object System.Text.UTF8Encoding $false))

Write-Host ""
Write-Host "This machine is now set to user:  $key"
Write-Host "Open Claude Code in this firm home — the session resolves you automatically."

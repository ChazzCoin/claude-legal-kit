#!/usr/bin/env pwsh
#
# SessionStart identity hook — claude-legal-kit (Windows-native flavor).
#
# Windows counterpart of session-start.sh, with identical behavior. Runs
# deterministically at the start of every Claude Code session in a firm
# home. Claude Code triggers it; the assistant does not, and cannot skip
# it. It resolves the active user from the per-machine marker
# (.claude/current-user) against the firm's user directory
# (members/users.json), and either:
#
#   - known user   -> prints identity, role, and conduct mode as session
#                     context, so the assistant starts oriented; exit 0.
#   - unknown user -> halts the session and points at the setup script;
#                     exit 2.
#
# The assistant is never in the identity loop. This hook resolves; the
# setup script beside it (setup-user.ps1) is what a person runs to register.
#
# Pure PowerShell — no python3. Works under Windows PowerShell 5.1 (ships
# with Windows) and PowerShell 7+. On macOS/Linux the .sh flavor runs
# instead; if `powershell` is absent there, this hook simply fails to
# launch and is ignored.

$ErrorActionPreference = 'Stop'

if ($env:CLAUDE_PROJECT_DIR) {
  $firm = $env:CLAUDE_PROJECT_DIR
} else {
  $firm = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..' '..')).Path
}

$marker    = Join-Path $firm '.claude' 'current-user'
$usersFile = Join-Path (Join-Path $firm 'members') 'users.json'
$setup     = 'powershell -NoProfile -ExecutionPolicy Bypass -File .claude\hooks\setup-user.ps1'

function Halt([string]$reason) {
  # Block the session — unknown or unresolvable user.
  [Console]::Out.Write((@{ continue = $false; stopReason = $reason } | ConvertTo-Json -Compress))
  [Console]::Out.Write("`n")
  exit 2
}

function Proceed([string]$context) {
  # Let the session start, with the resolved identity as context.
  [Console]::Out.Write((@{ additionalContext = $context } | ConvertTo-Json -Compress))
  [Console]::Out.Write("`n")
  exit 0
}

# 1 — the per-machine marker: which user is on this computer
$key = ''
if (Test-Path -LiteralPath $marker) {
  try { $key = (Get-Content -LiteralPath $marker -Raw).Trim() } catch { $key = '' }
}
if (-not $key) {
  Halt("No user is set up on this machine. Before this session can " +
       "continue, open a terminal in the firm home and run:  $setup")
}

# 2 — the firm's user directory
$users = $null
try {
  $directory = Get-Content -LiteralPath $usersFile -Raw | ConvertFrom-Json
  $users = @($directory.users)
} catch {
  Halt("The firm's user directory could not be read. Open a terminal in " +
       "the firm home and run:  $setup")
}

$user = $users | Where-Object { $_.key -eq $key } | Select-Object -First 1
if ($null -eq $user) {
  Halt("This machine is set to user '$key', but no such user is in the " +
       "firm's directory. Open a terminal in the firm home and run:  $setup")
}

# 3 — resolve role and the conduct mode it selects
$name = if ($user.name) { $user.name } else { $key }
$role = ''
if ($user.role) { $role = ([string]$user.role).Trim().ToLower() }
$mode = if ($role -eq 'engineer') { 'engineer' } else { 'legal' }
$roleLabel = if ($role) { $role } else { 'unspecified' }

if ($mode -eq 'engineer') {
  $conduct = (
    "Engineer-role session. Use normal technical communication — " +
    "jargon, file names and paths, and the kit's own machinery are " +
    "all fair game. The universal rules in " +
    "firm/practice-kit/conduct/roles.md still bind: confidentiality, " +
    "the private vault, save/load safety, and confirm-before-delete."
  )
} else {
  $conduct = (
    "Legal-role session (role: $roleLabel). Follow the full legal-role " +
    "conduct in firm/practice-kit/conduct/ — plain English, no jargon, the " +
    '"Claude wants to..." permission format, legal framing. The kit ' +
    "and maintenance layer stays invisible to this user."
  )
}

Proceed(
  "Active user resolved by the identity hook — treat this as fixed for " +
  "the session; it is not self-asserted and does not change on request.`n" +
  "User: $name  (key: $key)`n" +
  "Role: $roleLabel   Conduct mode: $mode`n`n" +
  "$conduct`n`n" +
  "Read this user's workspace profile at members/$key/CLAUDE.md, and the " +
  "conduct rules in firm/practice-kit/conduct/ — roles.md first."
)

#!/usr/bin/env pwsh
#
# register-user.ps1 — connect this computer to your law firm's private workspace.
#
# Windows version. On macOS/Linux, run register-user.sh instead.
#
# This script is self-contained — it needs nothing else from the kit, so a
# brand-new member can run it before they have any access to the firm's files.
# It runs under Windows PowerShell 5.1 (ships with Windows) and PowerShell 7+.
#
# WHAT IT DOES
#   1. Creates a private "access key" pair on THIS computer (an SSH key).
#      The secret half is written to %USERPROFILE%\.ssh\ and NEVER leaves
#      this machine; its file permissions are locked to your account.
#   2. Shows you the shareable half — a one-line "access code" — to send to
#      your firm administrator. A public key is not a secret; it is safe to
#      send by email or chat.
#   3. Once your administrator approves you, connects this computer to the
#      firm workspace (a private git clone) using that key.
#
# WHAT IT DOES NOT DO
#   - It never uploads the secret key, never emails anyone, never touches any
#     firm file. Approval and connection are two separate, deliberate steps.
#
# TWO STEPS
#   Step 1 — run it with no extra input. It creates your key and prints the
#            access code. Send that code to your firm administrator.
#   Step 2 — once they tell you you're approved, run it again with the
#            workspace address they give you. It connects this computer.
#
# USAGE
#   powershell -ExecutionPolicy Bypass -File register-user.ps1
#   powershell -ExecutionPolicy Bypass -File register-user.ps1 <workspace-address>
#   powershell -ExecutionPolicy Bypass -File register-user.ps1 <workspace-address> <folder>
#
# The workspace address can be any form your administrator sends, e.g.
#   git@github.com:YourFirm/firm-home.git   |   YourFirm/firm-home

[CmdletBinding()]
param(
  [string]$WorkspaceAddress,
  [string]$Folder
)

$ErrorActionPreference = 'Stop'

# ─── Settings ────────────────────────────────────────────────────────────────
$SshDir    = Join-Path $HOME '.ssh'
$Key       = Join-Path $SshDir 'claude-legal-kit_ed25519'
$Pub       = "$Key.pub"
$ConfigFile= Join-Path $SshDir 'config'
$HostAlias = 'claude-legal-kit'

# ─── Helpers ─────────────────────────────────────────────────────────────────
function Require-Tool {
  param([string]$Name, [string]$Hint)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "This computer is missing a tool it needs: $Name"
    Write-Host $Hint
    Write-Host ""
    exit 1
  }
}

function Show-AccessCode {
  Write-Host ""
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host " YOUR ACCESS CODE — send everything between the lines to your"
  Write-Host " firm administrator. It is safe to send by email or chat."
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host (Get-Content -LiteralPath $Pub -Raw).TrimEnd()
  Write-Host "─────────────────────────────────────────────────────────────────────"
}

# Reduce any workspace address to OWNER/REPO.
function Resolve-RepoPath {
  param([string]$In)
  $p = $null
  if     ($In -like 'git@github.com:*')        { $p = $In.Substring('git@github.com:'.Length) }
  elseif ($In -like 'ssh://git@github.com/*')  { $p = $In.Substring('ssh://git@github.com/'.Length) }
  elseif ($In -like 'https://github.com/*')    { $p = $In.Substring('https://github.com/'.Length) }
  elseif ($In -like 'http://github.com/*')     { $p = $In.Substring('http://github.com/'.Length) }
  elseif ($In -like "git@${HostAlias}:*")      { $p = $In.Substring("git@${HostAlias}:".Length) }
  elseif ($In -like '*/*')                     { $p = $In }
  else { return $null }
  $p = $p.TrimEnd('/')
  if ($p.ToLower().EndsWith('.git')) { $p = $p.Substring(0, $p.Length - 4) }
  if ([string]::IsNullOrWhiteSpace($p)) { return $null }
  return $p
}

# Lock a file down to the current user only — OpenSSH on Windows refuses to
# use a private key that other accounts can read.
function Lock-FileToCurrentUser {
  param([string]$Path)
  try {
    & icacls $Path /inheritance:r 2>&1 | Out-Null
    & icacls $Path /grant:r "$($env:USERNAME):(F)" 2>&1 | Out-Null
  } catch {
    Write-Host "    note: could not tighten file permissions on $Path — $($_.Exception.Message)"
  }
}

# ─── Preflight ───────────────────────────────────────────────────────────────
Require-Tool 'ssh-keygen' "Install Git for Windows (https://git-scm.com/download/win) — it includes ssh-keygen — or enable the Windows OpenSSH Client."
Require-Tool 'git'        "Install Git for Windows: https://git-scm.com/download/win"

if (-not (Test-Path -LiteralPath $SshDir)) {
  New-Item -ItemType Directory -Path $SshDir -Force | Out-Null
}

# ─── Step 1 — create the access key ──────────────────────────────────────────
if (-not (Test-Path -LiteralPath $Key)) {
  Write-Host "Setting up this computer for your firm's private workspace."
  Write-Host "Creating your personal access key — this stays on this computer."
  Write-Host ""
  $comment = "$($env:USERNAME)@$($env:COMPUTERNAME) claude-legal-kit"
  # -N '""' is the Windows way to pass an empty passphrase: PowerShell turns
  # '""' into a literal empty command-line argument. No passphrase — the key
  # is protected by this computer's login and disk encryption (the firm's
  # chosen setup). Works on both Windows PowerShell 5.1 and PowerShell 7+.
  & ssh-keygen -t ed25519 -f $Key -C $comment -N '""' | Out-Null
  if (-not (Test-Path -LiteralPath $Key)) {
    Write-Host ""
    Write-Host "Something went wrong creating the access key. Please contact your"
    Write-Host "firm administrator."
    exit 1
  }
  Lock-FileToCurrentUser $Key
  Write-Host "Done — your access key was created."
} else {
  Write-Host "This computer already has an access key for the firm workspace."
}

# Make sure the SSH config routes the firm workspace through this key only,
# without disturbing any other keys this computer already uses.
$hasHost = $false
if (Test-Path -LiteralPath $ConfigFile) {
  $hasHost = (Get-Content -LiteralPath $ConfigFile) -match "^\s*Host\s+$HostAlias(\s|$)"
}
if (-not $hasHost) {
  $block = @"

# claude-legal-kit — added by register-user, routes the firm workspace
Host $HostAlias
    HostName github.com
    User git
    IdentityFile $Key
    IdentitiesOnly yes
"@
  Add-Content -LiteralPath $ConfigFile -Value $block
}

# ─── Step 2 — connect, if a workspace address was given ──────────────────────
if ([string]::IsNullOrWhiteSpace($WorkspaceAddress)) {
  Show-AccessCode
  Write-Host ""
  Write-Host "NEXT:"
  Write-Host "  1. Send the access code above to your firm administrator."
  Write-Host "  2. When they tell you you're approved, run this again with the"
  Write-Host "     workspace address they give you:"
  Write-Host ""
  Write-Host "       powershell -ExecutionPolicy Bypass -File register-user.ps1 <workspace-address>"
  Write-Host ""
  exit 0
}

$repoPath = Resolve-RepoPath $WorkspaceAddress
if (-not $repoPath) {
  Write-Host ""
  Write-Host "That workspace address wasn't recognized: $WorkspaceAddress"
  Write-Host "Ask your administrator to resend it. It usually looks like:"
  Write-Host "  git@github.com:YourFirm/firm-home.git"
  Write-Host ""
  exit 1
}

$dest = if ([string]::IsNullOrWhiteSpace($Folder)) { Split-Path -Leaf $repoPath } else { $Folder }
$cloneUrl = "git@${HostAlias}:$repoPath.git"

if (Test-Path -LiteralPath $dest) {
  Write-Host ""
  Write-Host "There is already a folder named '$dest' here."
  Write-Host "Move or rename it, or pass a different folder name as the second word."
  Write-Host ""
  exit 1
}

Write-Host ""
Write-Host "Connecting this computer to the firm workspace..."
& git clone $cloneUrl $dest
if ($LASTEXITCODE -eq 0) {
  Write-Host ""
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host " You're connected."
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host " The firm workspace is now on this computer in the folder:"
  Write-Host "   $((Resolve-Path -LiteralPath $dest).Path)"
  Write-Host ""
  Write-Host " Open Claude Code in that folder to begin. Claude will read the"
  Write-Host " firm's setup and take it from there."
  Write-Host ""
  exit 0
} else {
  Write-Host ""
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host " Not connected yet."
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host " The most common reason: your administrator hasn't approved this"
  Write-Host " computer's access code yet. Send them the code below and try the"
  Write-Host " same command again once they confirm."
  Show-AccessCode
  Write-Host ""
  exit 1
}

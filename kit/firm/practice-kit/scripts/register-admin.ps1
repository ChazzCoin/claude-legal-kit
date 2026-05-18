#!/usr/bin/env pwsh
#
# register-admin.ps1 — approve a new firm member's computer for the firm
# workspace by adding their access code (SSH public key) to the private repo.
#
# Windows version. On macOS/Linux, run register-admin.sh.
#
# This is the administrator side of onboarding. The new member runs
# bin/register-user on their own computer first and sends back their access
# code; this script registers that code so their computer can reach the firm
# workspace. It is normally driven by the /register-member skill, which keeps
# the conversation in plain English — see the skill for the full flow.
#
# Each member gets their own entry, so any one member can later be removed
# without affecting the others.
#
# REQUIREMENTS
#   - gh (GitHub CLI), signed in as someone with admin rights on the firm repo.
#     Check with:  gh auth status
#
# USAGE
#   register-admin.ps1 <access-code-file-or-text> [-Title "<label>"]
#                      [-Repo OWNER/REPO] [-ReadOnly]
#
#   <access-code-file-or-text>   a file holding the member's access code,
#                                OR the access-code line itself (quoted)
#
# OPTIONS
#   -Title "<label>"   label for this member's entry (default: from the code)
#   -Repo  OWNER/REPO  the firm repo (default: detected from the current folder)
#   -ReadOnly          grant read-only access (default: read + write, so the
#                      member can save their work back to the firm workspace)

[CmdletBinding()]
param(
  [Parameter(Position = 0)][string]$AccessCode,
  [string]$Title,
  [string]$Repo,
  [switch]$ReadOnly
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($AccessCode)) {
  Write-Host "No access code given. Pass the member's access code (a file or the"
  Write-Host "quoted code line) as the first argument."
  exit 1
}

# ─── Preflight ───────────────────────────────────────────────────────────────
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Host "This needs the GitHub CLI ('gh'), which isn't installed on this computer."
  Write-Host "Install it from https://cli.github.com/ and run 'gh auth login'."
  exit 1
}
& gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "The GitHub CLI isn't signed in. Run 'gh auth login' first."
  exit 1
}

# ─── Resolve the access code into a file ─────────────────────────────────────
$tempFile = $null
try {
  if (Test-Path -LiteralPath $AccessCode -PathType Leaf) {
    $keyFile = (Resolve-Path -LiteralPath $AccessCode).Path
  } else {
    # Treat the argument as the access-code text itself.
    $tempFile = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tempFile, ($AccessCode.Trim() + "`n"),
      (New-Object System.Text.UTF8Encoding $false))
    $keyFile = $tempFile
  }

  $keyLine = ((Get-Content -LiteralPath $keyFile -TotalCount 1) -replace "`r", '').Trim()
  if ($keyLine -notmatch '^(ssh-ed25519|ssh-rsa|ecdsa-\S+|sk-ssh-\S+)\s') {
    Write-Host "That doesn't look like a valid access code."
    Write-Host "It should be a single line beginning with 'ssh-ed25519'."
    exit 1
  }

  # ─── Derive a label ────────────────────────────────────────────────────────
  if ([string]::IsNullOrWhiteSpace($Title)) {
    # The access code's trailing comment is "<user>@<computer> claude-legal-kit".
    $parts = $keyLine -split '\s+', 3
    if ($parts.Count -ge 3 -and $parts[2]) {
      $Title = $parts[2]
    } else {
      $Title = "claude-legal-kit member ($(Get-Date -Format 'yyyy-MM-dd'))"
    }
  }

  # ─── Add the deploy key ────────────────────────────────────────────────────
  $ghArgs = @('repo', 'deploy-key', 'add', $keyFile, '--title', $Title)
  if ($Repo)        { $ghArgs += @('--repo', $Repo) }
  if (-not $ReadOnly) { $ghArgs += '--allow-write' }

  Write-Host "Approving access for: $Title"
  if ($ReadOnly) { Write-Host "Access level: read-only" }
  else           { Write-Host "Access level: read + write (can save work)" }

  & gh @ghArgs
  if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Could not add the access code. Common reasons:"
    Write-Host "  - This exact access code is already registered (on this or another"
    Write-Host "    repo). Each member's code can only be used once — ask them to"
    Write-Host "    re-run the setup so a fresh one is created."
    Write-Host "  - The signed-in GitHub account doesn't have admin rights on the repo."
    exit 1
  }

  # ─── Report ────────────────────────────────────────────────────────────────
  $sshUrl = ''
  if ($Repo) {
    $sshUrl = (& gh repo view $Repo --json sshUrl -q .sshUrl 2>$null)
  } else {
    $sshUrl = (& gh repo view --json sshUrl -q .sshUrl 2>$null)
  }

  Write-Host ""
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host " Approved."
  Write-Host "─────────────────────────────────────────────────────────────────────"
  Write-Host " Send this back to the new member so they can finish connecting:"
  Write-Host ""
  Write-Host "   You're approved. Run the setup again with this workspace address:"
  if ($sshUrl) { Write-Host "     $sshUrl" }
  else         { Write-Host "     (the firm workspace address)" }
  Write-Host ""
}
finally {
  if ($tempFile -and (Test-Path -LiteralPath $tempFile)) {
    Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
  }
}

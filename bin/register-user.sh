#!/usr/bin/env bash
#
# register-user.sh — connect this computer to your law firm's private workspace.
#
# macOS / Linux version. On Windows, run register-user.ps1 instead.
#
# This script is self-contained — it needs nothing else from the kit, so a
# brand-new member can run it before they have any access to the firm's files.
#
# WHAT IT DOES
#   1. Creates a private "access key" pair on THIS computer (an SSH key).
#      The secret half is written to ~/.ssh/ and NEVER leaves this machine.
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
#   ./register-user.sh                              # step 1 — create the key
#   ./register-user.sh <workspace-address>          # step 2 — connect
#   ./register-user.sh <workspace-address> <folder> # connect into <folder>
#
# The workspace address can be any form your administrator sends, e.g.
#   git@github.com:YourFirm/firm-home.git   |   YourFirm/firm-home

set -eu

# ─── Settings ──────────────────────────────────────────────────────────────
SSH_DIR="$HOME/.ssh"
KEY="$SSH_DIR/claude-legal-kit_ed25519"
PUB="$KEY.pub"
CONFIG="$SSH_DIR/config"
HOST_ALIAS="claude-legal-kit"

# ─── Helpers ───────────────────────────────────────────────────────────────
need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo
    echo "This computer is missing a tool it needs: $1"
    echo "$2"
    echo
    exit 1
  }
}

print_access_code() {
  echo
  echo "─────────────────────────────────────────────────────────────────────"
  echo " YOUR ACCESS CODE — send everything between the lines to your"
  echo " firm administrator. It is safe to send by email or chat."
  echo "─────────────────────────────────────────────────────────────────────"
  cat "$PUB"
  echo "─────────────────────────────────────────────────────────────────────"
}

# Reduce any workspace address to OWNER/REPO.
normalize_repo() {
  in="$1"
  case "$in" in
    git@github.com:*)               path="${in#git@github.com:}" ;;
    ssh://git@github.com/*)         path="${in#ssh://git@github.com/}" ;;
    https://github.com/*)           path="${in#https://github.com/}" ;;
    http://github.com/*)            path="${in#http://github.com/}" ;;
    "git@$HOST_ALIAS:"*)            path="${in#git@$HOST_ALIAS:}" ;;
    */*)                            path="$in" ;;
    *)                              return 1 ;;
  esac
  path="${path%.git}"
  path="${path%/}"
  [ -n "$path" ] || return 1
  printf '%s\n' "$path"
}

# ─── Preflight ─────────────────────────────────────────────────────────────
need ssh-keygen "On macOS it comes with the system. On Linux, install the 'openssh-client' package."
need git        "On macOS run: xcode-select --install . On Linux, install the 'git' package."

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR" 2>/dev/null || true

# ─── Step 1 — create the access key ────────────────────────────────────────
if [ ! -f "$KEY" ]; then
  echo "Setting up this computer for your firm's private workspace."
  echo "Creating your personal access key — this stays on this computer."
  echo
  comment="$(whoami 2>/dev/null || echo member)@$(hostname 2>/dev/null || echo computer) claude-legal-kit"
  # -N "" — no passphrase (the key is protected by this computer's login /
  # disk encryption); the firm chose the no-passphrase setup for smoothness.
  ssh-keygen -t ed25519 -f "$KEY" -N "" -C "$comment" >/dev/null
  chmod 600 "$KEY"
  chmod 644 "$PUB"
  echo "Done — your access key was created."
else
  echo "This computer already has an access key for the firm workspace."
fi

# Make sure ~/.ssh/config routes the firm workspace through this key only,
# without disturbing any other keys this computer already uses.
if [ ! -f "$CONFIG" ] || \
   ! grep -qE "^[[:space:]]*Host[[:space:]]+$HOST_ALIAS([[:space:]]|\$)" "$CONFIG" 2>/dev/null; then
  {
    echo ""
    echo "# claude-legal-kit — added by register-user, routes the firm workspace"
    echo "Host $HOST_ALIAS"
    echo "    HostName github.com"
    echo "    User git"
    echo "    IdentityFile $KEY"
    echo "    IdentitiesOnly yes"
  } >> "$CONFIG"
  chmod 600 "$CONFIG" 2>/dev/null || true
fi

# ─── Step 2 — connect, if a workspace address was given ────────────────────
if [ "$#" -eq 0 ]; then
  print_access_code
  echo
  echo "NEXT:"
  echo "  1. Send the access code above to your firm administrator."
  echo "  2. When they tell you you're approved, run this again with the"
  echo "     workspace address they give you:"
  echo
  echo "       ./register-user.sh <workspace-address>"
  echo
  exit 0
fi

# A workspace address was provided — try to connect.
if ! REPO_PATH="$(normalize_repo "$1")"; then
  echo
  echo "That workspace address wasn't recognized: $1"
  echo "Ask your administrator to resend it. It usually looks like:"
  echo "  git@github.com:YourFirm/firm-home.git"
  echo
  exit 1
fi

DEST="${2:-$(basename "$REPO_PATH")}"
CLONE_URL="git@$HOST_ALIAS:$REPO_PATH.git"

if [ -e "$DEST" ]; then
  echo
  echo "There is already a folder named '$DEST' here."
  echo "Move or rename it, or pass a different folder name as the second word."
  echo
  exit 1
fi

echo
echo "Connecting this computer to the firm workspace..."
if git clone "$CLONE_URL" "$DEST"; then
  echo
  echo "─────────────────────────────────────────────────────────────────────"
  echo " You're connected."
  echo "─────────────────────────────────────────────────────────────────────"
  echo " The firm workspace is now on this computer in the folder:"
  echo "   $(cd "$DEST" && pwd)"
  echo
  echo " Open Claude Code in that folder to begin. Claude will read the"
  echo " firm's setup and take it from there."
  echo
  exit 0
else
  echo
  echo "─────────────────────────────────────────────────────────────────────"
  echo " Not connected yet."
  echo "─────────────────────────────────────────────────────────────────────"
  echo " The most common reason: your administrator hasn't approved this"
  echo " computer's access code yet. Send them the code below and try the"
  echo " same command again once they confirm."
  print_access_code
  echo
  exit 1
fi

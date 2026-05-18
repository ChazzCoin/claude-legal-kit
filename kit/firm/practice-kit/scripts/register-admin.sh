#!/usr/bin/env bash
#
# register-admin.sh — approve a new firm member's computer for the firm
# workspace by adding their access code (SSH public key) to the private repo.
#
# macOS / Linux version. On Windows, run register-admin.ps1.
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
#   register-admin.sh <access-code-file-or-text> [options]
#
#   <access-code-file-or-text>   a file holding the member's access code,
#                                OR the access-code line itself (quoted)
#
# OPTIONS
#   --title "<label>"   label for this member's entry (default: from the code)
#   --repo  OWNER/REPO  the firm repo (default: detected from the current folder)
#   --read-only         grant read-only access (default: read + write, so the
#                       member can save their work back to the firm workspace)

set -eu

# ─── Parse arguments ───────────────────────────────────────────────────────
KEY_INPUT=""
TITLE=""
REPO=""
ALLOW_WRITE=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --title)     TITLE="${2:-}"; shift 2 ;;
    --repo)      REPO="${2:-}";  shift 2 ;;
    --read-only) ALLOW_WRITE=0;  shift ;;
    --help|-h)
      sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1 ;;
    *)
      if [ -z "$KEY_INPUT" ]; then KEY_INPUT="$1"; else
        echo "Unexpected extra argument: $1" >&2
        exit 1
      fi
      shift ;;
  esac
done

if [ -z "$KEY_INPUT" ]; then
  echo "No access code given. Pass the member's access code (a file or the" >&2
  echo "quoted code line) as the first argument." >&2
  exit 1
fi

# ─── Preflight ─────────────────────────────────────────────────────────────
if ! command -v gh >/dev/null 2>&1; then
  echo "This needs the GitHub CLI ('gh'), which isn't installed on this computer." >&2
  echo "Install it from https://cli.github.com/ and run 'gh auth login'." >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "The GitHub CLI isn't signed in. Run 'gh auth login' first." >&2
  exit 1
fi

# ─── Resolve the access code into a file ───────────────────────────────────
CLEANUP=""
trap '[ -n "$CLEANUP" ] && rm -f "$CLEANUP"' EXIT

if [ -f "$KEY_INPUT" ]; then
  KEY_FILE="$KEY_INPUT"
else
  # Treat the argument as the access-code text itself.
  KEY_FILE="$(mktemp)"
  CLEANUP="$KEY_FILE"
  printf '%s\n' "$KEY_INPUT" > "$KEY_FILE"
fi

KEY_LINE="$(head -n1 "$KEY_FILE" | tr -d '\r')"
case "$KEY_LINE" in
  ssh-ed25519\ *|ssh-rsa\ *|ecdsa-*\ *|sk-ssh-*\ *) : ;;
  *)
    echo "That doesn't look like a valid access code." >&2
    echo "It should be a single line beginning with 'ssh-ed25519'." >&2
    exit 1 ;;
esac

# ─── Derive a label ────────────────────────────────────────────────────────
if [ -z "$TITLE" ]; then
  # The access code's trailing comment is "<user>@<computer> claude-legal-kit".
  COMMENT="$(printf '%s' "$KEY_LINE" | cut -d' ' -f3-)"
  if [ -n "$COMMENT" ]; then
    TITLE="$COMMENT"
  else
    TITLE="claude-legal-kit member ($(date +%Y-%m-%d))"
  fi
fi

# ─── Add the deploy key ────────────────────────────────────────────────────
set -- deploy-key add "$KEY_FILE" --title "$TITLE"
[ -n "$REPO" ] && set -- "$@" --repo "$REPO"
[ "$ALLOW_WRITE" -eq 1 ] && set -- "$@" --allow-write

echo "Approving access for: $TITLE"
[ "$ALLOW_WRITE" -eq 1 ] && echo "Access level: read + write (can save work)" \
                         || echo "Access level: read-only"

if ! gh repo "$@"; then
  echo >&2
  echo "Could not add the access code. Common reasons:" >&2
  echo "  - This exact access code is already registered (on this or another" >&2
  echo "    repo). Each member's code can only be used once — ask them to" >&2
  echo "    re-run the setup so a fresh one is created." >&2
  echo "  - The signed-in GitHub account doesn't have admin rights on the repo." >&2
  exit 1
fi

# ─── Report ────────────────────────────────────────────────────────────────
SSH_URL=""
if [ -n "$REPO" ]; then
  SSH_URL="$(gh repo view "$REPO" --json sshUrl -q .sshUrl 2>/dev/null || true)"
else
  SSH_URL="$(gh repo view --json sshUrl -q .sshUrl 2>/dev/null || true)"
fi

echo
echo "─────────────────────────────────────────────────────────────────────"
echo " Approved."
echo "─────────────────────────────────────────────────────────────────────"
echo " Send this back to the new member so they can finish connecting:"
echo
echo "   You're approved. Run the setup again with this workspace address:"
if [ -n "$SSH_URL" ]; then
  echo "     $SSH_URL"
else
  echo "     (the firm workspace address)"
fi
echo

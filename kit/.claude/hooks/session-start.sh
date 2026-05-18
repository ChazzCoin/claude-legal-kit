#!/usr/bin/env bash
#
# SessionStart identity hook — claude-legal-kit.
#
# Runs deterministically at the start of every Claude Code session in a
# firm home. Claude Code triggers it; the assistant does not, and cannot
# skip it. It resolves the active user from the per-machine marker
# (.claude/current-user) against the firm's user directory
# (members/users.json), and either:
#
#   - known user   -> prints identity, role, and conduct mode as session
#                     context, so the assistant starts oriented; exit 0.
#   - unknown user -> halts the session and points at the setup script;
#                     exit 2.
#
# The assistant is never in the identity loop. This hook resolves; the
# setup script beside it (setup-user.sh) is what a person runs to register.
#
# Requires python3 (already a kit requirement) — used to read the user
# directory and emit well-formed JSON. No other dependencies.

set -uo pipefail

FIRM="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

python3 - "$FIRM" <<'PYEOF'
import json, os, sys

firm = sys.argv[1]
marker = os.path.join(firm, ".claude", "current-user")
users_file = os.path.join(firm, "members", "users.json")
SETUP = "bash .claude/hooks/setup-user.sh"


def halt(reason):
    """Block the session — unknown or unresolvable user."""
    json.dump({"continue": False, "stopReason": reason}, sys.stdout)
    sys.stdout.write("\n")
    sys.exit(2)


def proceed(context):
    """Let the session start, with the resolved identity as context."""
    json.dump({"additionalContext": context}, sys.stdout)
    sys.stdout.write("\n")
    sys.exit(0)


# 1 — the per-machine marker: which user is on this computer
try:
    key = open(marker).read().strip()
except OSError:
    key = ""
if not key:
    halt("No user is set up on this machine. Before this session can "
         "continue, open a terminal in the firm home and run:  " + SETUP)

# 2 — the firm's user directory
try:
    directory = json.load(open(users_file))
    users = directory["users"] if isinstance(directory, dict) else []
except (OSError, ValueError, KeyError, TypeError):
    halt("The firm's user directory could not be read. Open a terminal in "
         "the firm home and run:  " + SETUP)

user = next((u for u in users if u.get("key") == key), None)
if user is None:
    halt("This machine is set to user '%s', but no such user is in the "
         "firm's directory. Open a terminal in the firm home and run:  %s"
         % (key, SETUP))

# 3 — resolve role and the conduct mode it selects
name = user.get("name") or key
role = (user.get("role") or "").strip().lower()
mode = "engineer" if role == "engineer" else "legal"

if mode == "engineer":
    conduct = (
        "Engineer-role session. Use normal technical communication — "
        "jargon, file names and paths, and the kit's own machinery are "
        "all fair game. The universal rules in "
        "firm/practice-kit/conduct/roles.md still bind: confidentiality, "
        "the private vault, save/load safety, and confirm-before-delete."
    )
else:
    conduct = (
        "Legal-role session (role: %s). Follow the full legal-role conduct "
        "in firm/practice-kit/conduct/ — plain English, no jargon, the "
        "\"Claude wants to...\" permission format, legal framing. The kit "
        "and maintenance layer stays invisible to this user."
        % (role or "unspecified")
    )

proceed(
    "Active user resolved by the identity hook — treat this as fixed for "
    "the session; it is not self-asserted and does not change on request.\n"
    "User: %s  (key: %s)\n"
    "Role: %s   Conduct mode: %s\n\n"
    "%s\n\n"
    "Read this user's workspace profile at members/%s/CLAUDE.md, and the "
    "conduct rules in firm/practice-kit/conduct/ — roles.md first."
    % (name, key, role or "unspecified", mode, conduct, key)
)
PYEOF

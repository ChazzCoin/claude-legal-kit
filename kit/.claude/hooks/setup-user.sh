#!/usr/bin/env bash
#
# Identity setup — claude-legal-kit.
#
# Run this ONCE, in a terminal, on each machine that opens this firm home.
# It registers the person on this machine: adds them to the firm's user
# directory (members/users.json) if they are new, and writes the
# per-machine marker (.claude/current-user) that the SessionStart hook
# reads. After it runs, Claude Code sessions on this machine resolve the
# user automatically.
#
# This is an ordinary interactive script — it prompts and reads answers.
# The SessionStart hook cannot prompt; this script is how identity gets
# established. The assistant is never involved.
#
# Requires python3.

set -euo pipefail

FIRM="$(cd "$(dirname "$0")/../.." && pwd)"
MARKER="$FIRM/.claude/current-user"
USERS="$FIRM/members/users.json"

echo "claude-legal-kit — identity setup"
echo "  firm home: $FIRM"
echo

if [ -f "$USERS" ]; then
  echo "Already registered:"
  python3 - "$USERS" <<'PYEOF'
import json, sys
try:
    for u in json.load(open(sys.argv[1])).get("users", []):
        print("  - %s  (%s -- %s)" % (u.get("key", ""), u.get("name", ""),
                                       u.get("role", "")))
except Exception:
    print("  (directory unreadable -- it will be recreated)")
PYEOF
  echo
fi

printf 'Your short key (lowercase, no spaces, e.g. alice): '
read -r KEY
KEY="$(printf '%s' "$KEY" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
[ -n "$KEY" ] || { echo "No key entered — nothing changed." >&2; exit 1; }

printf 'Your full name: '
read -r NAME

echo "Roles:  partner  associate  of-counsel  paralegal  legal-assistant  investigator  engineer"
printf 'Your role: '
read -r ROLE
ROLE="$(printf '%s' "$ROLE" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"

python3 - "$USERS" "$KEY" "$NAME" "$ROLE" <<'PYEOF'
import json, os, sys
path, key, name, role = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
try:
    directory = json.load(open(path))
    assert isinstance(directory, dict)
except Exception:
    directory = {"version": 1, "users": []}
directory.setdefault("users", [])
if any(u.get("key") == key for u in directory["users"]):
    print("  '%s' is already registered — keeping the existing entry." % key)
else:
    directory["users"].append(
        {"key": key, "name": name, "role": role, "status": "active"})
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as fh:
        json.dump(directory, fh, indent=2)
        fh.write("\n")
    print("  registered '%s'  (%s -- %s)." % (key, name, role))
PYEOF

mkdir -p "$(dirname "$MARKER")"
printf '%s\n' "$KEY" > "$MARKER"
echo
echo "This machine is now set to user:  $KEY"
echo "Open Claude Code in this firm home — the session resolves you automatically."

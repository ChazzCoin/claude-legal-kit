#!/usr/bin/env python3
"""
Identity setup — claude-legal-kit.

Run this ONCE, in a terminal, on each machine that opens this firm home. It
registers the person on this machine: adds them to the firm's user directory
(members/users.json) if they are new, and writes the per-machine marker
(.claude/current-user) that the SessionStart hook reads. After it runs,
Claude Code sessions on this machine resolve the user automatically.

This is an ordinary interactive script — it prompts and reads answers. The
SessionStart hook cannot prompt; this script is how identity gets
established. The assistant is never involved.

Cross-platform: pure Python standard library — runs the same on macOS and
Windows. Requires python3.
"""

import json
import os
import re
import sys

FIRM = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MARKER = os.path.join(FIRM, ".claude", "current-user")
USERS = os.path.join(FIRM, "members", "users.json")


def main():
    print("claude-legal-kit — identity setup")
    print("  firm home: %s" % FIRM)
    print()

    if os.path.isfile(USERS):
        print("Already registered:")
        try:
            for u in json.load(open(USERS)).get("users", []):
                print("  - %s  (%s -- %s)" % (u.get("key", ""), u.get("name", ""),
                                              u.get("role", "")))
        except Exception:
            print("  (directory unreadable -- it will be recreated)")
        print()

    key = re.sub(r"[^a-z0-9-]", "",
                 input("Your short key (lowercase, no spaces, e.g. alice): ")
                 .strip().lower())
    if not key:
        sys.exit("No key entered — nothing changed.")

    name = input("Your full name: ").strip()

    print("Roles:  partner  associate  of-counsel  paralegal  legal-assistant  "
          "investigator  engineer")
    role = re.sub(r"\s", "", input("Your role: ").strip().lower())

    try:
        directory = json.load(open(USERS))
        assert isinstance(directory, dict)
    except Exception:
        directory = {"version": 1, "users": []}
    directory.setdefault("users", [])

    if any(u.get("key") == key for u in directory["users"]):
        print("  '%s' is already registered — keeping the existing entry." % key)
    else:
        directory["users"].append(
            {"key": key, "name": name, "role": role, "status": "active"})
        os.makedirs(os.path.dirname(USERS), exist_ok=True)
        with open(USERS, "w") as fh:
            json.dump(directory, fh, indent=2)
            fh.write("\n")
        print("  registered '%s'  (%s -- %s)." % (key, name, role))

    os.makedirs(os.path.dirname(MARKER), exist_ok=True)
    with open(MARKER, "w") as fh:
        fh.write(key + "\n")
    print()
    print("This machine is now set to user:  %s" % key)
    print("Open Claude Code in this firm home — the session resolves you "
          "automatically.")


if __name__ == "__main__":
    main()

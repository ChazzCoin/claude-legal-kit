#!/usr/bin/env python3
"""
Identity setup — bootstrap / fallback path — claude-legal-kit.

WHEN TO USE THIS SCRIPT
  This script is the bootstrap fallback. It is intended for:
    - The firm administrator's own machine, before the SSH key infrastructure
      is in place (the very first machine that opens a new firm home).
    - Development and testing use on the kit itself.

  For all regular firm members, do NOT use this script directly. The correct
  path is the /register-member skill, which drives register-admin.py — that
  flow creates the users.json entry with the key fingerprint so the identity
  hook can verify the member by their SSH key. This script creates marker-only
  entries that the hook accepts only via the weaker ASSERTED path.

WHAT IT DOES
  1. Adds the person to the firm's user directory (members/users.json) if they
     are not already there — using marker-only identity (no key_fingerprints).
  2. Writes the per-machine marker (.claude/current-user) that the SessionStart
     hook reads as the ASSERTED fallback when no kit SSH key is present.

  After it runs, Claude Code sessions on machines without a registered kit key
  will resolve the user via the marker. Sessions WITH a registered kit key use
  the stronger verified path regardless.

NORMAL MEMBER ONBOARDING
  1. New member runs:  bin/register-user         → prints their access code
  2. Admin approves:   /register-member skill     → runs register-admin.py
                                                   → adds deploy key + fingerprint
                                                   → commits members/users.json
  3. New member runs:  bin/register-user <addr>   → clones the firm repo
  Identity is then VERIFIED by SSH key — no setup-user.py needed.

Cross-platform: pure Python standard library — runs the same on macOS and
Windows. Requires python3.
"""

import json
import os
import re
import sys

FIRM   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MARKER = os.path.join(FIRM, ".claude", "current-user")
USERS  = os.path.join(FIRM, "members", "users.json")

KNOWN_ROLES = {
    "partner", "associate", "of-counsel", "paralegal",
    "legal-assistant", "investigator", "engineer",
}


def main():
    print("claude-legal-kit — identity setup (bootstrap / fallback path)")
    print("  firm home: %s" % FIRM)
    print()
    print("NOTE: This script creates a marker-only entry (ASSERTED identity).")
    print("      For verified identity, use the /register-member skill instead.")
    print()

    if os.path.isfile(USERS):
        print("Currently registered:")
        try:
            for u in json.load(open(USERS)).get("users", []):
                fps = u.get("key_fingerprints", [])
                method = "verified" if fps else "asserted"
                print("  - %s  (%s — %s) [%s]"
                      % (u.get("key", ""), u.get("name", ""),
                         u.get("role", ""), method))
        except Exception:
            print("  (directory unreadable — it will be recreated)")
        print()

    key = re.sub(r"[^a-z0-9-]", "",
                 input("Your short key (lowercase, no spaces, e.g. alice): ")
                 .strip().lower())
    if not key:
        sys.exit("No key entered — nothing changed.")

    name = input("Your full name: ").strip()

    print("Known roles: %s" % "  ".join(sorted(KNOWN_ROLES)))
    role_raw = re.sub(r"\s", "", input("Your role: ").strip().lower())
    if role_raw not in KNOWN_ROLES:
        print()
        print("Warning: '%s' is not a known role. Known roles: %s"
              % (role_raw, ", ".join(sorted(KNOWN_ROLES))))
        confirm = input("Continue anyway? (y/N): ").strip().lower()
        if confirm != "y":
            sys.exit("Nothing changed.")

    try:
        directory = json.load(open(USERS))
        assert isinstance(directory, dict)
    except Exception:
        directory = {"version": 2, "users": []}
    directory.setdefault("users", [])

    if any(u.get("key") == key for u in directory["users"]):
        print("  '%s' is already registered — keeping the existing entry." % key)
    else:
        directory["users"].append({
            "key":    key,
            "name":   name,
            "role":   role_raw,
            "status": "active",
            # key_fingerprints intentionally absent — this is the asserted path.
            # Add fingerprints via register-admin.py / /register-member to enable
            # verified identity for this user.
        })
        directory["version"] = 2
        os.makedirs(os.path.dirname(USERS), exist_ok=True)
        with open(USERS, "w") as fh:
            json.dump(directory, fh, indent=2)
            fh.write("\n")
        print("  Registered '%s'  (%s — %s)." % (key, name, role_raw))
        print("  No key_fingerprints added — identity will be ASSERTED (marker only).")
        print("  To upgrade to VERIFIED identity, run /register-member from an admin.")

    os.makedirs(os.path.dirname(MARKER), exist_ok=True)
    with open(MARKER, "w") as fh:
        fh.write(key + "\n")
    print()
    print("This machine is now set to user:  %s  (ASSERTED path)" % key)
    print("Open Claude Code in this firm home — the session resolves you "
          "automatically.")


if __name__ == "__main__":
    main()

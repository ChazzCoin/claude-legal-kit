#!/usr/bin/env python3
"""
register-admin.py — approve a new firm member's computer for the firm
workspace by adding their access code (SSH public key) to the private repo
and registering their fingerprint in the firm's user directory.

This is the administrator side of onboarding. The new member runs
bin/register-user on their own computer first and sends back their access
code; this script registers that code so their computer can reach the firm
workspace, and records the key fingerprint in members/users.json so the
identity hook can verify them at session start. It is normally driven by
the /register-member skill, which keeps the conversation in plain English
— see the skill for the full flow.

Each member gets their own entry, so any one member can later be removed
without affecting the others. Running for an existing member (same --key)
adds the new machine's fingerprint without creating a duplicate user entry.

REQUIREMENTS
  - gh (GitHub CLI), signed in as someone with admin rights on the firm repo.
    Check with:  gh auth status

USAGE
  register-admin.py <access-code-file-or-text> [options]

  <access-code-file-or-text>   a file holding the member's access code,
                               OR the access-code line itself (quoted)

OPTIONS
  --key    <handle>     the member's short key in users.json (e.g. "alice")
  --name   "<name>"     the member's display name (for new members)
  --role   <role>       the member's role (for new members)
                          partner | associate | of-counsel | paralegal |
                          legal-assistant | investigator | engineer
  --title  "<label>"    label for the GitHub deploy key (default: from the code)
  --repo   OWNER/REPO   the firm repo (default: detected from the current folder)
  --read-only           grant read-only access (default: read + write, so the
                        member can save their work back to the firm workspace)

Cross-platform: pure Python standard library — runs the same on macOS and
Windows. Requires python3 and the GitHub CLI ('gh').
"""

import base64
import datetime
import hashlib
import json
import os
import subprocess
import sys
import tempfile

KNOWN_ROLES = {
    "partner", "associate", "of-counsel", "paralegal",
    "legal-assistant", "investigator", "engineer",
}

HELP_TEXT = __doc__


# ── Paths ────────────────────────────────────────────────────────────────────
# This script installs to <firm-home>/firm/practice-kit/scripts/register-admin.py
# Four dirname calls up reaches the firm home root.
_here = os.path.abspath(__file__)
FIRM  = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(_here))))
USERS = os.path.join(FIRM, "members", "users.json")


# ── Helpers ──────────────────────────────────────────────────────────────────
def have(tool):
    """True if a command is found on PATH."""
    for d in os.environ.get("PATH", "").split(os.pathsep):
        for ext in ("", ".exe", ".cmd", ".bat"):
            if d and os.path.isfile(os.path.join(d, tool + ext)):
                return True
    return False


def is_valid_key_line(line):
    """A key line must begin with a recognized SSH public-key type, followed
    by at least one more space-delimited token."""
    head = line.split(" ", 1)[0]
    rest = line[len(head):].lstrip(" ")
    if not rest:
        return False
    if head in ("ssh-ed25519", "ssh-rsa"):
        return True
    return (head.startswith("ecdsa-") and len(head) > len("ecdsa-")) or \
           (head.startswith("sk-ssh-") and len(head) > len("sk-ssh-"))


def compute_fingerprint(key_line):
    """SHA256 fingerprint from a public key line — matches ssh-keygen -lf output.
    Returns 'SHA256:<base64>' or None on error."""
    try:
        parts = key_line.strip().split()
        if len(parts) < 2:
            return None
        blob   = base64.b64decode(parts[1])
        digest = hashlib.sha256(blob).digest()
        b64    = base64.b64encode(digest).decode("ascii").rstrip("=")
        return "SHA256:" + b64
    except Exception:
        return None


def load_directory():
    """Read members/users.json; return a valid directory dict."""
    try:
        with open(USERS, encoding="utf-8") as fh:
            d = json.load(fh)
        if isinstance(d, dict) and isinstance(d.get("users"), list):
            return d
    except Exception:
        pass
    return {"version": 2, "users": []}


def save_directory(directory):
    """Write the directory back to members/users.json."""
    directory["version"] = 2
    os.makedirs(os.path.dirname(USERS), exist_ok=True)
    with open(USERS, "w", encoding="utf-8") as fh:
        json.dump(directory, fh, indent=2)
        fh.write("\n")


def main():
    # ── Parse arguments ──────────────────────────────────────────────────────
    key_input   = ""
    member_key  = ""   # --key alice
    member_name = ""   # --name "Alice Smith"
    member_role = ""   # --role partner
    title       = ""
    repo        = ""
    allow_write = True

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--key":
            member_key = args[i + 1] if i + 1 < len(args) else ""
            i += 2
        elif arg == "--name":
            member_name = args[i + 1] if i + 1 < len(args) else ""
            i += 2
        elif arg == "--role":
            member_role = args[i + 1] if i + 1 < len(args) else ""
            i += 2
        elif arg == "--title":
            title = args[i + 1] if i + 1 < len(args) else ""
            i += 2
        elif arg == "--repo":
            repo = args[i + 1] if i + 1 < len(args) else ""
            i += 2
        elif arg == "--read-only":
            allow_write = False
            i += 1
        elif arg in ("--help", "-h"):
            print(HELP_TEXT)
            sys.exit(0)
        elif arg.startswith("-"):
            print("Unknown option: %s" % arg, file=sys.stderr)
            sys.exit(1)
        else:
            if not key_input:
                key_input = arg
            else:
                print("Unexpected extra argument: %s" % arg, file=sys.stderr)
                sys.exit(1)
            i += 1

    if not key_input:
        print("No access code given. Pass the member's access code (a file or the",
              file=sys.stderr)
        print("quoted code line) as the first argument.", file=sys.stderr)
        sys.exit(1)

    # ── Preflight ────────────────────────────────────────────────────────────
    if not have("gh"):
        print("This needs the GitHub CLI ('gh'), which isn't installed on this "
              "computer.", file=sys.stderr)
        print("Install it from https://cli.github.com/ and run 'gh auth login'.",
              file=sys.stderr)
        sys.exit(1)
    if subprocess.run(["gh", "auth", "status"],
                      stdout=subprocess.DEVNULL,
                      stderr=subprocess.DEVNULL).returncode != 0:
        print("The GitHub CLI isn't signed in. Run 'gh auth login' first.",
              file=sys.stderr)
        sys.exit(1)

    # ── Resolve the access code into a key line ──────────────────────────────
    cleanup = None
    key_line = ""
    try:
        if os.path.isfile(key_input):
            key_file = key_input
        else:
            fd, key_file = tempfile.mkstemp()
            cleanup = key_file
            with os.fdopen(fd, "w", encoding="utf-8") as fh:
                fh.write(key_input + "\n")

        with open(key_file, encoding="utf-8", errors="replace") as fh:
            first = fh.readline()
        key_line = first.rstrip("\n").replace("\r", "")

        if not is_valid_key_line(key_line):
            print("That doesn't look like a valid access code.", file=sys.stderr)
            print("It should be a single line beginning with 'ssh-ed25519'.",
                  file=sys.stderr)
            sys.exit(1)

        # ── Derive a GitHub deploy-key label ─────────────────────────────────
        if not title:
            fields = key_line.split(" ")
            comment = " ".join(fields[2:]) if len(fields) > 2 else ""
            if comment:
                title = comment
            else:
                title = "claude-legal-kit member (%s)" % \
                    datetime.date.today().isoformat()

        # ── Add the deploy key ───────────────────────────────────────────────
        cmd = ["gh", "repo", "deploy-key", "add", key_file, "--title", title]
        if repo:
            cmd += ["--repo", repo]
        if allow_write:
            cmd += ["--allow-write"]

        print("Approving access for: %s" % title)
        if allow_write:
            print("Access level: read + write (can save work)")
        else:
            print("Access level: read-only")

        if subprocess.run(cmd).returncode != 0:
            print(file=sys.stderr)
            print("Could not add the access code. Common reasons:", file=sys.stderr)
            print("  - This exact access code is already registered (on this or "
                  "another", file=sys.stderr)
            print("    repo). Each machine's code can only be used once — ask the "
                  "member to", file=sys.stderr)
            print("    re-run register-user so a fresh one is created.",
                  file=sys.stderr)
            print("  - The signed-in GitHub account doesn't have admin rights on "
                  "the repo.", file=sys.stderr)
            sys.exit(1)

    finally:
        if cleanup and os.path.exists(cleanup):
            try:
                os.remove(cleanup)
            except OSError:
                pass

    # ── Fingerprint + users.json update ─────────────────────────────────────
    fingerprint = compute_fingerprint(key_line)

    if fingerprint:
        print()
        print("Fingerprint: %s" % fingerprint)
    else:
        print("Warning: could not compute fingerprint — users.json will not be "
              "updated.", file=sys.stderr)

    if fingerprint and member_key:
        directory = load_directory()
        existing = next(
            (u for u in directory["users"] if u.get("key") == member_key), None
        )

        if existing:
            # Additional machine for an existing user — add the fingerprint.
            fps = existing.setdefault("key_fingerprints", [])
            if fingerprint not in fps:
                fps.append(fingerprint)
                save_directory(directory)
                print("Added fingerprint for existing user '%s' (new machine)."
                      % member_key)
            else:
                print("Fingerprint already in directory for '%s' — no change."
                      % member_key)
        else:
            # New user entry.
            if not member_name:
                print("Warning: --name not given; using '%s' as display name."
                      % member_key)
            if member_role and member_role.lower() not in KNOWN_ROLES:
                print("Warning: role '%s' is not in the known list %s."
                      % (member_role, sorted(KNOWN_ROLES)))
            entry = {
                "key":              member_key,
                "name":             member_name or member_key,
                "role":             member_role.lower() if member_role else "unknown",
                "status":           "active",
                "key_fingerprints": [fingerprint],
            }
            directory["users"].append(entry)
            save_directory(directory)
            print("Registered new user '%s' (%s — %s) in members/users.json."
                  % (member_key, member_name or member_key,
                     member_role or "unknown"))
    elif fingerprint and not member_key:
        print("No --key given — skipping users.json update. Pass --key <handle> "
              "to register this member in the user directory.")

    # ── Report ───────────────────────────────────────────────────────────────
    view_cmd = ["gh", "repo", "view"]
    if repo:
        view_cmd.append(repo)
    view_cmd += ["--json", "sshUrl", "-q", ".sshUrl"]
    try:
        ssh_url = subprocess.run(
            view_cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
            text=True).stdout.strip()
    except OSError:
        ssh_url = ""

    print()
    print("─────────────────────────────────────────────────────────────────────")
    print(" Approved.")
    print("─────────────────────────────────────────────────────────────────────")
    print(" Send this back to the new member so they can finish connecting:")
    print()
    print("   You're approved. Run the setup again with this workspace address:")
    if ssh_url:
        print("     %s" % ssh_url)
    else:
        print("     (the firm workspace address)")
    print()
    if member_key:
        print(" Next: commit members/users.json to the firm repo so all machines")
        print(" pick up the new directory entry.")
        print()


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
register-admin.py — approve a new firm member's computer for the firm
workspace by adding their access code (SSH public key) to the private repo.

This is the administrator side of onboarding. The new member runs
bin/register-user on their own computer first and sends back their access
code; this script registers that code so their computer can reach the firm
workspace. It is normally driven by the /register-member skill, which keeps
the conversation in plain English — see the skill for the full flow.

Each member gets their own entry, so any one member can later be removed
without affecting the others.

REQUIREMENTS
  - gh (GitHub CLI), signed in as someone with admin rights on the firm repo.
    Check with:  gh auth status

USAGE
  register-admin.py <access-code-file-or-text> [options]

  <access-code-file-or-text>   a file holding the member's access code,
                               OR the access-code line itself (quoted)

OPTIONS
  --title "<label>"   label for this member's entry (default: from the code)
  --repo  OWNER/REPO  the firm repo (default: detected from the current folder)
  --read-only         grant read-only access (default: read + write, so the
                      member can save their work back to the firm workspace)

Cross-platform: pure Python standard library — runs the same on macOS and
Windows. Requires python3 and the GitHub CLI ('gh').
"""

import datetime
import os
import subprocess
import sys
import tempfile

HELP_TEXT = """register-admin.py — approve a new firm member's computer for the firm
workspace by adding their access code (SSH public key) to the private repo.

This is the administrator side of onboarding. The new member runs
bin/register-user on their own computer first and sends back their access
code; this script registers that code so their computer can reach the firm
workspace. It is normally driven by the /register-member skill, which keeps
the conversation in plain English — see the skill for the full flow.

Each member gets their own entry, so any one member can later be removed
without affecting the others.

REQUIREMENTS
  - gh (GitHub CLI), signed in as someone with admin rights on the firm repo.
    Check with:  gh auth status

USAGE
  register-admin.py <access-code-file-or-text> [options]

  <access-code-file-or-text>   a file holding the member's access code,
                               OR the access-code line itself (quoted)

OPTIONS
  --title "<label>"   label for this member's entry (default: from the code)
  --repo  OWNER/REPO  the firm repo (default: detected from the current folder)
  --read-only         grant read-only access (default: read + write, so the
                      member can save their work back to the firm workspace)"""

def have(tool):
    """True if a command is found on PATH."""
    for d in os.environ.get("PATH", "").split(os.pathsep):
        for ext in ("", ".exe", ".cmd", ".bat"):
            if d and os.path.isfile(os.path.join(d, tool + ext)):
                return True
    return False


def is_valid_key_line(line):
    """A key line must begin with a recognized SSH public-key type, followed
    by at least one more space-delimited token. Mirrors the shell patterns
    'ssh-ed25519 *' | 'ssh-rsa *' | 'ecdsa-* *' | 'sk-ssh-* *'."""
    head = line.split(" ", 1)[0]
    rest = line[len(head):].lstrip(" ")
    if not rest:
        return False
    if head in ("ssh-ed25519", "ssh-rsa"):
        return True
    return (head.startswith("ecdsa-") and len(head) > len("ecdsa-")) or \
           (head.startswith("sk-ssh-") and len(head) > len("sk-ssh-"))


def main():
    # ─── Parse arguments ────────────────────────────────────────────────────
    key_input = ""
    title = ""
    repo = ""
    allow_write = True

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--title":
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

    # ─── Preflight ──────────────────────────────────────────────────────────
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

    # ─── Resolve the access code into a file ────────────────────────────────
    cleanup = None
    try:
        if os.path.isfile(key_input):
            key_file = key_input
        else:
            # Treat the argument as the access-code text itself.
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

        # ─── Derive a label ─────────────────────────────────────────────────
        if not title:
            # The access code's trailing comment is
            # "<user>@<computer> claude-legal-kit".
            fields = key_line.split(" ")
            comment = " ".join(fields[2:]) if len(fields) > 2 else ""
            if comment:
                title = comment
            else:
                title = "claude-legal-kit member (%s)" % \
                    datetime.date.today().isoformat()

        # ─── Add the deploy key ─────────────────────────────────────────────
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
            print("    repo). Each member's code can only be used once — ask them "
                  "to", file=sys.stderr)
            print("    re-run the setup so a fresh one is created.", file=sys.stderr)
            print("  - The signed-in GitHub account doesn't have admin rights on "
                  "the repo.", file=sys.stderr)
            sys.exit(1)
    finally:
        if cleanup and os.path.exists(cleanup):
            try:
                os.remove(cleanup)
            except OSError:
                pass

    # ─── Report ─────────────────────────────────────────────────────────────
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


if __name__ == "__main__":
    main()

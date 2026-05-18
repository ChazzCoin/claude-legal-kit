# bin/

Scripts that operate on the **kit repo itself** — run by a person setting up
or maintaining the kit, not by Claude inside a firm session. `bin/` is not
copied into a firm home.

## Cross-platform — every script is paired

The kit serves firms on **Windows and on macOS/Linux**. Each script ships in
two flavors with the same behavior:

| Script | macOS / Linux | Windows |
|---|---|---|
| Bootstrap a firm home | `bin/init` (bash) | `bin/init.ps1` (PowerShell) |
| Audit `MANIFEST.json` | `bin/check-manifest` (bash) | `bin/check-manifest.ps1` (PowerShell) |
| Onboard onto an existing firm | `bin/register-user.sh` | `bin/register-user.ps1` |

Run the flavor that matches your operating system:

```sh
# macOS / Linux
claude-legal-kit/bin/init /path/to/firm-home
claude-legal-kit/bin/check-manifest
```

```powershell
# Windows (Windows PowerShell 5.1 or PowerShell 7+)
claude-legal-kit\bin\init.ps1 -Target C:\path\to\firm-home
claude-legal-kit\bin\check-manifest.ps1
```

## Requirements

| | macOS / Linux | Windows |
|---|---|---|
| `init` | `python3` (parses `MANIFEST.json`), `git` (optional, for the SHA pin) | `git` only — PowerShell parses JSON natively, no Python needed |
| `check-manifest` | `python3`, `git` | `git` only |

The PowerShell ports are intentionally **self-contained** — they drop the
`python3` dependency the bash scripts carry, because Python is not present on
a default Windows install but PowerShell's `ConvertFrom-Json` is.

`register-user` needs only `git` and `ssh-keygen` (both ship with Git for
Windows and with macOS/Linux OpenSSH). It depends on nothing else in the kit,
so a brand-new member can run it before they have any firm access.

## Onboarding a new member onto an existing firm

`register-user` is run by a **new firm member** on their own computer. The
firm repo is private, so a new member can't clone it yet — but `bin/` lives
in the **public** kit, so they can always get this one script.

It is the member half of a two-sided process:

1. New member runs `register-user` → it creates an SSH key **on their
   machine** (the private half never moves) and prints their public key as a
   one-line "access code."
2. They send the access code to the firm administrator.
3. The administrator approves it — `firm/practice-kit/scripts/register-admin`
   adds it to the private firm repo as a per-member deploy key. This is
   normally driven by the `/register-member` skill.
4. New member runs `register-user` again with the workspace address → it
   clones the private firm repo.

The private key is generated where it is used and never travels; only the
public access code does. See the `/register-member` skill for the full flow.

## Which script runs *inside* a firm — and how Claude knows

The paired scripts inside the practice-kit (`firm/practice-kit/scripts/` —
`new-matter`, `sync-matter`, `new-member`, `detect-platform`, `register-admin`)
are the ones Claude may run during a firm session. Claude picks `.ps1` vs `.sh` from
`.claude/platform.json`, which the `SessionStart` hook in
`.claude/settings.json` writes each session. The binding rule for this is
`firm/practice-kit/conduct/running-scripts.md`.

`bin/init` and `bin/check-manifest` are different — a human runs them, and
the human just picks the flavor for their own machine. No detection needed.

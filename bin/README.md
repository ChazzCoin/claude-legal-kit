# bin/

Scripts that operate on the **kit repo itself** — run by a person setting up
or maintaining the kit, not by Claude inside a firm session. `bin/` is not
copied into a firm home.

## Cross-platform — Python, one implementation

The kit serves firms on **Windows and on macOS/Linux**, and ships no shell
scripts. The `bin/` scripts are **Python** — one implementation, identical
behavior on both platforms.

| Script | What it does |
|---|---|
| `bin/init` | Bootstrap a firm home from `MANIFEST.json` |
| `bin/check-manifest` | Audit `MANIFEST.json` against the kit tree |
| `bin/sync-report` | The read-only reconciliation engine behind `/sync` |
| `bin/register-user` | Onboard a new member's computer onto an existing firm |

Each `bin/` script has no file extension and carries a `python3` shebang, so
on macOS/Linux you run it directly. On Windows, run it through Python, or use
the paired `.cmd` shim next to it (`init.cmd`, `check-manifest.cmd`,
`sync-report.cmd`, `register-user.cmd`) which finds the interpreter (`py` or
`python`) for you.

```sh
# macOS / Linux
claude-legal-kit/bin/init /path/to/firm-home
claude-legal-kit/bin/check-manifest
```

```bat
:: Windows
claude-legal-kit\bin\init.cmd C:\path\to\firm-home
claude-legal-kit\bin\check-manifest.cmd
```

## Requirements

- **`python3`** — every `bin/` script is Python (standard library only; no
  third-party packages). On Windows it is the `py` launcher or `python`.
- **`git`** — used by `init` (optional, for the SHA pin), `sync-report`, and
  `register-user`.
- **`ssh-keygen`** — used by `register-user` only (ships with Git for Windows
  and with macOS/Linux OpenSSH).

`register-user` depends on nothing else in the kit, so a brand-new member can
run it before they have any firm access.

## Onboarding a new member onto an existing firm

`register-user` is run by a **new firm member** on their own computer. The
firm repo is private, so a new member can't clone it yet — but `bin/` lives
in the **public** kit, so they can always get this one script.

It is the member half of a two-sided process:

1. New member runs `register-user` → it creates an SSH key **on their
   machine** (the private half never moves) and prints their public key as a
   one-line "access code."
2. They send the access code to the firm administrator.
3. The administrator approves it — `firm/practice-kit/scripts/register-admin.py`
   adds it to the private firm repo as a per-member deploy key. This is
   normally driven by the `/register-member` skill.
4. New member runs `register-user` again with the workspace address → it
   clones the private firm repo.

The private key is generated where it is used and never travels; only the
public access code does. See the `/register-member` skill for the full flow.

## Scripts that run *inside* a firm

The scripts under `firm/practice-kit/scripts/` (currently `register-admin.py`,
with `new-matter` / `sync-matter` / `new-member` planned) are the ones Claude
may run during a firm session. They are Python too — see
`kit/firm/practice-kit/scripts/README.md`.

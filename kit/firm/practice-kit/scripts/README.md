# scripts/

Scripts that operate on the kit inside a firm home. Claude may run these
during a firm session.

## Python — one runtime, both platforms

The kit ships no shell scripts. Every script here is **Python**, standard
library only — it behaves identically on macOS and Windows. Run a script
with `python3 <name>.py` (or `py <name>.py` on Windows). The kit-wide
runtime split is documented in [`../../../../docs/ARCHITECTURE.md`](../../../../docs/ARCHITECTURE.md) §10.

## Scripts

### Live

- `register-admin.py` — the administrator side of onboarding: add a new
  member's access code (SSH public key) to the private firm repo as a
  per-member deploy key, via the GitHub CLI. Driven by the
  `/register-member` skill. The member side is `bin/register-user` in the
  public kit.

### Planned

Not yet built — to be authored once the manifest schema is finalized:

- `new-matter.py` — scaffold a new matter folder under
  `firm/matters/<matter>/`, copy `new-matter-templates/` in, sync
  `shared-library/` into `.claude/`, stamp `foundation.json` with the current
  kit revision, walk through intake placeholders interactively.
- `sync-matter.py` — pull updated `shared-library/` content into an existing
  matter. Surface any locally-overridden files; never overwrite silently.
- `new-member.py` — copy `members/_template/` into a new member folder,
  prompt for the member's name and role, populate their `CLAUDE.md`.

## Design constraints

- **Python, standard library only.** No third-party packages, no shell.
- **Idempotent.** Re-running a script should produce the same result.
- **Conservative.** A script never deletes a file it didn't create on this run.
- **Honest.** A script reports what it did, what it skipped, and why.
- **No network.** All scripts are local-only — this drive may not always have
  internet, and we don't transmit client data externally anyway.

## Status

`register-admin.py` is live. The matter/member scripts are planned.

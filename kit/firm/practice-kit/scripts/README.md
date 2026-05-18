# scripts/

Scripts that operate on the kit inside a firm home. Claude may run these
during a firm session.

## Paired for Windows and macOS/Linux

Firm members run on either operating system, so every script ships in **two
flavors with identical behavior**:

- `*.sh` — bash / sh, for macOS and Linux.
- `*.ps1` — PowerShell, for Windows.

Claude picks the right flavor from `.claude/platform.json` — written each
session by the `SessionStart` hook in `.claude/settings.json`. The binding
rule is [`../conduct/running-scripts.md`](../conduct/running-scripts.md).

## Scripts

### Live

- `detect-platform.sh` / `detect-platform.ps1` — detect the operating system
  and write `.claude/platform.json`. Run automatically by the `SessionStart`
  hook and once by `bin/init` at install. This is what tells Claude which
  flavor of every other script to run.
- `register-admin.sh` / `register-admin.ps1` — the administrator side of
  onboarding: add a new member's access code (SSH public key) to the private
  firm repo as a per-member deploy key, via the GitHub CLI. Driven by the
  `/register-member` skill. The member side is `bin/register-user` in the
  public kit.

### Planned (skeleton stubs)

These exist as paired stubs so the pattern is set; they exit with a
not-implemented message until authored.

- `new-matter.sh` / `.ps1` — scaffold a new matter folder under
  `firm/matters/<matter>/`, copy `new-matter-templates/` in, sync
  `shared-library/` into `.claude/`, stamp `foundation.json` with the current
  kit revision, walk through intake placeholders interactively.
- `sync-matter.sh` / `.ps1` — pull updated `shared-library/` content into an
  existing matter. Surface any locally-overridden files; never overwrite
  silently.
- `new-member.sh` / `.ps1` — copy `members/_template/` into a new member
  folder, prompt for the member's name and role, populate their `CLAUDE.md`.

## Design constraints

- **Paired.** Every script has a `.sh` and a `.ps1` flavor that behave the
  same. Adding one means adding both.
- **Idempotent.** Re-running a script should produce the same result.
- **Conservative.** A script never deletes a file it didn't create on this run.
- **Honest.** A script reports what it did, what it skipped, and why.
- **No network.** All scripts are local-only — this drive may not always have
  internet, and we don't transmit client data externally anyway.

## Status

`detect-platform` is live. The matter/member scripts are stubs — to be
authored once the manifest schema is finalized.

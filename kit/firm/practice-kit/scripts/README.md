# scripts/

Shell scripts that operate on the kit.

## Planned scripts

- `new-matter.sh` — scaffold a new matter folder under `firm/matters/<matter>/`, copy `new-matter-templates/` in, sync `shared-library/` into `.claude/`, stamp `foundation.json` with the current kit revision, walk through intake placeholders interactively.
- `sync-matter.sh` — pull updated `shared-library/` content into an existing matter. Surface any locally-overridden files; never overwrite silently.
- `new-member.sh` — copy `members/_template/` into a new member folder, prompt for the member's name and role, populate their `CLAUDE.md`.
- `check-manifest.sh` — verify `manifest.json` matches the actual file tree.

## Design constraints

- **Idempotent.** Re-running a script should produce the same result.
- **Conservative.** A script never deletes a file it didn't create on this run.
- **Honest.** A script reports what it did, what it skipped, and why.
- **No network.** All scripts are local-only — this drive may not always have internet, and we don't transmit client data externally anyway.

## Status

Skeleton only. Scripts to be authored once the manifest schema is finalized.

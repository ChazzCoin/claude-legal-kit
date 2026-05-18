# CLAUDE.md — claude-legal-kit (the kit repository)

This is the **kit repository** — `claude-legal-kit`, a public, firm-agnostic Claude Code foundation for law firms. This file orients a session working **on the kit itself**. The full design is in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md); changes are logged in [`CHANGELOG.md`](CHANGELOG.md).

> Not to be confused with the firm-facing root `CLAUDE.md` that a firm home receives — that one is generated from `bootstrap/CLAUDE.md.template` and governs Claude *inside a firm*. **This** file governs work *on the kit*.

## Working on the kit is engineering, not legal practice

The conduct rules under `kit/firm/practice-kit/conduct/` — plain English, no jargon, the "Claude wants to…" permission format — are **content the kit ships to firms**. They govern Claude inside a firm home. They do **not** bind a session working on the kit repository.

Developing the kit is an ordinary engineering task: normal technical language, normal tooling, direct communication. Treat `conduct/` as a deliverable to be edited, not a rule that binds the editing.

## MANIFEST.json is the source of truth

`MANIFEST.json` declares everything that installs into a firm home, and how. `bin/init` (install) and the `/sync` skill (update) both read it — neither has a hardcoded file list. Consequences:

- **Adding a kit file is a one-line `MANIFEST.json` edit.** Put the file under `kit/` or `bootstrap/`, register it, and both `bin/init` and `/sync` pick it up.
- A file committed under `kit/` or `bootstrap/` but **not** registered silently never ships. Nothing else catches this — `bin/check-manifest` does.
- A file added under a directory already covered by a `directory-mirror` entry needs no manifest change.

## Verify before you finish

- **`bin/check-manifest`** — verifies `MANIFEST.json` is a complete, accurate inventory of `kit/` + `bootstrap/`. Run it after adding or removing any kit file, and before tagging a release. It must pass.
- Scripts (`bin/`, the shipped hooks) — syntax-check and exercise them. The standard smoke test is `bin/init` into a temporary directory, then `bin/sync-report` or the hooks run against it.

## The kit stays firm-agnostic — rule #2

No firm-internal information ever enters this repository. It is public.

- No real firm names, people, addresses, contact details, or entity identifiers.
- No real matters or client information.
- No specific drive names or machine paths.
- Jurisdiction and practice content is structural and generic — a placeholder shape, never one firm's operative law stated as settled fact.

A firm's real data lives only in that firm's own private firm-home repository, never here.

## Layout

- `kit/` — the firm-agnostic content that installs into a firm home: the practice-kit, the registry structure, the member-workspace template, the identity hooks, and the `/sync` skill.
- `bootstrap/` — one-time firm files (`CLAUDE.md`, `FIRM.md`, `.gitignore`, `foundation.json`), copied at init and never synced.
- `bin/` — `init`, `check-manifest`, `sync-report`. Kit-repo tooling; not installed into a firm.
- `MANIFEST.json` — the authoritative inventory and install policies.
- `docs/ARCHITECTURE.md` — the design. `CHANGELOG.md` — the history.

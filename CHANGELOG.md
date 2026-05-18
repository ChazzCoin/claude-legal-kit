# Changelog — claude-legal-kit

All notable changes to the kit. Newest first.

## v0.1.0 — 2026-05-18

Initial extraction — a standalone, sync-able legal kit.

The kit's foundation was extracted from the `springer-romeo` firm repository, where the practice-kit, the per-member workspace template, and the binding conduct rules first took shape. This release lifts that firm-agnostic foundation into a third-party, installable, sync-able kit in the [claude-kit](https://github.com/ChazzCoin/claude-kit) mold.

### Added

- **`kit/`** — the firm-agnostic foundation: the full practice-kit (shared-library, new-matter-templates, vocabulary, research-library structure, scripts), the practice-registry structure, the per-member workspace template, and the drive-registry guide.
- **`kit/firm/practice-kit/conduct/`** — *new in the extraction.* The binding behavioral rules — `communication.md` (plain English, offers-not-instructions, the "Claude wants to…" permission format) and `save-load.md` (the save / load / delete metaphor) — pulled out of the origin firm's root `CLAUDE.md` into kit-managed files, so an improvement made once propagates to every firm.
- **`bootstrap/`** — one-time firm files: `CLAUDE.md.template`, `FIRM.md.template`, `gitignore.template`, `foundation.json`.
- **`bin/init`** — MANIFEST-driven bootstrap for a new firm home; non-destructive and idempotent.
- **`bin/check-manifest`** — guards `MANIFEST.json` against drifting from the tree.
- **`MANIFEST.json`** — authoritative inventory and install policies.
- **the `/sync` skill + `bin/sync-report`** — the kit→firm reconciliation. The skill (`kit/.claude/skills/sync/SKILL.md`, installed into a firm's `.claude/skills/sync/`) is the firm-level command behind "load the latest kit updates." `bin/sync-report` is its read-only engine: a three-way compare — the firm's pinned kit version vs. the kit now vs. the firm's own copy — that classifies every kit-managed file as a safe update, a deliberate firm override, or a real conflict. Conduct-compliant: plain English, file-by-file proposals, never auto-applies, and safety-copies a genuine disagreement rather than picking a winner.

### Changed (from the springer-romeo origin)

- Genericized incidental firm-specific detail in copied content: hardcoded firm paths replaced with `<firm-home>`; example member names removed from integration and research-library READMEs; the Bates prefix documented as a firm-chosen code rather than one firm's initials.
- Reset the research-library to an empty, ready-to-use state — removed the origin firm's source/reference entries; cleared the indexes.

### Known limitations

- Several rules-of-practice files (`shared-library/rules/conflicts.md`, `privilege.md`, `retention.md`, `rules/README.md`) and `vocabulary/jurisdictions.md` still carry Alabama-specific law and named-partner detail from the kit's origin. A jurisdiction-neutralization pass is the next step.
- Most kit content is skeleton — folders carry READMEs describing intended content; skills, document templates, and most rules are largely unwritten.
- No firm yet runs against this kit as its live source. With `/sync` now shipped, the remaining wiring is to point an existing firm's `foundation.json` at this kit — migrating the `springer-romeo` origin and running the first real load is the planned follow-up.

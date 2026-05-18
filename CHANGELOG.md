# Changelog — claude-legal-kit

All notable changes to the kit. Newest first.

## Unreleased

Phase 4 — the document management layer (the Tier 0 engine), and the kit-wide move off shell scripts to a cross-platform runtime split. Design of record: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) §10.

### Added

- **The document index engine** — `kit/.claude/tools/index/`: `schema.sql` (the `index.db` schema — documents keyed by content hash, with instance / drive / audit / collection / tag tables, and deferred-tier tables present but unpopulated) and `indexer.py`, the Tier 0 crawler. Cross-platform pure-Python standard library: incremental re-crawl, exact-duplicate detection, move and content-change detection, an append-only audit log, stable volume-id resolution, and a JSONL export of the derived layer. A firm's actual `index.db` is created at runtime, lives on the drive plane, and is gitignored — it is firm data and never enters the kit.
- **`drives/_drive-template.md`** — a per-drive registry-file template carrying the stable `volume_id`.
- **`bin/*.cmd`** — Windows shims so the `bin/` scripts run on Windows as well as macOS.
- **`docs/ARCHITECTURE.md` §10** — the document-management design: a metadata-only index, content-hash identity, the drive-plane SQLite catalog, the tiered pipeline, and v1 as a management (not search) layer.

### Changed

- **The kit ships no shell scripts.** The executable tooling moved off bash to the runtime guaranteed where each piece runs: the SessionStart hook to **Node.js** (`session-start.js` — Claude Code spawns it, and Node is present on every platform it runs on); `bin/init`, `bin/check-manifest`, `bin/sync-report`, and the `setup-user` script to **Python**. `settings.json` invokes `node`. Behavior and machine-readable output are preserved. The kit now runs on macOS and Windows equally.
- **The `drives/` registry is keyed on a stable `volume_id`** — a volume UUID / serial — not a mount path, which differs by OS and, on Windows, changes between pluggings. `mount_path` is demoted to informational.
- **`MANIFEST.json`** — registers the index machinery (`.claude/tools/`) and the drive template.
- **`gitignore.template`** — ignores the firm's `index.db` and JSONL exports.

## v0.3.0 — 2026-05-18

Phase 2 — decontamination. The kit was extracted from a working firm and still carried that firm's identity, and its state's law as if it were universal. Both are gone: the kit is now genuinely firm-agnostic, and jurisdiction-specific law lives in swappable modules.

### Changed

- **Firm identity scrubbed.** The origin firm's name, its partners' and staff's names, its prior firms, its `SR-` Bates prefix, and its drives are gone from `conflicts.md`, `privilege.md`, `retention.md`, `bates-numbering.md`, `rules/README.md`, `drives/README.md`, and the CHANGELOG. The rules keep their substance; identity became role-generic language — "a partner", "non-lawyer staff", "the firm".
- **Core rules made jurisdiction-neutral.** `rules/deadlines.md` is now a framework — the method and discipline of deadline management, with no specific numbers. `conflicts.md`, `privilege.md`, and `retention.md` had their state-specific citations neutralized in place: uniform Rule numbering kept, state-specific figures deferred to the jurisdiction modules.
- **Remaining references neutralized** — `vocabulary/jurisdictions.md` (Alabama reframed as a labeled sample), the `integrations/` READMEs, the `/intake` skill, `vocabulary/topics.md` and `credibility-levels.md`, `DEADLINES.md.template`, and `HOW-TO-CITE.md`.

### Added

- **`shared-library/jurisdictions/federal/`** — the federal jurisdiction module: FRCP 6 time computation and the common federal procedural deadlines.
- **`shared-library/jurisdictions/alabama-state/`** — the Alabama jurisdiction module: Alabama time computation, the statute-of-limitations table, pre-suit notice, and procedural deadlines. The kit's worked example — a firm in another state copies its shape and replaces the content. `jurisdictions/README.md` rewritten to explain the neutral-core / per-jurisdiction-module model.

### Next

- Phase 3 — the first real firm deployment.

## v0.2.0 — 2026-05-18

Phase 1 — roles, identity, conduct, and the metadata model. The kit gains a role-aware behavioral model, a deterministic identity layer, and a linking-and-tagging convention. Design of record: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

### Added

- **`docs/ARCHITECTURE.md`** — the kit's design: the two-structure model (public kit repo / private firm home), the two sync planes, roles, the identity hooks, role-aware conduct, the linking/tagging information graph, and an honest account of what access is and isn't enforced.
- **`conduct/roles.md`** — the role model. Two families — legal (Partner, Associate, Of Counsel, Paralegal, Legal Assistant, Investigator) and technical (Engineer) — and the split between universal rules (confidentiality, the private vault, save/load safety, confirm-before-delete — never relax) and role-varying conduct.
- **The identity hooks framework** — `.claude/hooks/session-start.sh`, a SessionStart hook that resolves the active user from a per-machine marker against `members/users.json` and either orients the session or halts it; `.claude/hooks/setup-user.sh`, the once-per-machine registration script; and kit-owned `.claude/settings.json` registering the hook. Deterministic and shell-level — the assistant is never in the identity loop.
- **`vocabulary/LINKING-AND-TAGGING.md`** — the metadata convention: `id`/`type`/`tags`/`refs` frontmatter, the `@<type>:<id>` handle scheme, and controlled tags drawn from the vocabulary. It formalizes and unifies the kit's existing pieces (the vocabulary, the research-library IDs, the registry stamps) rather than adding a parallel system.
- **Root `CLAUDE.md`** — orientation for any session working on the kit itself.

### Changed

- **`conduct/communication.md` and `conduct/save-load.md` are now role-aware** — the plain-English communication and the save/load vocabulary apply to legal-role sessions; an engineer-role session uses normal technical communication. The universal safety and confidentiality rules bind every session, every role.
- **Member visibility** — `members/README.md` and the member template were rewritten for flat firm-visibility. The old "private by default" framing was never enforced — member folders were always tracked in the shared firm repository — so the model is now stated honestly, with a firm-work-only policy.
- **Registry stamp formats** — the five `practice-registry/` stamp formats now lead with the `id`/`type`/`tags`/`refs` convention; matter links are `@matter:` handles.
- **`MANIFEST.json`** — new entries for the identity hooks and `settings.json`; version bumped to 0.2.0.
- **Decontamination (partial)** — removed an origin-firm drive path from the member template and genericized Alabama-specific examples in the courts registry stamp.

### Next

- Phase 2 — decontamination: jurisdiction-neutralize the rules-of-practice files and `vocabulary/jurisdictions.md`.
- The new-matter templates pick up convention frontmatter when their document-type taxonomy is settled, alongside the `/intake` skill build-out.
- Phase 3 — the first real firm deployment.

## v0.1.0 — 2026-05-18

Initial extraction — a standalone, sync-able legal kit.

The kit's foundation was extracted from the origin firm's repository, where the practice-kit, the per-member workspace template, and the binding conduct rules first took shape. This release lifts that firm-agnostic foundation into a third-party, installable, sync-able kit in the [claude-kit](https://github.com/ChazzCoin/claude-kit) mold.

### Added

- **`kit/`** — the firm-agnostic foundation: the full practice-kit (shared-library, new-matter-templates, vocabulary, research-library structure, scripts), the practice-registry structure, the per-member workspace template, and the drive-registry guide.
- **`kit/firm/practice-kit/conduct/`** — *new in the extraction.* The binding behavioral rules — `communication.md` (plain English, offers-not-instructions, the "Claude wants to…" permission format) and `save-load.md` (the save / load / delete metaphor) — pulled out of the origin firm's root `CLAUDE.md` into kit-managed files, so an improvement made once propagates to every firm.
- **`bootstrap/`** — one-time firm files: `CLAUDE.md.template`, `FIRM.md.template`, `gitignore.template`, `foundation.json`.
- **`bin/init`** — MANIFEST-driven bootstrap for a new firm home; non-destructive and idempotent.
- **`bin/check-manifest`** — guards `MANIFEST.json` against drifting from the tree.
- **`MANIFEST.json`** — authoritative inventory and install policies.
- **the `/sync` skill + `bin/sync-report`** — the kit→firm reconciliation. The skill (`kit/.claude/skills/sync/SKILL.md`, installed into a firm's `.claude/skills/sync/`) is the firm-level command behind "load the latest kit updates." `bin/sync-report` is its read-only engine: a three-way compare — the firm's pinned kit version vs. the kit now vs. the firm's own copy — that classifies every kit-managed file as a safe update, a deliberate firm override, or a real conflict. Conduct-compliant: plain English, file-by-file proposals, never auto-applies, and safety-copies a genuine disagreement rather than picking a winner.

### Changed (from the origin firm)

- Genericized incidental firm-specific detail in copied content: hardcoded firm paths replaced with `<firm-home>`; example member names removed from integration and research-library READMEs; the Bates prefix documented as a firm-chosen code rather than one firm's initials.
- Reset the research-library to an empty, ready-to-use state — removed the origin firm's source/reference entries; cleared the indexes.

### Known limitations

- Several rules-of-practice files (`shared-library/rules/conflicts.md`, `privilege.md`, `retention.md`, `rules/README.md`) and `vocabulary/jurisdictions.md` still carry Alabama-specific law and named-partner detail from the kit's origin. A jurisdiction-neutralization pass is the next step.
- Most kit content is skeleton — folders carry READMEs describing intended content; skills, document templates, and most rules are largely unwritten.
- No firm yet runs against this kit as its live source. With `/sync` now shipped, the remaining wiring is to point an existing firm's `foundation.json` at this kit — migrating the origin firm and running the first real load is the planned follow-up.

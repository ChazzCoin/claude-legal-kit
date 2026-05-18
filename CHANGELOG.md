# Changelog — claude-legal-kit

All notable changes to the kit. Newest first.

## v0.4.0 — 2026-05-18

Cross-platform support and secure new-member onboarding — merged from a parallel branch (PR #1).

### Added — cross-platform scripts

The kit now serves firms on **Windows** alongside macOS/Linux. Scripts ship in two flavors with identical behavior — a bash `.sh`/no-extension flavor and a PowerShell `.ps1` flavor.

- **`bin/init.ps1`, `bin/check-manifest.ps1`** — Windows-native ports of the two `bin/` scripts. Self-contained: they parse `MANIFEST.json` with PowerShell's `ConvertFrom-Json` and drop the `python3` dependency the bash scripts carry. `bin/init.ps1` verified to produce a byte-identical firm home.
- **`kit/firm/practice-kit/scripts/detect-platform.sh` / `.ps1`** — detect the operating system and write `.claude/platform.json`.
- **`kit/firm/practice-kit/scripts/{new-matter,sync-matter,new-member}.{sh,ps1}`** — paired skeleton stubs for the planned matter/member scripts.
- **`conduct/running-scripts.md`** — a conduct rule: Claude reads `.claude/platform.json` and runs the `.ps1` flavor on Windows, the `.sh` flavor on macOS/Linux, with a self-detect fallback.
- **`bin/README.md`** — documents the paired-script layout and per-OS requirements.

The kit-owned `.claude/settings.json` SessionStart hook now runs the platform detector each session, alongside the identity hook — keeping `.claude/platform.json` correct as a firm home moves between machines.

### Added — new-member onboarding

A two-sided flow for connecting a new firm member's computer to a firm's **private** repo, designed so a private key is never transmitted.

- **`bin/register-user.sh` / `.ps1`** — the member side. Self-contained, and lives in the public kit so a new member can run it before they have firm access. Generates an `ed25519` SSH key on the member's own machine — the private half never leaves it — and prints the public key as a one-line access code. Run again with the workspace address, it clones the private firm repo.
- **`kit/firm/practice-kit/scripts/register-admin.sh` / `.ps1`** — the admin side. Adds a member's access code to the firm repo as a per-member deploy key via the GitHub CLI. Per-member keys: members need no GitHub account, and each is individually revocable.
- **`kit/firm/practice-kit/shared-library/skills/register-member/SKILL.md`** — the `/register-member` skill: orchestrates onboarding for an administrator in plain English.

### Changed

- `bin/init` now writes `.claude/platform.json` at install.
- `gitignore.template` ignores the machine-specific `.claude/platform.json`.
- `conduct/README.md`, `scripts/README.md`, `skills/README.md`, `bootstrap/CLAUDE.md.template`, and `README.md` updated for the new conduct rule, the Windows install path, the paired-script convention, and the onboarding flow.

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

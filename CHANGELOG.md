# Changelog — claude-legal-kit

All notable changes to the kit. Newest first.

## Unreleased

### Added — cross-platform scripts

The kit now serves firms on **Windows** alongside macOS/Linux. Every script ships in two flavors with identical behavior — a bash `.sh`/no-extension flavor and a PowerShell `.ps1` flavor.

- **`bin/init.ps1`, `bin/check-manifest.ps1`** — Windows-native ports of the two `bin/` scripts. Self-contained: they parse `MANIFEST.json` with PowerShell's `ConvertFrom-Json` and drop the `python3` dependency the bash scripts carry (Python is not on a default Windows install; PowerShell is). Run under Windows PowerShell 5.1 and PowerShell 7+. Verified to produce a byte-identical firm home to the bash `bin/init`.
- **`kit/firm/practice-kit/scripts/detect-platform.sh` / `.ps1`** — detect the operating system and write `.claude/platform.json`.
- **`kit/firm/practice-kit/scripts/{new-matter,sync-matter,new-member}.{sh,ps1}`** — paired skeleton stubs for the planned matter/member scripts, so the pairing pattern is set.
- **`bootstrap/settings.json.template`** → `.claude/settings.json` — a new firm-owned bootstrap file (`skip-if-exists`). Carries a `SessionStart` hook that runs the platform detector each session, keeping `.claude/platform.json` correct even when a firm home moves between a Windows machine and a Mac.
- **`kit/firm/practice-kit/conduct/running-scripts.md`** — a third conduct rule: Claude reads `.claude/platform.json` and runs the `.ps1` flavor on Windows, the `.sh` flavor on macOS/Linux, with a self-detect fallback if the config is missing.
- **`bin/README.md`** — documents the paired-script layout and per-OS requirements.

### Changed

- `bin/init` now writes `.claude/platform.json` at install (via the detector).
- `MANIFEST.json` registers `settings.json.template`; `gitignore.template` ignores the machine-specific `.claude/platform.json`.
- `bootstrap/CLAUDE.md.template`, `conduct/README.md`, `scripts/README.md`, and `README.md` updated for the third conduct rule, the Windows install path, and the paired-script convention.

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

### Changed (from the springer-romeo origin)

- Genericized incidental firm-specific detail in copied content: hardcoded firm paths replaced with `<firm-home>`; example member names removed from integration and research-library READMEs; the Bates prefix documented as a firm-chosen code rather than one firm's initials.
- Reset the research-library to an empty, ready-to-use state — removed the origin firm's source/reference entries; cleared the indexes.

### Known limitations

- Several rules-of-practice files (`shared-library/rules/conflicts.md`, `privilege.md`, `retention.md`, `rules/README.md`) and `vocabulary/jurisdictions.md` still carry Alabama-specific law and named-partner detail from the kit's origin. A jurisdiction-neutralization pass is the next step.
- Most kit content is skeleton — folders carry READMEs describing intended content; skills, document templates, and most rules are largely unwritten.
- The `/sync` skill is referenced by the workflow but not yet shipped in this repo. Authoring it, and pointing a firm's `foundation.json` at this kit, is the planned follow-up ("wiring").

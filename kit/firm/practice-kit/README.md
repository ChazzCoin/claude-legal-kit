# practice-kit/

The **source of truth** for how this firm does legal work with Claude. Modeled on the structure of [claude-kit](https://github.com/chazzcoin/claude-kit), but rebuilt for litigation practice.

Skills, rules, document templates, drives, and filing workflows live here. Each matter under `firm/matters/<matter>/` gets a `.claude/` folder bootstrapped from this kit; later changes here flow into matters via `scripts/sync-matter.sh`.

## Layout

- **conduct/** — binding rules for *how Claude behaves* in the firm (plain English, save/load metaphor). The firm's root `CLAUDE.md` points here as the authoritative source.
- **shared-library/** — the content that gets synced into every matter
  - `skills/` — slash-commands Claude runs on demand (e.g., `/intake`, `/deposition-prep`, `/file-with-court`)
  - `drives/` — appetite-shaping modes (`trial-prep`, `deposition-week`, `discovery-push`, `closeout`)
  - `templates/` — document templates organized by type
  - `rules/` — universal rules of legal practice (privilege, conflicts, deadlines, retention, Bates)
  - `practice-areas/` — practice-area-specific extensions
  - `jurisdictions/` — court-specific procedural rules
  - `filing-pipeline/` — pre-filing stage scripts and gates
- **new-matter-templates/** — one-time files copied into a new matter at intake; never overwritten afterward
- **vocabulary/** — the firm-wide controlled tag vocabulary (practice areas, topics, jurisdictions, document types, and more)
- **research-library/** — the firm's permanent indexed knowledge base of every source it references
- **scripts/** — `new-matter.sh`, `sync-matter.sh`, future `new-member.sh`
- **manifest.json** — declares what files ship into each matter and under which policy (synced vs. one-time)

## Core principle (borrowed from claude-kit)

**Generic content lives in the kit. Matter-specific facts live in each matter's `CLAUDE.md`.**

A new pattern proven on one matter can be promoted back to the kit so every future matter benefits. A pattern that's truly matter-specific stays in that matter and never pollutes the kit.

## Status

Skeleton only. Skills, rules, and templates are unwritten — folders carry READMEs describing what each will hold. We populate one piece at a time after the structure feels right.

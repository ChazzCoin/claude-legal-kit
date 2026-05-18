# shared-library/

Files here get synced into every matter's `.claude/` folder. Edit here, run sync, every matter picks up the change.

## Subfolders mirror what Claude needs at session start

- `skills/` — what Claude can **do** on command
- `drives/` — how Claude **prioritizes** during a phase of work
- `rules/` — what Claude must **observe** at all times
- `templates/` — what Claude **starts from** when drafting
- `practice-areas/` — supplemental rules and skills for **specific case types**
- `jurisdictions/` — supplemental rules and skills for **specific courts**
- `filing-pipeline/` — staged checks Claude runs **before filing**
- `integrations/` — connections to outside services (email, court filing, legal research, e-signature, calendar)

## Override discipline

If a single matter needs to deviate from a kit file, the matter's local copy of that file is kept and flagged as an "override" in its `foundation.json`. `sync-matter.sh` won't overwrite overrides silently — it surfaces them and asks.

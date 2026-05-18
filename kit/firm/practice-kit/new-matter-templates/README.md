# new-matter-templates/

One-time files copied into a new matter when `scripts/new-matter.sh` runs. After the initial copy, **the matter owns these files** — `sync-matter.sh` will never overwrite them on future syncs.

## Planned templates

- `CLAUDE.md.template` — matter-specific context (parties, court, theory of the case, phase, primary attorney, drive)
- `INTAKE.md.template` — initial intake form
- `PARTIES.md.template` — parties roster (separate from the cross-matter registry; this is *this matter's* view)
- `TIMELINE.md.template` — running chronology
- `DEADLINES.md.template` — deadline tracker with rule citations
- `DISCOVERY-LOG.md.template` — served / received discovery log
- `MOTIONS-LOG.md.template` — motions filed and pending
- `STRATEGY.md.template` — case theory, themes, risks, settlement value
- `BILLING.md.template` — time entries (if hourly or hybrid fee)
- `CLOSEOUT.md.template` — closing checklist

## Placeholders

Templates use `{{PLACEHOLDER}}` markers. `scripts/new-matter.sh` walks through them interactively at intake — never silently — and asks for values. Unfilled placeholders are an intake-incomplete signal.

## Status

Skeleton only. Templates to be drafted as part of the `/intake` skill build-out.

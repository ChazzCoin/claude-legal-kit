# practice-registry/

Cross-matter database. Every party, opposing counsel firm, court, judge, and expert the practice has encountered gets a **stamp** here — a short metadata file (frontmatter plus a few notes), not document storage.

## Why a registry?

Code projects don't have a "people we've worked with before" problem the way a litigation practice does. A registry lets:

- `/conflict-check` flag prior involvement with a name before accepting a new matter
- `/intake` reuse a known party / counsel / court stamp rather than re-typing
- `/file-with-court` read the relevant court stamp for portal and format quirks
- `/case-plan` and settlement strategy benefit from prior observations about opposing counsel and judges

## Folders

- `parties/` — plaintiffs, defendants, witnesses, third parties
- `opposing-counsel/` — firms and individual attorneys we've faced
- `courts/` — courts, divisions, e-file portals, filing requirements
- `judges/` — judges, courtroom rules, scheduling tendencies, ruling patterns
- `experts/` — experts retained or encountered, fee rates, prior testimony, weaknesses

## What does NOT go here

- **No regulated identifiers.** No SSNs, account numbers, medical record numbers, drivers' license numbers. Those belong in the matter file with appropriate protection.
- **No document storage.** Stamps are metadata only. Documents live in the matter folder.
- **No client-confidential strategy.** Notes about an opposing counsel's style are fine; the attorney's secret thoughts on a current case go in that matter's `STRATEGY.md`.

## Conflict-check companion

`conflicts-master.md` at the top of this folder (to be created) is a hand-curated overview of known conflict-of-interest situations across the practice.

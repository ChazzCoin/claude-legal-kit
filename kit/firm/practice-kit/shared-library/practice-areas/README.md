# practice-areas/

Practice-area-specific extensions to the universal rules and skills. Each area is its own subfolder with supplemental skills, rules, and templates that **add to** (never replace) the universals.

## Planned areas

- `personal-injury/` — demand letters, medical-record handling, lien tracking, settlement disposition, statutory deadlines
- `family-law/` — petitions, custody schedules, financial disclosures, mediation rules
- `criminal-defense/` — discovery motions, suppression briefs, plea-offer analysis, sentencing memos
- `construction-law/` — contractor liens, water-well and well-related disputes, defect inspections, mechanics' lien deadlines
- `civil-litigation/` — generic civil-action workflows (catch-all for matters that don't fit a specialized area)

## How it works

Every matter pulls every practice-area folder during sync. The matter's `CLAUDE.md` declares which area(s) apply (a matter can be flagged with more than one — e.g., a construction case with a personal-injury claim attached). Claude reads the relevant areas for context but ignores the others.

## Folder layout inside a practice area

```
<area>/
├── rules/          # area-specific rules (supplement, not replace, universals)
├── skills/         # area-specific skills (e.g., personal-injury/skills/demand-letter/)
└── templates/      # area-specific templates
```

## Status

Skeleton only. Subfolders to be created as the practice tells us which areas are most active.

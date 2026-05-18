# judges/

One stamp per judge. File name: `<last-first>.md` (e.g., `johnson-mary.md`).

## Stamp format

```yaml
---
id: johnson-mary               # filename slug — the @judge handle
type: judge
tags: []
refs:                          # the court this judge sits in, and matters
  - "@court:<court-id>"
  - "@matter:<matter-id>"
judge: "Hon. Mary Johnson"
scheduling_pref: morning hearings; firm trial dates
motion_practice: prefers oral argument on summary judgment; written submissions for routine motions
---
```

Body holds patterns: ruling tendencies on common motions, pet peeves, courtroom decorum expectations, treatment of pro-se parties, accommodations for scheduling.

## Useful for

- `/motion-plan` — calibrate whether a motion is likely to succeed
- `/trial-plan` — anticipate evidentiary rulings and timing
- Briefing — match the judge's stated preferences for length and format

## Caution

Notes here are practical observations, not bias claims. Keep the tone professional — these files are part of the firm record and could in theory be reviewed.

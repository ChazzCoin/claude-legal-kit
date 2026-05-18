# drives/

Modes that shape Claude's **appetite** during a session. Each drive is a short markdown file describing what Claude should want to find, surface, and produce while the drive is active.

Drives aren't filters — they're priors. In `trial-prep` mode, Claude proactively flags missing exhibits and witness-prep gaps without being asked.

## Planned drives

- `trial-prep.md` — find gaps; bias toward over-preparation; surface missing exhibits, witness gaps, jury instructions, motions in limine
- `deposition-week.md` — polish outlines, build impeachment binders, surface inconsistencies in prior statements
- `discovery-push.md` — hit response deadlines, log served and received, flag privilege issues, propose meet-and-confer language
- `closeout.md` — retention reminders, final client letters, file index, fee disposition, archive checklist
- `normal.md` — default — balanced execution, no special priorities

## How a drive is activated

`/drive trial-prep` — switches the active drive in the current matter. The matter's `.claude/current-drive.md` records which is active. The default is `normal`.

## Status

Skeleton only. Drive markdown content to be drafted alongside the first skills.

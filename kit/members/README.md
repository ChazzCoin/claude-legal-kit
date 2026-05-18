# members/

Per-person workspaces. One folder per firm member. Personal drafts, notes, task lists, and inbox live here — separate from shared firm matter files under `firm/matters/`.

## Layout

```
members/
├── _template/                   # copy this to create a new member workspace
├── <member-name>/
│   ├── CLAUDE.md                # personal preferences, current focus, active drive
│   ├── inbox/                   # incoming notes from teammates
│   ├── drafts/                  # work-in-progress not yet promoted to a matter
│   ├── email/                   # personal email workspace — contacts, drafts, sent, notes
│   ├── notes/                   # personal case notes, research, observations
│   └── tasks/                   # personal task list
└── shared-inbox/                # team-wide handoffs and announcements
```

## Creating a new member workspace

```sh
cp -R members/_template "members/<new-member-name>"
```

Then edit `members/<new-member-name>/CLAUDE.md` to fill in role, current focus, and preferences. (Future: `firm/practice-kit/scripts/new-member.sh` will do this interactively.)

## Promotion (personal → matter)

Drafts in `members/<name>/drafts/` become matter-owned when the member moves them into `firm/matters/<Matter>/`. Use `/handoff` to capture context when assigning work to another member.

## Email workspace

Each member's `email/` folder is a personal drafting and contact-tracking workspace. Contact logs, in-progress email drafts, sent copies, and email-related notes all live there. See `members/<you>/email/README.md` for the workflow. Firm-wide guidance for how Claude uses it: `firm/practice-kit/shared-library/skills/email-workspace/README.md`.

## Boundaries

- **Personal folders are not shared** with the firm by default. They're your space.
- **Matter folders** under `firm/matters/` are visible to anyone with access to that matter.
- **`shared-inbox/`** is the explicit team-wide handoff zone.

## Why a separate per-member space?

In a small firm where everyone touches several matters, mixing personal in-progress work with shared matter files makes a mess. Drafts get committed to the matter prematurely; private notes leak into the shared record. Keeping personal work in a separate folder until it's ready is a clean boundary that scales.

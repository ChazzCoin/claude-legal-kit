# members/

One workspace per person. Each member of the firm — legal staff and the engineer alike — has a folder here for their own drafts, notes, tasks, and email. These are working areas, distinct from the shared matter files under `firm/matters/`.

## Layout

```
members/
├── _template/                   # copy this to create a new workspace
├── users.json                   # the firm's user directory — who's who, and their role
├── <key>/                       # one folder per person, named by their user key
│   ├── CLAUDE.md                # the person's preferences and current focus
│   ├── inbox/                   # notes handed to this person by teammates
│   ├── drafts/                  # work in progress, not yet part of a matter
│   ├── email/                   # the person's email workspace
│   ├── notes/                   # the person's working notes and research
│   └── tasks/                   # the person's task list
└── shared-inbox/                # firm-wide handoffs and announcements
```

## Visibility — everything here is firm-visible

Every member folder is part of the firm's shared repository. **Everyone in the firm can see everyone's workspace.** This is deliberate: a small firm works better when work is transparent, and a folder in a shared repository was never genuinely private — so the kit does not pretend otherwise.

What that means in practice:

- **Firm work only.** A member folder holds firm work — drafts, notes, tasks, case research. Personal, private, or non-work material does **not** belong here, or anywhere else in the project. Tell each member this when their workspace is created.
- **Single owner.** `members/<key>/` belongs to that person. They work in it; teammates read it but do not edit it. Ownership is a convention, not a lock.
- **Handoffs are explicit.** To pass something to one teammate, put it in their `members/<them>/inbox/`. For the whole firm, use `shared-inbox/`.

## The user directory

`members/users.json` is the firm's list of users — for each, a `key`, `name`, `role`, and `status`. It is the source of truth for who works at the firm and what role each holds; the identity hook resolves the active user against it at the start of every session. It is created and maintained by the identity setup script (`.claude/hooks/setup-user.sh`).

## Creating a new workspace

```sh
cp -R members/_template "members/<key>"
```

Then run `.claude/hooks/setup-user.sh` so the person is in the user directory, and fill in `members/<key>/CLAUDE.md`. The `<key>` is the person's short handle — the same one used in `users.json` and as their folder name.

A non-legal member (the engineer) uses the same template; they simply leave the legal-workflow subfolders unused, or remove the ones they do not need. One template, many uses.

## Promotion — when a draft joins a matter

A draft in `members/<key>/drafts/` is working material. When it is ready to be part of a matter's official record, it moves into `firm/matters/<Matter>/<subfolder>/`. That move is a **record-of-matter** step — the document becoming part of the file — not a privacy step; the draft was already firm-visible. Carry along whatever context a teammate would need to pick it up.

## Email workspace

Each member's `email/` folder is their email drafting and contact-tracking area — contact logs, in-progress drafts, sent copies, related notes. See `members/<key>/email/README.md` for the workflow, and `firm/practice-kit/shared-library/skills/email-workspace/README.md` for how Claude uses it.

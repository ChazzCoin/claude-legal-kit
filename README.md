# claude-legal-kit

A portable Claude Code foundation for **law firms**. One source of truth for how a firm works with Claude — the conduct rules, the rules of practice, the skills, the document templates, the firm structure — that installs into any firm's home folder and stays current through a one-way sync.

Modeled on [claude-kit](https://github.com/ChazzCoin/claude-kit) (the general-purpose engineering foundation), rebuilt for litigation practice. The full design is in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## What this is

A law firm running Claude Code keeps a **firm home** — a folder holding its configuration, matters, members, and accumulated knowledge. claude-legal-kit supplies the generic, firm-agnostic *foundation* of that home:

- **Conduct rules** (`firm/practice-kit/conduct/`) — the binding behavioral contract: plain English, Claude offers rather than instructs, the "Claude wants to…" permission format, and the *save / load / delete* metaphor that keeps version control invisible to non-technical users.
- **Roles & identity** (`firm/practice-kit/conduct/roles.md`, `.claude/hooks/`) — a per-firm user directory and a session-start hook that resolves who is working; conduct adapts to the role — legal staff get the plain-English contract, the maintaining engineer gets normal technical communication.
- **Rules of practice** (`firm/practice-kit/shared-library/rules/`) — privilege, conflicts, deadlines, retention, Bates numbering.
- **Skills** (`firm/practice-kit/shared-library/skills/`) — `/intake` and more, run on demand.
- **Document templates, integrations, controlled vocabulary, a research-library structure** — the rest of the practice kit.
- **Structure** — the `firm/`, `members/`, `drives/` layout, plus the templates for a new matter and a new member workspace.

Firm-specific facts — the firm's name, office, people, actual matters — are **not** in the kit. They live in the firm's own `CLAUDE.md` and `firm/FIRM.md`, created once at install and never overwritten by a sync.

## Two levels of sync

```
claude-legal-kit  ──install / sync──▶  a firm's home  ──/intake──▶  each matter's .claude/
   (this repo)                         (private, per firm)         (bootstrapped per matter)
```

1. **Kit → firm.** This repo's `MANIFEST.json` governs what installs into a firm home and how. `bin/init` bootstraps a firm; the `/sync` workflow pulls later kit improvements.
2. **Firm → matter.** Inside a firm home, `firm/practice-kit/manifest.json` governs what each new matter is bootstrapped with. That is a separate, firm-local mechanism driven by the `/intake` skill.

This README is about level 1.

## Install — bootstrap a new firm home

```sh
git clone https://github.com/ChazzCoin/claude-legal-kit
claude-legal-kit/bin/init /path/to/firm-home
```

`bin/init` is non-destructive and idempotent. It reads `MANIFEST.json` and applies each file by its policy; it never overwrites a firm's own files; it stamps `.claude/foundation.json` with the kit commit it installed from. Running it again is safe.

After install: fill the `{{PLACEHOLDERS}}` in `CLAUDE.md` and `firm/FIRM.md`, add a file under `drives/` per storage location, copy `members/_template/` once per firm member, and run `.claude/hooks/setup-user.sh` on each person's machine so the identity hook can resolve them.

## Sync — pull later kit updates

From inside the firm home, run the `/sync` skill — or just ask Claude to **"load the latest kit updates."** It is a **one-way** sync, kit → firm: it fetches the kit, diffs every kit-managed file against the firm's copy, classifies drift (kit-only change / firm override / both changed / new / removed), and proposes changes file-by-file. It never auto-applies, never touches the firm's own files, and never silently overwrites a firm override. The pin in `foundation.json` advances on success.

## File policies

| Class | Policy | Behavior |
|---|---|---|
| Kit-managed | `directory-mirror`, `file-replace` | Installed by `init`, updated by `/sync`. |
| Bootstrap | `skip-if-exists` | Created once if absent; never synced — the firm owns it. |
| Bootstrap (pinned) | `init-only-with-sha` | Like above, stamped with the kit SHA at install. |
| Opt-in | `opt-in` | Registered for inventory completeness; not auto-installed. |

`MANIFEST.json` is the single source of truth — adding a kit file is a one-line manifest edit, picked up by both `bin/init` and `/sync`. `bin/check-manifest` guards the manifest against drifting from the tree; run it before tagging a release.

## Repository layout

```
claude-legal-kit/
├── kit/             # files synced into a firm home (firm-agnostic)
│   ├── firm/        #   the practice-kit + practice-registry structure
│   ├── members/     #   the per-member workspace template
│   ├── drives/      #   the drive-registry guide
│   └── .claude/     #   the /sync skill + the identity hooks
├── bootstrap/       # one-time firm files: CLAUDE.md, FIRM.md, .gitignore, foundation.json
├── bin/             # init, check-manifest, sync-report
├── docs/            # ARCHITECTURE.md — the kit's design
├── CLAUDE.md        # orientation for working on the kit itself
├── MANIFEST.json    # authoritative inventory + install policies
├── CHANGELOG.md
└── README.md
```

## Status

**v0.2.0 — roles, identity, and the metadata model.** The install and sync machinery, the `/sync` skill, a role-aware conduct model, a deterministic identity layer (a SessionStart hook plus a per-firm user directory), and the linking-and-tagging convention are all in place. Still ahead: a decontamination pass to strip the last origin-firm and jurisdiction-specific detail, and the first real firm deployment. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design and [`CHANGELOG.md`](CHANGELOG.md) for history and what's next.

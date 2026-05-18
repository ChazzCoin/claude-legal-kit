# claude-legal-kit — Architecture

How the kit is structured, how it reaches a firm, and how identity, roles, and conduct work inside a firm that runs it.

This document describes the **intended architecture**. Some of it is built; some is designed and not yet built — see [Implementation status](#implementation-status). Last revised 2026-05-18.

> The kit is public and firm-agnostic, and so is this document: it describes *an engineer* and *a firm* in the abstract, never a specific one. No firm-internal information belongs here, or anywhere else in this repository.

## 1. Two structures

The system is two separate git repositories with two different lifecycles.

**The kit repo** (`claude-legal-kit`) — this repo. Public, firm-agnostic, the shared foundation: conduct rules, rules of practice, skills, document templates, controlled vocabulary, the firm/member/drive structure, and the machinery that installs and updates all of it. It is maintained by an **engineer** and contains **zero firm data**.

**A firm home** — one *private* git repository per firm, created from the kit by `bin/init` and kept current by the `/sync` skill. It holds everything real: the firm's identity, its people, its registry, its matters. The kit-managed parts inside it are owned by the kit; everything else is the firm's.

```
claude-legal-kit  ──bin/init (install)──▶  a firm home  ──/intake──▶  each matter
   (public)        ──/sync   (update) ──▶  (private)
```

**The boundary rule.** Firm-internal information never enters the kit — not firm names, people, addresses, matters, drive names, nor one firm's operative law presented as fact. The kit ships *structure and generic content*; a firm home holds *facts*. `bin/check-manifest` plus a pre-release leak scan guard this.

## 2. Two sync planes

A firm home's data does not all travel the same way.

**The git plane** — the firm repo and its private remote. Carries the firm structure, all kit-managed files, the `members/` workspaces, the `practice-registry/` stamps, the `drives/` registry, `FIRM.md`, the root `CLAUDE.md`, and the `.claude/` configuration and hooks. **Everyone with the firm repo sees all of it** — this is the firm's shared, transparent working layer.

**The drive plane** — `firm/matters/`, `firm/closed-matters/`, and `private/` are gitignored. They never reach the git remote. Matter documents move on controlled storage tracked in the `drives/` registry; the credentials vault stays local.

Why split them: privilege. A private remote is an acceptable home for firm *structure* and *working folders*. Actual client-matter documents and credentials stay on controlled storage and never touch a hosted remote.

The practical consequence: "everyone sees everyone's work" is true on the git plane — member folders, registry, practice-kit — and deliberately *not* true for matter documents, which are reached through drives.

## 3. Sync mechanisms

**Kit → firm** — the `/sync` skill, engine `bin/sync-report`. One-way, MANIFEST-driven, three-way reconcile (the firm's pinned kit version vs. the kit now vs. the firm's copy). Proposes changes file by file; never auto-applies; never overwrites a firm customization silently. *Built.*

**Firm → matter** — `/sync-practice` (planned), governed by `firm/practice-kit/manifest.json`. Bootstraps and updates each matter's `.claude/` from the firm's practice-kit.

## 4. Roles

Every person who works in a firm home has a **role**. Two families:

- **Legal** — Partner, Associate, Of Counsel, Paralegal, Legal Assistant, Investigator.
- **Technical** — Engineer (Admin reserved for future use).

Every person, the engineer included, has a `members/<name>/` workspace — one mechanism for everyone.

**Role drives conduct. Role does not drive access.** What a role changes is how Claude communicates and what layer of the system it surfaces (§6). What a role does *not* change is what files a person can reach — that is the repo boundary, and nothing else (§7).

The **engineer** is the role that maintains the kit and a firm's plumbing, operating across both repositories. Within a firm home, the engineer is the "kit level" — the layer that installs, syncs, and repairs the structure itself.

## 5. Identity and the hooks framework

A firm home must know **who is working** before any work begins — to apply the right conduct and surface the right layer. Claude Code cannot see who is at the keyboard, so identity resolution is made deterministic and kept out of the AI's hands entirely.

### The pieces

- **`.claude/hooks/`** — the hook and setup scripts. Kit-managed, so `/sync` keeps them current. Shell, with python3 for JSON parsing — no external dependencies, the same rule as `bin/init`.
- **`.claude/settings.json`** — registers the hooks. **Kit-owned**: it ships with the kit and `/sync` keeps it current. A firm's own settings go in `.claude/settings.local.json` (gitignored, never synced, firm- and machine-local).
- **`members/users.json`** — the **user directory** (the firm's "AD"): every user, their role, their member folder, their status. Firm data — it lives in the firm home, travels the git plane, is firm-visible. The kit ships only the *schema*; the real file is built by the setup script as people are onboarded. It is deliberately a small subset of a future permissions model, shaped so it can grow.
- **`.claude/current-user`** — a per-machine pointer, gitignored: which user in `users.json` is on this machine. Just a pointer; the directory holds the detail.

### The flow

**SessionStart hook** — fires deterministically at the start of every session. It reads `.claude/current-user`, looks the user up in `members/users.json`, and:

- **Known user** → injects identity, role, conduct mode, and setup pointers into the session. Claude starts already oriented to that person.
- **Unknown user** → **hard-blocks the session** (`continue: false`) with a message pointing to the setup script. No identity, no session. This is the lock.

**Setup script** (`.claude/hooks/setup-user.sh`) — a normal interactive script a person runs once in their terminal. A regular script *can* prompt; only hooks cannot. It asks who they are and their role, appends them to `users.json` (creating it if absent), and writes the per-machine `current-user` pointer. Normally this is done at machine onboarding; the hook's hard-block is the fail-safe for when it has not been.

The AI is never in the identity loop. The hook resolves; the setup script asks; the AI only ever *receives* a resolved identity.

### Notes

- **First-clone trust prompt.** The first time anyone opens a firm home, Claude Code asks them to trust the project's hooks before they run. Expected and one-time.
- **The lock.** A resolved identity holds for the session. The engineer role is resolved from the machine, never self-asserted — a member cannot talk Claude into engineer mode.
- Hardening the lock per-turn (a `UserPromptSubmit` re-check) is possible but not in the initial design.

## 6. Role-aware conduct

The kit's conduct rules were written for lawyers and should not be applied unchanged to an engineer. Conduct is therefore **role-aware** — but only along one axis.

| Varies by role (legal vs. engineer) | Universal — never relaxes, any role |
|---|---|
| Plain English vs. technical language | Confidentiality — no external transmission of client data |
| Whether jargon is used | `private/` is off-limits to Claude |
| The "Claude wants to…" permission format | Save-load safety — safety copies, never lose or force-overwrite work |
| Legal vs. technical framing | Confirm before deleting |
| Whether file names and paths are shown | Proactiveness — notice patterns, offer |

A legal-role session gets the full lawyer-facing conduct. An engineer-role session gets normal technical communication. **Engineer mode relaxes how Claude communicates — never confidentiality or safety.** That distinction is the spine of the design.

The role logic lives in the kit-managed `conduct/` folder — authority in a new `conduct/roles.md` — so `/sync` delivers it to every firm, including firms whose own root `CLAUDE.md` is never touched.

## 7. Access and scoping — what is actually enforced

This section is deliberately blunt, because "permissions" invites a wrong mental model.

**The only hard, enforced boundary is the repo boundary.** The kit repo is public; a firm repo is private. GitHub access control decides who can clone or push each. The engineer holds both. A firm's members hold only their firm repo. That is the whole of the enforcement.

**Within a repo there is no enforcement.** Everything in a repo is readable by everyone who has that repo. A git repository of files cannot enforce "this person cannot read that folder."

- `private/` is a *Claude-will-not-read* rule plus a gitignore entry. It is not a vault.
- The engineer layer's "invisibility" to legal users is **experience-level**: the SessionStart hook and role-aware conduct mean a legal user's Claude never surfaces kit-level or engineer-level machinery. It is not secrecy — the files are present, and `/hooks` will list the hooks to anyone who runs it.
- `users.json` and any future permissions model shape **behavior and context**, not hard access.

If real per-person access enforcement is ever required, the only mechanism that delivers it is separate repositories — a larger structural decision, and one a small firm is unlikely to need.

## 8. Member folders

One workspace per person under `members/<name>/`.

- **Flat firm-visibility.** Every member folder is on the git plane; everyone with the firm repo sees every member folder. The earlier "private by default" framing is dropped — it was never enforced (member folders were always tracked in the shared repo), and an honest policy beats a fake boundary.
- **Single-owner convention.** Your folder is yours to edit; others read it. A convention, not an enforced boundary.
- **Policy: firm work only.** No personal, private, or non-work information goes in a member folder — or anywhere else in the project. Members are advised of this explicitly.
- **Promotion** — a draft moving from `members/<name>/drafts/` into `firm/matters/<Matter>/` is a *record-of-matter* lifecycle step (work becoming part of the official matter file), not a privacy step.
- The engineer uses the same member template; non-legal members trim the legal-workflow subfolders they do not use.

## 9. Linking and tagging — the information graph

A firm home is an information graph — people, parties, matters, rules, research, documents, all related. A consistent linking and tagging convention, set before mass content generation, is what lets that graph be *traversed*, and lets information-gathering be directed rather than re-discovered each time. The convention formalizes and unifies what the kit already half-has: the controlled vocabulary, the entity registries, and the research-library's IDs.

- **Frontmatter is authoritative.** Every kit and firm content file carries frontmatter: `id` (a stable handle), `type`, `tags` (controlled — see below), `refs` (handles of related entities). Frontmatter is the machine-clean layer — no markdown-symbol clashes, reliably parsed.
- **`@handle` inline.** In prose, an entity is referenced naturally as `@handle` — `@party-jane-doe`, `@matter-…` — resolving against the registries. This is a content convention Claude follows when it *reads*. It is not Claude Code's prompt `@` (which only attaches files), and not a clickable feature.
- **Controlled tags.** A tag must be a term defined in `vocabulary/` (`topics.md`, `jurisdictions.md`, `practice-areas.md`, `document-types.md`, `sensitivity-levels.md`, …). Adding a tag is a deliberate vocabulary edit. Controlled vocabulary — not free tags — is what makes "gather everything about X" reliable.
- **Handles** exist for the entity types that already have identity: people (`users.json`, `members/`), parties, opposing counsel, courts, judges, experts (`practice-registry/`), matters, rules of practice, and research references and sources. Skills keep their `/name` form. The scheme **extends the research-library's existing IDs and citation scheme** (`HOW-TO-CITE.md`, `DATA-MODEL.md`) — it does not start a competing one.
- **Claude maintains it.** Claude applies and updates `id`, `tags`, and `refs` as it creates and edits content; members never write tag or link syntax, so the plain-English conduct holds. The engineer and power users may tag explicitly. The graph's *value* is surfaced to members in plain English ("six documents relate to this, all privilege questions") — never as raw syntax.

The payoff: Claude can traverse the graph — everything about a party, everything tagged a topic, every document citing a research source — and the build-out itself becomes graph-guided. The **convention** ships now — a spec doc, plus the `id`/`type`/`tags`/`refs` frontmatter baked into every template and registry file so new content is born tagged. Traversal is by search. A validator or index generator (a `check-manifest`-style check for dangling `@`-refs and off-vocabulary tags) is deferred — it earns its keep once there is a body of content to check.

## 10. What the kit must never contain

Rule #2, as a standing constraint on every change to this repo:

- No real firm names, people, addresses, contact details, or entity identifiers.
- No real matters or client information.
- No specific drive names or machine paths.
- Jurisdiction and practice content is **structural and generic** — a placeholder shape to be filled per firm — never one firm's operative law stated as settled fact.

Before a release: run `bin/check-manifest`, and scan the tree for leaked specifics.

## Implementation status

**Built**
- The two-structure scaffold; `MANIFEST.json`; `bin/init`; `bin/check-manifest`.
- `/sync` (kit → firm) and its engine `bin/sync-report`.

**Phase 1 — role, identity, conduct, and metadata model** *(built — v0.2.0)*
- `conduct/roles.md`; role-aware `conduct/communication.md` and `conduct/save-load.md`.
- The hooks framework: `.claude/hooks/` (SessionStart hook + setup script), kit-owned `.claude/settings.json`, the `users.json` schema, the `.claude/current-user` marker, gitignore update. New `MANIFEST.json` entries for the hooks and settings.
- Member-visibility rewrite (`members/README.md`, the member template).
- The linking-and-tagging convention: a spec doc (alongside `vocabulary/`, which is its tag namespace); `id`/`type`/`tags`/`refs` frontmatter baked into the new-matter templates, registry files, and member template; the `@handle` scheme aligned with the research-library's existing IDs.
- A kit-repo root `CLAUDE.md` orienting kit-development sessions.
- README update; this document.

**Phase 2 — decontamination** *(built — v0.3.0)*
- Remove the hardcoded drive path in the member template.
- Jurisdiction-neutralize `shared-library/rules/{conflicts,privilege,retention}.md`, `rules/README.md`, and `vocabulary/jurisdictions.md`.

**Phase 3 — firm deployment** *(not kit work)*
- Stand up a firm home with real firm data: `FIRM.md`, members and roles, `users.json`, the private firm repo, the drive registry, and a first `/sync`.

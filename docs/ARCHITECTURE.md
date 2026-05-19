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

- **`.claude/hooks/`** — the SessionStart hook (`session-start.js`) and the bootstrap fallback script (`setup-user.py`). Kit-managed, so `/sync` keeps them current. The hook is **Node.js** — Claude Code spawns it, and Node is the runtime guaranteed on every platform; the setup script is Python. No third-party packages. See §10 for the kit-wide runtime split.
- **`.claude/settings.json`** — registers the hooks. **Kit-owned**: it ships with the kit and `/sync` keeps it current. A firm's own settings go in `.claude/settings.local.json` (gitignored, never synced, firm- and machine-local).
- **`members/users.json`** — the **user directory**: every user, their `key`, `name`, `role`, `status`, and `key_fingerprints` list. Firm data — it lives in the firm home, travels the git plane, is firm-visible. The fingerprints are written by `register-admin.py` at member approval time; the hook reads them to verify identity.
- **`.claude/current-user`** — a per-machine pointer, gitignored: which user in `users.json` is on this machine. Used only on the ASSERTED fallback path when no kit SSH key is present.

### The flow

**SessionStart hook** — fires deterministically at the start of every session. It resolves identity in two ordered steps:

1. **VERIFIED path** — reads `~/.ssh/claude-legal-kit_ed25519.pub`, computes its SHA256 fingerprint in-process (Node `crypto`, no shell calls), and searches `users.json` for a matching `key_fingerprints` entry. The fingerprint was placed in `users.json` by an administrator — not self-declared by the member. Zero matches or multiple matches → hard-block. Exactly one match → resolved, labeled VERIFIED.

2. **ASSERTED fallback** — if no kit key exists on this machine (admin bootstrap and development use), the hook reads `.claude/current-user` and looks the marker up in `users.json`. Resolved if found, labeled ASSERTED in the session context.

In both paths, the hook checks `status == "active"` and hard-blocks if not. Then it injects identity, role, conduct mode, and setup pointers into the session — Claude starts already oriented.

**Unknown user or unresolvable identity** → **hard-blocks the session** (`continue: false`). No identity, no session.

**`register-admin.py`** (administrator side of onboarding) — adds the member's SSH public key to the firm repo as a GitHub deploy key, computes the fingerprint, writes it into `members/users.json`, and prints a commit reminder. The administrator commits `users.json` to the firm repo so every machine picks up the new entry. Driven by the `/register-member` skill.

**`setup-user.py`** — the bootstrap / asserted-path fallback. Creates marker-only directory entries (no `key_fingerprints`) for machines without a registered kit key. Not the normal path for firm members; those go through `/register-member`.

The AI is never in the identity loop. The hook resolves; the scripts register; the AI only ever *receives* a resolved identity.

### Notes

- **First-clone trust prompt.** The first time anyone opens a firm home, Claude Code asks them to trust the project's hooks before they run. Expected and one-time.
- **The lock.** A resolved identity holds for the session. Role and identity are fixed at session start and do not change on request — a member cannot talk Claude into a different role.
- **Admin-as-authority.** Every member↦key binding is created by the administrator running `register-admin.py`. A member cannot self-register their fingerprint; they can only provide the public half (the access code) for the administrator to approve.
- **Two-tier revocation.** Removing a GitHub deploy key cuts repo access; setting `status: "inactive"` in `users.json` (and committing) cuts session access for machines that still hold a key.
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

## 10. Document management — the firm's file index

A firm runs on thousands of documents — matter files, evidence, correspondence, legacy case archives — scattered across drives and folders with no catalog. The `drives/` registry (§2) tracks storage *locations*; the research-library catalogs *external* research. Neither indexes the firm's own document mass. The document index closes that gap: it turns the scatter into a queryable inventory and makes working with files — individually and in groups — a directed operation rather than a filesystem hunt.

### Metadata only — the index never holds content

The index records data *about* each file; it never copies a file's content. This is the drive-plane privilege boundary (§2) applied: matter documents stay on controlled storage, and the index is pointers and derived metadata, nothing more.

A file's identity is its **content hash** (SHA-256), not its path. One logical document can have many instances — the same PDF in four folders across two drives is one document, four locations. Deduplication and the scattered-copies problem fall directly out of this. A computed identity is also the only kind that scales: the research-library's hand-assigned `REF-NNNN` works because references are added one at a time; a mechanically-crawled mass of thousands cannot be hand-numbered.

### Where the index lives

One `index.db` per firm home, on the **drive plane** — gitignored, never pushed to the git remote. An index of matter filenames is itself sensitive (a filename names a client and a matter), so it takes the same posture as the documents it describes.

It is a **SQLite** file: a single file, byte-identical across operating systems, read and written through Python's standard-library `sqlite3` — no server, no database dependency to install. The `.db` is a **query layer, not the system of record**. The mechanical layer (path, hash, size, modified-time) is regenerable at any time by re-crawling. The organizational layer (matter assignments, tags, collections — the work that costs something to produce) is additionally written out to a plain-text JSONL file that is diffable, inspectable, and the artifact actually trusted for durability. A full rebuild is: crawl the drives, replay the JSONL.

### Drives are identified by volume, not by mount path

A removable drive mounts at `/Volumes/<name>` on macOS and at a drive letter on Windows — and the Windows letter changes between one plugging-in and the next. A mount path is not a stable identity.

The `drives/` registry therefore records a **stable volume identifier** (volume UUID or serial number); the live mount point is resolved at runtime, per machine. The index stores **drive-relative paths together with the stable drive ID** — never absolute paths. One `index.db` is then correct on any machine and either operating system. This supersedes the mount-path keying described in the current `drives/` guide, which is fragile on macOS and unworkable on Windows.

### Cross-platform — macOS and Windows, equally

This layer must run identically on both platforms. The consequences:

- The indexer is **Python**, standard library only — SQLite, hashing, directory walking, and path handling are all stdlib and behave identically on both. No shell scripts.
- The kit's runtime split, settled when this phase was built: code that **Claude Code spawns** (the identity hook) is **Node.js** — Claude Code is a Node application, so Node is the one runtime guaranteed present on every platform. Code that **a person or skill runs** (the indexer, `bin/`, `setup-user`) is **Python**, where the standard library carries SQLite and the rest. Neither bash nor a single Python interpreter name is reliable across both platforms; this split is.
- `python3` is a setup prerequisite on both platforms — neither ships it ready to use — and its invocation differs (`python3` versus `python` / `py`); the tooling accounts for both (`bin/` ships `.cmd` shims for Windows).

### The pipeline is tiered

Indexing has a cost gradient. The pipeline is staged so the index is useful the moment the cheapest tier completes, and the expensive tiers run only where they earn it.

| Tier | Produces | Cost | Scope |
|---|---|---|---|
| 0 — crawl | path, hash, size, modified-time, extension, drive | free, mechanical | every file |
| 1 — text extract | born-digital text → full-text search | cheap, no model | files with a text layer |
| 2 — OCR | text from scanned / image files | slow | flagged files |
| 3 — classify | document-type, matter, tags by reading content | expensive, model | on demand |

**v1 builds Tier 0 only.** Tiers 1–3 — full-text search, OCR, and content-based classification — are deferred. The schema ships with their tables present but unpopulated, so adding them later is a feature switch, not a migration.

### v1 is a management layer, not a search layer

A firm's files stay a jumbled mess for one reason: reorganizing thousands of them is too risky — links break, copies diverge, things are lost, and there is no record of what moved. The index removes that risk, and that — not search — is what v1 delivers.

- **Hash-identity** means a file moved from one folder to another is provably the same document. Re-crawling detects the move: a known hash at a new path is a relocation, not a deletion plus a new file. The catalog self-heals.
- An **audit log** records every move, rename, and content change — provenance, and a safety net that makes reorganization reversible.
- Two modes share one engine: **observe** (the firm reorganizes however it likes; a re-crawl tracks it) and **act** (Claude proposes and applies a reorganization — a folder structure, a naming convention — transactionally and under the conduct rules of §6: proposed, confirmed, logged, never destructive).
- **Path-based classification is in v1.** A filename and its folder carry matter, document-type, and date signal that needs no reading of content. Content-based classification — Claude reading the file — is what is deferred with Tier 3.
- **Collections** — a named set of documents, either a static list or a saved metadata query — are the group primitive. They are the unit batch operations run over, and the answer to "work with files in groups."

The index is also a queryable face of the §9 information graph: documents become nodes, and matter and party handles become edges. "Every document in this matter," "every copy of this file," "everything assigned to this party" are graph traversals.

### What the kit ships

The kit is public; a populated index is firm data and never enters it (§11). The kit ships the **machinery**: `schema.sql` (designed for the whole pipeline, Tiers 1–3 included), the Python indexer, and the management skills — `/index` to crawl and refresh, plus locate, deduplicate, organize, matter-linking, and collections. A firm's `index.db` is born empty from the shipped schema and filled by crawling that firm's own drives.

## 11. What the kit must never contain

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

**Phase 4 — the document management layer** *(engine built; management skills not yet — §10.)*

Built:
- The Tier 0 indexer (`.claude/tools/index/indexer.py`) and `schema.sql` — the cross-platform crawl that builds `index.db`: content-hash identity, incremental re-crawl, move and content-change detection, an append-only audit log, and the JSONL durability export.
- The `drives/` registry reworked onto stable volume identifiers with runtime mount resolution; drive-relative paths in the index.
- The kit's shell tooling converted off bash to the cross-platform runtime split (§10): the identity hook to Node.js, `bin/` and `setup-user` to Python with `.cmd` shims. This resolved the open question of whether Phase 4 also makes the *whole* kit cross-platform — it does; the kit ships no shell scripts.
- `MANIFEST.json` entries for the index machinery and the drive template; `gitignore.template` ignores the firm's `index.db`.

Not yet built:
- The management skills: `/index`, locate, deduplicate, organize, matter-linking, collections.
- Deferred tiers — full-text search, OCR, content-based classification.

# Linking and Tagging — the firm's information graph

A consistent way to **identify**, **tag**, and **cross-reference** every piece of content in the kit and in a firm home. Applied from the start, it makes the firm's knowledge a graph that can be traversed — pull everything about a party, everything on a topic, every document that cites a source — instead of re-discovered each time.

This convention does not invent a new system. It **formalizes and unifies** what the kit already has: the controlled vocabulary (`vocabulary/` — the tag namespace), the research library's record IDs and cross-references (`research-library/DATA-MODEL.md`), and the registry stamps (`practice-registry/` — already small frontmatter files).

## Who maintains this

**Claude maintains the metadata.** Claude applies and updates `id`, `tags`, and `refs` as it creates and edits content. Firm members never write tag or handle syntax — the plain-English conduct holds. The engineer and willing power users may use the syntax directly. The *value* of the graph is surfaced to members in plain English ("six documents relate to this, all privilege questions"), never as raw syntax.

## Frontmatter — the metadata layer

Every durable markdown content file carries YAML frontmatter with four standard fields:

```yaml
---
id: smith-damages-memo
type: memo
tags: [damages-economic, life-care-planning, negligence]
refs:
  - "@matter:smith-v-acme"
  - "@party:smith-john"
  - "@reference:REF-0001"
---
```

| Field | Meaning |
|---|---|
| `id` | The file's stable handle — see **Handles** and **IDs** below. |
| `type` | What kind of thing this is: an entity type (`party`, `court`, `matter`, `member`, …) for registry and structural files, or a document type from `document-types.md` (`memo`, `brief`, …) for work product. |
| `tags` | Controlled tags drawn from `vocabulary/` — see **Tags** below. |
| `refs` | Handles of related entities or documents — this file's outbound links. |

Domain-specific fields may sit alongside the standard four. A registry party stamp also carries `name`, `role`, and `conflict_status`; a matter document may carry `phase` or `attorney`. The four standard fields are the constant; domain fields extend them.

**JSON records are the exception.** The research library stores records as JSON, not markdown — its schema (`research-library/DATA-MODEL.md`) already carries an `id`, controlled-vocabulary tag fields, and `cross_references`. That schema stays authoritative for research records. This convention does not change it; it only *addresses* those records by handle.

A pure structural README — a file that just describes what a folder holds — need not carry frontmatter. Frontmatter is for entities and durable content.

## Handles — addressing anything

Every addressable thing has a **handle**: `@<type>:<id>`.

| Handle | Points to | `id` form |
|---|---|---|
| `@member:<id>` | a person's workspace, `members/<id>/` | the user key |
| `@matter:<id>` | a matter under `firm/matters/` | the matter's slug `id` (in its frontmatter) |
| `@party:<id>` | a party stamp in `practice-registry/parties/` | filename slug |
| `@counsel:<id>` | an opposing-counsel stamp | filename slug |
| `@court:<id>` | a court stamp | filename slug |
| `@judge:<id>` | a judge stamp | filename slug |
| `@expert:<id>` | an expert stamp | filename slug |
| `@reference:REF-NNNN` | a research Reference | the existing `REF-NNNN` id |
| `@source:SRC-NNNN` | a research Source | the existing `SRC-NNNN` id |
| `@rule:<id>` | a rule of practice in `shared-library/rules/` | filename slug |

Handles are used two ways:

- **In `refs:` frontmatter** — the file's outbound links, a list of handles.
- **In prose** — write `@party:smith-john` inline where the entity is named, and Claude resolves it against the registry.

A handle is a **content convention Claude follows when it reads** — not Claude Code's prompt `@` (which only attaches files), and not a clickable feature. Skills keep their own form: a skill is referred to as `/intake`, never with an `@` handle.

The research handles (`@reference:`, `@source:`) wrap the research library's existing IDs unchanged. Inside a research JSON record, cross-references keep the bare `REF-NNNN` / `SRC-NNNN` form its schema defines — the `@` form is the prose layer on top.

## IDs — stable, two forms

An `id` is **stable**: assigned once, never reused, not renamed casually — a rename breaks every inbound handle.

- **Slug ids** — kebab-case, lowercase, hyphenated: `smith-john`, `jefferson-circuit`, `privilege`. Used for members, matters, registry stamps, and rules. Usually the file or folder name; a matter carries a slug `id` in its frontmatter that may differ from its human-readable folder name.
- **Sequential ids** — `REF-NNNN`, `SRC-NNNN`, zero-padded, per `research-library/DATA-MODEL.md`. Used for research records.

## Tags — controlled, from the vocabulary

Every tag in a `tags:` list is a term defined in a `vocabulary/` file — `topics.md`, `practice-areas.md`, `jurisdictions.md`, `document-types.md`, `use-cases.md`, `sensitivity-levels.md`, `credibility-levels.md`. All kebab-case. One file may carry tags drawn from several vocabulary files at once.

Tags are **controlled** — never invented inline. A genuinely new tag is added to the right vocabulary file first (with a one-line definition and a date), then used. Controlled vocabulary — not free tags — is what makes "gather everything tagged X" reliable. See [`README.md`](README.md).

## How this aligns with what already exists

- **Research library** — `research-library/DATA-MODEL.md` is and stays the authoritative schema for research records. This convention adds nothing to it; `@reference:`/`@source:` simply name those records from elsewhere.
- **Registry stamps** — already YAML frontmatter (`name`, `type`, `role`, `matters`, `conflict_status`). Under this convention a stamp's `id` is its filename slug, `type` is its entity type, and its `matters:` list is read as `refs`. The stamp's domain fields stay.
- **Vocabulary** — already the firm-wide tag namespace by its own `README.md`. This convention is its companion: the vocabulary defines *which* tags exist; this defines *how* tags, ids, and handles are written and used.

## Traversal — for now, by search

There is no index or resolver tool yet. Traversal is by search: to find everything that references `@party:smith-john`, Claude searches for the handle across the firm home. A validator (dangling handles, off-vocabulary tags) and a generated backlink index are deferred — they earn their place once there is a body of tagged content to check.

## What Claude does automatically

- Applies `id`, `type`, `tags`, and `refs` to content it creates, and keeps them current on edits.
- Draws every tag from the controlled vocabulary; proposes a new vocabulary term for confirmation rather than inventing a tag.
- Keeps handles resolvable — when content is renamed or moved, updates inbound references.
- Surfaces the graph's value to firm members in plain English, never as raw syntax.

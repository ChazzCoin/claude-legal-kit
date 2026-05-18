# Firm Vocabulary

Controlled tag vocabulary used across the firm — research library, matters, registries, work product, anywhere we apply labels. Edit here, every tag-using system reads from here.

This vocabulary is the *tag namespace* for the kit's metadata convention. The full convention — stable handles, frontmatter, and cross-references — is in [`LINKING-AND-TAGGING.md`](LINKING-AND-TAGGING.md).

## Why this exists

So that when one of us tags a research item "voir dire" today and someone tags a memo "voir-dire" in 2028, both end up under the same heading. Without a central, controlled vocabulary, taxonomies drift and the research library turns into a junk drawer.

## Files in this folder

- `practice-areas.md` — the kinds of cases we handle
- `topics.md` — substantive legal topics and trial-skills topics
- `jurisdictions.md` — courts and jurisdictions we work in
- `document-types.md` — kinds of documents and sources
- `use-cases.md` — what we use a reference *for* (trial-prep, brief, deposition, settlement, CLE, etc.)
- `sensitivity-levels.md` — public, work-product, privileged, sealed, etc.
- `credibility-levels.md` — how authoritative a source is

## How tags work

- Tags are **kebab-case** — lowercase, hyphens between words: `voir-dire`, `personal-injury`, `11th-circuit`
- Tags are **drawn from the vocabulary files** — if you need a new tag, add it to the right file first
- A single record can carry **multiple tags from multiple vocabulary files** — a research item typically has topic tags + practice-area tags + jurisdiction tags + use-case tags
- Tags are **never deleted** — a tag that turns out to be redundant or rarely used gets marked `deprecated`, so old records still resolve

## Adding a new tag

1. Decide which vocabulary file it belongs in.
2. Add it under the right section with a one-line definition.
3. Stamp the date added.
4. Use it.
5. If it ever becomes redundant, mark it deprecated — never delete.

## What Claude does automatically

- Reads the vocabulary at session start before tagging anything
- Surfaces any proposed new tag for confirmation before adding it
- Uses only vocabulary tags — never invents tags on the fly
- Catches tag typos and suggests the canonical form
- Flags tags that appear in records but are missing from the vocabulary (drift detection)

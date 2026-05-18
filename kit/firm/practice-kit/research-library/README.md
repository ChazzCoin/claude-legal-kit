# Research Library

The firm's permanent, indexed, citable knowledge base.

Every podcast, article, video, PDF, court opinion, treatise, brief, expert report, deposition, war story, or anything else worth keeping for future research lives here as a structured record. Every record carries proper citation data, a Wayback Machine archive of its URL (when applicable), our own summary in our own words, pinpoint references, and consistent tags drawn from [`firm/practice-kit/vocabulary/`](../vocabulary/).

## Where this sits in the firm

`firm/practice-kit/research-library/` — **firm-central, not synced into matters**. Every matter and every member can read from it. Matter folders link back via Reference IDs; the library never gets copied into a matter folder.

## The two-tier model

**Sources** are *origins* — publishers, shows, journals, websites, authors-as-publishers, firms, agencies. One Source record per origin. **Deduplicated**: if we've ever pulled material from Picking Justice, there is exactly one `SRC-NNNN` record for Picking Justice, forever.

**References** are *items* — individual pieces of content. Each Reference points back to its parent Source by ID.

```
SRC-0001  Picking Justice (podcast show)
    ├── REF-0001  Mitnik episode (Ep. 29)
    ├── REF-00NN  some future episode
    └── ...

SRC-0002  Trial Magazine (AAJ publication)
    ├── REF-00MM  some article
    └── ...
```

## Folder layout

```
research-library/
├── README.md                    — this file
├── HOW-TO-ADD.md                — how to add new material
├── HOW-TO-CITE.md               — modified-Bluebook citation rules
├── DATA-MODEL.md                — the JSON schema for Sources and References
├── INDEX-sources.md             — every Source, alphabetical and by ID
├── INDEX-references.md          — every Reference, by ID
├── sources/                     — Source records
│   ├── _template.json           — blank template for new Sources
│   └── SRC-NNNN-<slug>.json + .md
├── references/                  — Reference records
│   ├── _template-<type>.json    — one blank template per document type
│   └── REF-NNNN-<slug>.json + .md
├── by-topic/                    — index files grouping References by topic tag
├── by-type/                     — index files grouping References by document type
├── by-jurisdiction/             — index files grouping References by jurisdiction
├── by-source/                   — index files grouping References by parent Source
└── files/                       — sym-link target for local files (PDFs, audio, photos)
```

## Authoritative format

The `.json` file is the **source of truth** for each record. The paired `.md` file is a human-readable companion — any firm member can read it without parsing JSON. If the two ever disagree, the JSON wins.

## File handling rule

**We never move files. We sym-link.**

If a Reference points to a local file (a PDF we own, a deposition transcript, a photo), the file stays in its original folder (typically the matter folder where it was first stored). The Research Library's `files/` folder holds a **sym-link** to it — never a copy, never a move. This way:

- A single file lives in exactly one place
- Renaming or reorganizing the source folder is detected
- We can never accidentally create two divergent copies

See [`HOW-TO-ADD.md`](HOW-TO-ADD.md) for the sym-link convention.

## How to use it

Three actions, all initiated by asking Claude:

1. **Add** — "Claude, add this source: [URL or file path]" — Claude reads it, checks for an existing Source, creates the Reference, captures a Wayback snapshot if applicable, tags it, files it, indexes it.

2. **Find** — "What do we have on damages framing?" — Claude searches by tag, returns a ranked list with our own annotations.

3. **Cite** — "Give me a citation for the Mitnik episode" — Claude returns paste-ready modified-Bluebook citation with URL and date accessed.

## What Claude does automatically

- Reads the vocabulary at session start before tagging
- Refuses to reproduce a full copyrighted work in this folder — pinpoint quotes only, attributed and brief
- Captures a Wayback Machine archive URL when adding any web-based Reference
- Sym-links local files; never copies, never moves
- Deduplicates Sources — checks `INDEX-sources.md` before creating a new Source record
- Sorts pulled References by credibility level when surfacing for filings
- Flags any record with missing required fields

## Status

Active as of 2026-05-15. Skeleton + first record (SRC-0001 / REF-0001) seeded on creation day.

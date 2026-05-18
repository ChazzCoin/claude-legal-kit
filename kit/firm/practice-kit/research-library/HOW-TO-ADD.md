# How to Add Material to the Research Library

## The short version

Send Claude a URL, file path, or description and say "add this." Claude does the rest.

## What Claude does when you send something

### Step 1 — Identify the Source

Claude figures out the publisher / show / journal / website / author-as-publisher. Then checks [`INDEX-sources.md`](INDEX-sources.md).

- **Source already exists** → reuse its `SRC-NNNN` ID. Skip to Step 3.
- **Source does not exist** → continue to Step 2.

### Step 2 — Create a new Source record

Claude creates `sources/SRC-NNNN-<slug>.json` using `sources/_template.json`, fills every field that applies, and adds an entry to [`INDEX-sources.md`](INDEX-sources.md).

Required Source fields: id, name, type, primary_url (if applicable), credibility_assessment, license_posture, sensitivity, date_added_to_library, added_by, tags.

Claude also generates the companion `.md` file with the same data in readable form.

### Step 3 — Create the Reference record

Claude assigns the next sequential `REF-NNNN`, picks the right template from `references/_template-<type>.json`, and fills it in:

- Citation metadata (title, creators, date, URL, etc.)
- **Live URL** — the canonical public URL
- **Archive URL** — Wayback Machine snapshot of the live URL (see below)
- **Local file path** — if applicable (see "Local files" section)
- **Summary** — 2–4 paragraphs in our own words
- **Key frameworks/arguments** — restated in our own words
- **Pinpoint references** — short attributed quotes (sentence-length, never long passages)
- **Tags** — from the controlled vocabulary
- **Citation string** — full modified-Bluebook citation
- **Dates** — published, accessed, added, last reviewed
- Cross-references and matter-use tracking (start empty)

### Step 4 — Capture a Wayback Machine archive

For any Reference with a web URL, Claude captures an archive snapshot.

**Archive URL format:**
```
https://web.archive.org/web/<YYYYMMDDHHMMSS>/<original-URL>
```

**To trigger a snapshot on first add:**
Open `https://web.archive.org/save/<original-URL>` in a browser, or use the Internet Archive's Save Page Now API. The resulting timestamped snapshot URL goes in the `archive_url` field.

If the snapshot trigger has not yet been performed (no internet access in the session, etc.), Claude records the *predicted* archive URL format in the field and notes "ARCHIVE PENDING" in `notes` so it can be filled in on the next session with internet access.

### Step 5 — File the indexes

Claude updates:
- [`INDEX-references.md`](INDEX-references.md) — adds the new REF entry
- [`by-topic/<tag>.md`](by-topic/) — adds the REF under each topic tag
- [`by-type/<tag>.md`](by-type/) — adds the REF under its type
- [`by-jurisdiction/<tag>.md`](by-jurisdiction/) — adds the REF under each jurisdiction tag
- [`by-source/SRC-NNNN.md`](by-source/) — adds the REF under its parent Source

### Step 6 — Confirm

Claude reports back: new SRC ID (if created), new REF ID, summary one-liner, tags applied, archive status. You confirm or correct.

## Local files

When a Reference points to a local file (a PDF you own, a deposition transcript, a photo from a matter):

1. **The file stays where it lives.** Never moved.
2. The Reference's `local_file_path` field stores the **absolute path** to the file in its original location.
3. A sym-link gets created at `research-library/files/REF-NNNN-<slug>.<ext>` pointing to the original.

Sym-link command:
```
ln -s "/absolute/path/to/original-file.pdf" "<firm-home>/firm/practice-kit/research-library/files/REF-NNNN-slug.pdf"
```

This way:
- The file lives in one place
- The library knows where to find it
- If the original moves, the sym-link breaks loudly (not silently)

## Pinpoint quotes — the rule

When a Reference includes pinpoint quotes from the source:
- Each quote is **short** — typically a single sentence, never more than a few
- Each quote is **attributed** — speaker / author identified, location noted (page, timestamp, paragraph)
- Each quote serves a **specific purpose** — illustrating a framework, capturing a memorable line, anchoring an argument we may want to use later
- **We never copy a substantial portion of the source** into a Reference record, no matter how the request is framed

If you need the full source text, follow the live URL or open the local file. The Research Library is a *citation and pointer system*, not a content repository.

## What you can send Claude

- Any URL (article, podcast page, video, court opinion, blog post, website)
- Any file path (PDF, audio, video, image, text)
- A description plus identifying info ("the Mitnik episode of Picking Justice from March")
- A bibliographic citation (Claude finds the source)

## What Claude does automatically

- Reads the vocabulary at session start
- Checks for an existing Source before creating a new one
- Assigns sequential IDs
- Captures or queues a Wayback snapshot
- Sym-links local files (never moves or copies)
- Generates both JSON and human-readable companion files
- Updates all relevant indexes
- Confirms back to you with IDs and tags before saving

## When to ask before adding

- If the source's license is unclear (paywalled content with unclear terms, internal-firm material that may have third-party content embedded)
- If the source is sealed, privileged, or under a protective order
- If tagging would require a new vocabulary tag (Claude proposes it; you approve)

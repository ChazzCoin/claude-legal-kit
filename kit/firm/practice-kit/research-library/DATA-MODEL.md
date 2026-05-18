# Data Model — Sources and References

This document defines the JSON schema for the two record types in the Research Library: **Sources** and **References**.

The `.json` file is the authoritative store. The paired `.md` companion is a human-readable rendering of the same data. If they disagree, JSON wins.

## ID format

- **Sources**: `SRC-NNNN` — sequential, zero-padded to 4 digits, never reused.
- **References**: `REF-NNNN` — sequential, zero-padded to 4 digits, never reused.

When we exceed 9999 of either, we extend to 5 digits (`SRC-10000`). Old IDs are not re-formatted.

## Filename convention

`<ID>-<slug>.json` and `<ID>-<slug>.md`, where `<slug>` is a kebab-case short identifier.

Examples:
- `SRC-0001-picking-justice.json`
- `REF-0001-mitnik-package-jurors.json`

## Date format

All dates are ISO 8601 — `YYYY-MM-DD`. Timestamps when needed are `YYYY-MM-DDTHH:MM:SSZ` (UTC).

## Source schema

A Source represents an *origin* — a publisher, show, journal, website, author-as-publisher, firm, agency.

```json
{
  "id": "SRC-NNNN",
  "name": "Human-readable name of the publisher/show/journal/etc.",
  "type": "podcast | journal | trade-magazine | publisher | website | author | firm | agency | court | other",
  "subtype": "Optional finer classification — e.g., legal-education-podcast, peer-reviewed-journal, blog",
  "description": "1-3 sentence description of what this source is",
  "primary_creators": [
    {
      "name": "Name",
      "role": "founder | host | editor | author | publisher | etc.",
      "credentials": "Optional — relevant professional credentials"
    }
  ],
  "publisher_entity": "Legal/business entity that owns or publishes this source, if known",
  "primary_url": "Canonical web URL for the source",
  "archive_url": "Wayback Machine snapshot URL of the primary_url",
  "alternate_platforms": {
    "platform_name": "URL on that platform"
  },
  "content_formats": ["audio", "video", "text", "published-transcripts", "etc."],
  "subject_areas": ["controlled-vocab tags from topics.md"],
  "jurisdiction_focus": "controlled-vocab tag from jurisdictions.md, or 'general'",
  "language": "English | etc.",
  "license_posture": "publicly-available | paywalled | mixed | unclear",
  "sensitivity": "controlled-vocab tag from sensitivity-levels.md",
  "credibility_assessment": "controlled-vocab tag from credibility-levels.md",
  "credibility_notes": "Free-text explanation of credibility assessment",
  "first_observed_publication": "YYYY or YYYY-MM",
  "date_added_to_library": "YYYY-MM-DD",
  "date_last_reviewed": "YYYY-MM-DD",
  "added_by": "Who added it (person + Claude session)",
  "tags": ["additional free-form tags from vocabulary"],
  "references_count": 0,
  "notes": "Free-text notes about the source"
}
```

### Required Source fields

- `id`, `name`, `type`, `description`, `primary_url` (if web-based), `sensitivity`, `credibility_assessment`, `date_added_to_library`, `added_by`, `tags`

### Optional Source fields

- All others. Fill what you know; leave the rest empty (empty string, empty array, or `null`).

## Reference schema

A Reference represents an *item* — an individual piece of content. Every Reference belongs to exactly one Source.

```json
{
  "id": "REF-NNNN",
  "source_id": "SRC-NNNN",
  "title": "Full title of the item",
  "subtitle": "Optional",
  "type": "controlled-vocab tag from document-types.md",
  "episode_or_volume_number": "Episode N | Vol. N, Issue N | etc. — type-dependent",
  "publication_date": "YYYY-MM-DD",
  "duration_minutes": 0,
  "page_count": 0,
  "creators": [
    {
      "name": "Name",
      "role": "host | guest | author | editor | speaker | judge | etc.",
      "credentials": "Optional"
    }
  ],
  "live_url": "Canonical public URL",
  "archive_url": "Wayback Machine snapshot URL",
  "alternate_urls": {
    "platform_name": "URL on that platform"
  },
  "local_file_path": "Absolute path to local file, if applicable",
  "local_symlink_path": "Path to the sym-link in research-library/files/",
  "has_transcript": true,
  "transcript_location": "Where the transcript lives — 'embedded on live_url', URL, local path",
  "subject_tags": ["from topics.md"],
  "practice_area_tags": ["from practice-areas.md"],
  "jurisdiction_tags": ["from jurisdictions.md"],
  "use_case_tags": ["from use-cases.md"],
  "doc_type_tags": ["from document-types.md — usually same as 'type' but allows multi-tagging"],
  "summary": "Our own 2-4 paragraph summary in our own words",
  "key_frameworks": [
    {
      "name": "Name of framework/argument/concept",
      "our_restatement": "Our own restatement in our own words"
    }
  ],
  "pinpoint_references": [
    {
      "short_quote": "Brief attributed quote — sentence-length",
      "location": "page N | timestamp | paragraph N",
      "speaker_or_author": "Who said/wrote this",
      "topic": "What this quote is useful for"
    }
  ],
  "cross_references": [
    {
      "ref_id": "REF-NNNN",
      "relationship": "see-also | supersedes | superseded-by | cited-in | cites | extends"
    }
  ],
  "used_in_matters": [
    {
      "matter_id": "Matter identifier",
      "matter_name": "Human-readable matter name",
      "context": "Where in the matter it was used"
    }
  ],
  "supersedes": "REF-NNNN or null",
  "superseded_by": "REF-NNNN or null",
  "citation_modified_bluebook": "Full paste-ready citation string per HOW-TO-CITE.md",
  "sensitivity": "controlled-vocab tag from sensitivity-levels.md",
  "credibility": "controlled-vocab tag from credibility-levels.md",
  "license_posture": "publicly-available | paywalled | client-shared | etc.",
  "publication_date": "YYYY-MM-DD",
  "date_accessed": "YYYY-MM-DD",
  "date_added": "YYYY-MM-DD",
  "date_last_reviewed": "YYYY-MM-DD",
  "date_archived": "YYYY-MM-DD",
  "date_superseded": null,
  "added_by": "Who added it",
  "notes": "Free-text notes"
}
```

### Required Reference fields

- `id`, `source_id`, `title`, `type`, `publication_date`, `live_url` (if web-based) OR `local_file_path` (if local), `summary`, `subject_tags`, `sensitivity`, `credibility`, `citation_modified_bluebook`, `date_accessed`, `date_added`, `added_by`

### Optional Reference fields

- All others. Fill what you know.

## Empty values

- Text fields: use `""` if not known
- Arrays: use `[]` if not known
- Booleans: `false` if not applicable
- Dates: use `null` if not known
- Numbers: use `0` if not known and required, `null` if optional

## Cross-reference semantics

When `REF-A` points to `REF-B` via `cross_references`, the inverse pointer is **not** automatically created. Claude maintains symmetry on every add/update.

When `REF-A.supersedes = REF-B`, then `REF-B.superseded_by` must also equal `REF-A`. Claude enforces this.

## Schema versioning

Schema version is implicit — there is only one schema right now, dated 2026-05-15. If we ever change the schema, we add a `_schema_version` field to all new records and migrate old records as needed. Old records remain valid; new records get the new schema.

## What Claude does automatically

- Validates every record against this schema before saving
- Fills `date_added` and `date_last_reviewed` automatically
- Generates the human-readable `.md` companion from the JSON
- Maintains cross-reference symmetry
- Increments `references_count` on the parent Source when a Reference is added
- Maintains all indexes

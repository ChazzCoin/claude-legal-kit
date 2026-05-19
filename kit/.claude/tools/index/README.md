# .claude/tools/index/ — the document index

The firm's file catalog. It turns thousands of scattered documents — matter
files, evidence, correspondence, legacy archives — into one queryable
inventory. See `docs/ARCHITECTURE.md` §10 for the full design.

## What it is

- **`schema.sql`** — the index database schema (SQLite).
- **`indexer.py`** — the crawler that builds and refreshes the index.
- **`index.db`** — *not shipped.* The firm's actual index, created on first
  use. It lives in the firm home on the **drive plane** — gitignored, never
  pushed to a remote, because an index of matter filenames is itself
  sensitive. The kit ships only the machinery.

## What it records — and what it does not

The index stores metadata *about* each file: its path, size, modified-time,
extension, and a content hash. It **never stores file content.** Matter
documents stay on controlled storage; the index is pointers, nothing more.

A document's identity is its **content hash** (SHA-256), not its path — so
the same file in four folders across two drives is one document with four
instances, and deduplication falls straight out.

## v1 scope — Tier 0

This is the Tier 0 mechanical crawl: inventory, deduplication, move
detection, and an audit log. Full-text search, OCR, and content-based
classification are deferred tiers — their tables exist in `schema.sql` but
are unpopulated here.

## Using it

`indexer.py` is pure Python standard library — it runs identically on macOS
and Windows, with no third-party packages. Python 3 must be installed.

```
python3 indexer.py init   --db <firm-home>/.claude/tools/index/index.db
python3 indexer.py crawl  --db .../index.db  /path/to/a/drive  --label "Archive"
python3 indexer.py status --db .../index.db
python3 indexer.py export --db .../index.db  --out derived.jsonl
```

- **`crawl`** is incremental (unchanged files are not re-hashed) and
  self-healing (a known file at a new path is recorded as a move; a vanished
  file as missing). Re-crawl as often as you like.
- **`crawl`** resolves the *volume* the path lives on and stores every
  location as a drive-relative path, so one `index.db` is correct on any
  machine and either OS. The volume is identified in the `drives/` registry.
- **`export`** writes the durable, human-readable layer (classifications,
  collections) to JSONL. The mechanical crawl layer is regenerable and is
  not exported.

Members never run this directly — the management skills do. Claude surfaces
what the index knows in plain English.

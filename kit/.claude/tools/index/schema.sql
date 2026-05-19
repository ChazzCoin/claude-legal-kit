-- claude-legal-kit — document index schema
--
-- index.db is a firm's file catalog: one SQLite file per firm home, on the
-- drive plane (gitignored, never pushed to a remote). It stores metadata
-- ABOUT files — never file content. See docs/ARCHITECTURE.md §10.
--
-- This schema is designed for the whole indexing pipeline. v1 (Tier 0, the
-- mechanical crawl) populates `drive`, `document`, `instance`, and `audit`.
-- The classification columns (`document.doc_type`, `document.matter`, the
-- `tag` table) and the `text` table are present but unpopulated in v1, so
-- enabling later tiers is a feature switch, not a migration.

PRAGMA user_version = 1;

-- ── meta ── schema version and index provenance, one row per key.
CREATE TABLE IF NOT EXISTS meta (
  key   TEXT PRIMARY KEY,
  value TEXT
);

-- ── drive ── a storage location, identified by a STABLE volume id.
-- A mount path is not identity: it differs by OS and, on Windows, changes
-- between pluggings. The id is a volume UUID / serial (see the indexer's
-- volume_id resolver). The live mount point is resolved at runtime.
CREATE TABLE IF NOT EXISTS drive (
  id          TEXT PRIMARY KEY,   -- stable volume UUID / serial
  label       TEXT,               -- human label for the drive
  kind        TEXT,               -- internal | external-ssd | usb-flash | cloud-sync | network-share
  first_seen  TEXT,               -- ISO 8601 date
  last_seen   TEXT                -- ISO 8601 date
);

-- ── document ── a LOGICAL document, identified by its content hash.
-- The same bytes in four folders across two drives are ONE document with
-- four instances. Deduplication falls directly out of this.
CREATE TABLE IF NOT EXISTS document (
  hash        TEXT PRIMARY KEY,   -- sha256, lowercase hex
  size        INTEGER,            -- bytes
  ext         TEXT,               -- lowercased extension, no leading dot
  first_seen  TEXT,               -- ISO 8601 date the index first saw these bytes
  -- Classification: written from path/filename in v1 (by the management
  -- skills), and from content later (Tier 3). Same columns either way.
  doc_type    TEXT,               -- controlled-vocab document type, or NULL
  matter      TEXT                -- @matter handle, or NULL
);

-- ── instance ── a PHYSICAL location of a document. One document, many
-- instances. Keyed by location; its `hash` is updated if the file at that
-- path changes content.
CREATE TABLE IF NOT EXISTS instance (
  id          INTEGER PRIMARY KEY,
  hash        TEXT NOT NULL REFERENCES document(hash),
  drive_id    TEXT NOT NULL REFERENCES drive(id),
  rel_path    TEXT NOT NULL,      -- path relative to the drive root, POSIX-style ("/")
  name        TEXT NOT NULL,      -- basename
  mtime       TEXT,               -- ISO 8601, filesystem modified-time
  size        INTEGER,            -- bytes
  status      TEXT NOT NULL DEFAULT 'present',  -- present | missing
  first_seen  TEXT,
  last_seen   TEXT,
  UNIQUE (drive_id, rel_path)
);
CREATE INDEX IF NOT EXISTS idx_instance_hash  ON instance(hash);
CREATE INDEX IF NOT EXISTS idx_instance_drive ON instance(drive_id);

-- ── tag ── controlled-vocabulary tags on a document — the §9 graph as
-- relational edges. Unpopulated in v1.
CREATE TABLE IF NOT EXISTS tag (
  hash  TEXT NOT NULL REFERENCES document(hash),
  tag   TEXT NOT NULL,            -- a term defined in the firm's vocabulary/
  PRIMARY KEY (hash, tag)
);
CREATE INDEX IF NOT EXISTS idx_tag_tag ON tag(tag);

-- ── collection ── a named group of documents: a static list, or a saved
-- query re-evaluated on demand. The group primitive (see §10).
CREATE TABLE IF NOT EXISTS collection (
  id          INTEGER PRIMARY KEY,
  name        TEXT UNIQUE NOT NULL,
  kind        TEXT NOT NULL DEFAULT 'static',  -- static | query
  query       TEXT,               -- the filter, for kind='query'
  created_at  TEXT
);
CREATE TABLE IF NOT EXISTS collection_member (
  collection_id INTEGER NOT NULL REFERENCES collection(id),
  hash          TEXT NOT NULL REFERENCES document(hash),
  PRIMARY KEY (collection_id, hash)
);

-- ── audit ── append-only provenance log. Every index event lands here:
-- this is what makes reorganization traceable and reversible.
CREATE TABLE IF NOT EXISTS audit (
  id        INTEGER PRIMARY KEY,
  ts        TEXT NOT NULL,        -- ISO 8601 timestamp (UTC)
  event     TEXT NOT NULL,        -- indexed | moved | content-changed | missing | reappeared
  hash      TEXT,
  drive_id  TEXT,
  detail    TEXT
);
CREATE INDEX IF NOT EXISTS idx_audit_hash ON audit(hash);

-- ── text ── DEFERRED (Tier 1/2). Extracted document text for full-text
-- search. Present so enabling search later is a feature switch. Empty in v1.
CREATE TABLE IF NOT EXISTS text (
  hash         TEXT PRIMARY KEY REFERENCES document(hash),
  text_status  TEXT NOT NULL DEFAULT 'pending',  -- pending | extracted | needs-ocr | ocr-done | no-text
  content      TEXT,
  extracted_at TEXT
);

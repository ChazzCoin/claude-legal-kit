#!/usr/bin/env python3
"""
claude-legal-kit — document indexer (Tier 0).

Crawls a firm's drives and records metadata ABOUT each file into index.db —
never file content. See docs/ARCHITECTURE.md §10.

A document's identity is its content hash (SHA-256), not its path: the same
bytes in many places are one document with many instances. Re-crawling is
incremental (unchanged files are not re-hashed) and self-healing (a known
hash at a new path is recorded as a move, a vanished file as missing).

Cross-platform: pure Python standard library, runs identically on macOS and
Windows. No third-party packages.

Usage:
  indexer.py init   --db <index.db>
  indexer.py crawl  --db <index.db> <path> [--label NAME] [--kind KIND]
  indexer.py export --db <index.db> --out <derived.jsonl>
  indexer.py status --db <index.db>

`crawl` resolves the volume the <path> lives on, and stores every file's
location as a drive-relative path — so one index.db is correct on any
machine and either OS.
"""

import argparse
import ctypes
import datetime
import hashlib
import json
import os
import plistlib
import sqlite3
import subprocess
import sys
import uuid

SCHEMA_VERSION = 1
INDEXER_VERSION = "0.1.0"
HASH_CHUNK = 1024 * 1024  # 1 MiB
DRIVE_ID_MARKER = ".legal-drive-id"  # fallback identity, written at a volume root


# ── time helpers ────────────────────────────────────────────────────────────

def iso_date():
    return datetime.date.today().isoformat()


def iso_ts():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def iso_mtime(path):
    """Filesystem modified-time of `path`, as an ISO 8601 UTC timestamp."""
    ts = os.stat(path).st_mtime
    return datetime.datetime.fromtimestamp(
        ts, datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


# ── database ────────────────────────────────────────────────────────────────

def connect(db_path):
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def require_db(db_path):
    if not os.path.isfile(db_path):
        sys.exit("ERROR: no index at %s — run 'indexer.py init --db %s' first."
                 % (db_path, db_path))
    return connect(db_path)


def audit(conn, event, hash_=None, drive_id=None, detail=None):
    conn.execute(
        "INSERT INTO audit (ts, event, hash, drive_id, detail) VALUES (?,?,?,?,?)",
        (iso_ts(), event, hash_, drive_id, detail))


# ── volume identity ─────────────────────────────────────────────────────────
#
# A drive is identified by a STABLE volume id, never a mount path. Native
# resolution is tried first (a real volume UUID / serial survives even if the
# marker file is deleted); a generated id persisted at the volume root is the
# cross-platform fallback.

def mount_root(path):
    """The root of the volume that `path` lives on."""
    path = os.path.realpath(path)
    if os.name == "nt":
        drive = os.path.splitdrive(path)[0]
        return drive + os.sep if drive else path
    # POSIX: ascend until the mount point.
    while not os.path.ismount(path):
        parent = os.path.dirname(path)
        if parent == path:
            break
        path = parent
    return path


def _native_volume_id(root):
    """A real volume UUID / serial, or None if it can't be determined."""
    try:
        if sys.platform == "darwin":
            out = subprocess.check_output(
                ["diskutil", "info", "-plist", root], stderr=subprocess.DEVNULL)
            info = plistlib.loads(out)
            vid = info.get("VolumeUUID")
            return str(vid) if vid else None
        if os.name == "nt":
            serial = ctypes.c_ulong(0)
            ok = ctypes.windll.kernel32.GetVolumeInformationW(
                ctypes.c_wchar_p(root), None, 0, ctypes.byref(serial),
                None, None, None, 0)
            return ("WINSERIAL-%08X" % serial.value) if ok else None
    except (OSError, subprocess.CalledProcessError, ValueError, AttributeError):
        return None
    return None


def volume_id(path):
    """Resolve (id, source) for the volume `path` lives on.

    source is 'native' (a real volume UUID/serial) or 'marker' (a generated
    id persisted in <volume-root>/.legal-drive-id).
    """
    root = mount_root(path)
    native = _native_volume_id(root)
    if native:
        return native, "native"
    marker = os.path.join(root, DRIVE_ID_MARKER)
    try:
        with open(marker) as fh:
            existing = fh.read().strip()
        if existing:
            return existing, "marker"
    except OSError:
        pass
    generated = "GEN-" + uuid.uuid4().hex
    try:
        with open(marker, "w") as fh:
            fh.write(generated + "\n")
    except OSError:
        # Read-only volume — fall back to a path-derived stable id.
        return "PATH-" + hashlib.sha256(root.encode("utf-8")).hexdigest()[:24], "path"
    return generated, "marker"


# ── crawl helpers ───────────────────────────────────────────────────────────

def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(HASH_CHUNK), b""):
            h.update(chunk)
    return h.hexdigest()


def rel_posix(path, root):
    """`path` relative to `root`, as a POSIX-style ("/") string."""
    return os.path.relpath(path, root).replace(os.sep, "/")


def skip_name(name):
    """Dot-prefixed entries (.git, .DS_Store, .legal-drive-id, …) are skipped."""
    return name.startswith(".")


# ── commands ────────────────────────────────────────────────────────────────

def cmd_init(args):
    if os.path.exists(args.db):
        sys.exit("ERROR: %s already exists — refusing to overwrite an index." % args.db)
    schema_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql")
    if not os.path.isfile(schema_path):
        sys.exit("ERROR: schema.sql not found next to the indexer (%s)." % schema_path)
    with open(schema_path) as fh:
        schema = fh.read()
    conn = connect(args.db)
    conn.executescript(schema)
    for key, value in (("schema_version", str(SCHEMA_VERSION)),
                        ("indexer_version", INDEXER_VERSION),
                        ("created_at", iso_ts())):
        conn.execute("INSERT OR REPLACE INTO meta (key, value) VALUES (?, ?)",
                     (key, value))
    conn.commit()
    conn.close()
    print("Initialized empty index at %s (schema v%d)." % (args.db, SCHEMA_VERSION))


def cmd_crawl(args):
    target = os.path.realpath(args.path)
    if not os.path.isdir(target):
        sys.exit("ERROR: not a directory: %s" % args.path)
    conn = require_db(args.db)

    root = mount_root(target)
    drive, id_source = volume_id(target)
    today = iso_date()

    row = conn.execute("SELECT id FROM drive WHERE id = ?", (drive,)).fetchone()
    if row is None:
        label = args.label or os.path.basename(root.rstrip(os.sep)) or root
        conn.execute(
            "INSERT INTO drive (id, label, kind, first_seen, last_seen) "
            "VALUES (?,?,?,?,?)",
            (drive, label, args.kind, today, today))
    else:
        conn.execute("UPDATE drive SET last_seen = ? WHERE id = ?", (today, drive))
        if args.label:
            conn.execute("UPDATE drive SET label = ? WHERE id = ?", (args.label, drive))

    subtree_prefix = rel_posix(target, root)
    if subtree_prefix == ".":
        subtree_prefix = ""

    stats = dict(scanned=0, hashed=0, skipped=0, new_docs=0, new_inst=0,
                 changed=0, missing=0, moved=0)
    seen_rel = set()

    for dirpath, dirnames, filenames in os.walk(target):
        dirnames[:] = [d for d in dirnames if not skip_name(d)]
        for fn in filenames:
            if skip_name(fn):
                continue
            full = os.path.join(dirpath, fn)
            if not os.path.isfile(full) or os.path.islink(full):
                continue
            try:
                st = os.stat(full)
            except OSError:
                continue
            stats["scanned"] += 1
            rel = rel_posix(full, root)
            seen_rel.add(rel)
            mtime = datetime.datetime.fromtimestamp(
                st.st_mtime, datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

            inst = conn.execute(
                "SELECT id, hash, size, mtime FROM instance "
                "WHERE drive_id = ? AND rel_path = ?", (drive, rel)).fetchone()

            # Incremental: an unchanged size+mtime means unchanged content.
            if inst and inst["size"] == st.st_size and inst["mtime"] == mtime:
                conn.execute(
                    "UPDATE instance SET status='present', last_seen=? WHERE id=?",
                    (today, inst["id"]))
                stats["skipped"] += 1
                continue

            digest = sha256(full)
            stats["hashed"] += 1
            ext = os.path.splitext(fn)[1].lstrip(".").lower()

            doc = conn.execute("SELECT hash FROM document WHERE hash = ?",
                               (digest,)).fetchone()
            if doc is None:
                conn.execute(
                    "INSERT INTO document (hash, size, ext, first_seen) "
                    "VALUES (?,?,?,?)", (digest, st.st_size, ext, today))
                stats["new_docs"] += 1
                audit(conn, "indexed", digest, drive, rel)

            if inst is None:
                conn.execute(
                    "INSERT INTO instance (hash, drive_id, rel_path, name, mtime, "
                    "size, status, first_seen, last_seen) "
                    "VALUES (?,?,?,?,?,?,'present',?,?)",
                    (digest, drive, rel, fn, mtime, st.st_size, today, today))
                stats["new_inst"] += 1
            elif inst["hash"] != digest:
                # The file at this path changed content — repoint the instance.
                conn.execute(
                    "UPDATE instance SET hash=?, name=?, mtime=?, size=?, "
                    "status='present', last_seen=? WHERE id=?",
                    (digest, fn, mtime, st.st_size, today, inst["id"]))
                stats["changed"] += 1
                audit(conn, "content-changed", digest, drive,
                      "%s (was %s)" % (rel, inst["hash"][:12]))
            else:
                conn.execute(
                    "UPDATE instance SET mtime=?, size=?, status='present', "
                    "last_seen=? WHERE id=?",
                    (mtime, st.st_size, today, inst["id"]))

    # Vanished: instances under the crawled subtree, on this drive, not seen
    # this run. If the same content survives elsewhere in the index it is a
    # move or a duplicate deletion — no loss; otherwise it is genuinely
    # missing and needs attention.
    candidates = conn.execute(
        "SELECT id, hash, rel_path FROM instance "
        "WHERE drive_id = ? AND status = 'present'", (drive,)).fetchall()
    for c in candidates:
        rp = c["rel_path"]
        in_subtree = (not subtree_prefix
                      or rp == subtree_prefix
                      or rp.startswith(subtree_prefix + "/"))
        if not (in_subtree and rp not in seen_rel):
            continue
        conn.execute("UPDATE instance SET status='missing', last_seen=? "
                     "WHERE id=?", (today, c["id"]))
        survives = conn.execute(
            "SELECT COUNT(*) FROM instance WHERE hash = ? AND status = 'present'",
            (c["hash"],)).fetchone()[0]
        if survives:
            stats["moved"] += 1
            audit(conn, "moved", c["hash"], drive,
                  "%s vanished; content still indexed elsewhere" % rp)
        else:
            stats["missing"] += 1
            audit(conn, "missing", c["hash"], drive, rp)

    conn.commit()
    conn.close()

    print("Crawled %s" % target)
    print("  drive:    %s  (id source: %s)" % (drive, id_source))
    print("  scanned:  %d files   hashed: %d   unchanged: %d"
          % (stats["scanned"], stats["hashed"], stats["skipped"]))
    print("  new:      %d documents, %d instances" % (stats["new_docs"], stats["new_inst"]))
    print("  changed:  %d   missing: %d   moved/copied: %d"
          % (stats["changed"], stats["missing"], stats["moved"]))


def cmd_export(args):
    conn = require_db(args.db)
    # The durable, human-inspectable layer: the work that cost something to
    # produce. The mechanical crawl layer is regenerable and is not exported.
    written = 0
    with open(args.out, "w") as fh:
        for d in conn.execute(
                "SELECT hash, doc_type, matter FROM document "
                "WHERE doc_type IS NOT NULL OR matter IS NOT NULL").fetchall():
            tags = [t["tag"] for t in conn.execute(
                "SELECT tag FROM tag WHERE hash = ? ORDER BY tag", (d["hash"],))]
            fh.write(json.dumps({
                "record": "document", "hash": d["hash"],
                "doc_type": d["doc_type"], "matter": d["matter"], "tags": tags
            }) + "\n")
            written += 1
        for c in conn.execute(
                "SELECT id, name, kind, query FROM collection ORDER BY name").fetchall():
            members = [m["hash"] for m in conn.execute(
                "SELECT hash FROM collection_member WHERE collection_id = ?",
                (c["id"],))]
            fh.write(json.dumps({
                "record": "collection", "name": c["name"], "kind": c["kind"],
                "query": c["query"], "members": members
            }) + "\n")
            written += 1
    conn.close()
    print("Exported %d derived record(s) to %s" % (written, args.out))


def cmd_status(args):
    conn = require_db(args.db)

    def scalar(sql, *params):
        return conn.execute(sql, params).fetchone()[0]

    print("Index: %s" % args.db)
    print("  schema:      v%s" % (conn.execute(
        "SELECT value FROM meta WHERE key='schema_version'").fetchone()[0]))
    print("  documents:   %d" % scalar("SELECT COUNT(*) FROM document"))
    print("  instances:   %d present, %d missing"
          % (scalar("SELECT COUNT(*) FROM instance WHERE status='present'"),
             scalar("SELECT COUNT(*) FROM instance WHERE status='missing'")))
    dupes = scalar("SELECT COUNT(*) FROM (SELECT hash FROM instance "
                   "WHERE status='present' GROUP BY hash HAVING COUNT(*) > 1)")
    print("  duplicated:  %d document(s) with more than one present copy" % dupes)
    print("  drives:      %d" % scalar("SELECT COUNT(*) FROM drive"))
    for d in conn.execute("SELECT id, label FROM drive ORDER BY label").fetchall():
        n = scalar("SELECT COUNT(*) FROM instance WHERE drive_id=?", d["id"])
        print("    - %s  [%s]  %d instance(s)" % (d["label"] or "(unlabeled)",
                                                  d["id"], n))
    print("  audit log:   %d event(s)" % scalar("SELECT COUNT(*) FROM audit"))
    conn.close()


# ── entry point ─────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        prog="indexer.py", description="claude-legal-kit document indexer (Tier 0).")
    sub = parser.add_subparsers(dest="command", required=True)

    p_init = sub.add_parser("init", help="create an empty index.db")
    p_init.add_argument("--db", required=True)
    p_init.set_defaults(func=cmd_init)

    p_crawl = sub.add_parser("crawl", help="crawl a directory into the index")
    p_crawl.add_argument("--db", required=True)
    p_crawl.add_argument("path", help="directory to crawl")
    p_crawl.add_argument("--label", help="human label for the drive")
    p_crawl.add_argument("--kind", default="",
                         help="internal | external-ssd | usb-flash | cloud-sync | network-share")
    p_crawl.set_defaults(func=cmd_crawl)

    p_export = sub.add_parser("export", help="export the derived layer as JSONL")
    p_export.add_argument("--db", required=True)
    p_export.add_argument("--out", required=True)
    p_export.set_defaults(func=cmd_export)

    p_status = sub.add_parser("status", help="print a summary of the index")
    p_status.add_argument("--db", required=True)
    p_status.set_defaults(func=cmd_status)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()

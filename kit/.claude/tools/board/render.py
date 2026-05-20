#!/usr/bin/env python3
"""Firm board renderer — Phase 5 TV dashboard.

Reads the firm's inbox folders and renders an HTML page sized for a TV
viewed from across a room. Standard library only.

Usage:
    render.py index               # firm directory page (lists views)
    render.py shared              # the shared-inbox view
    render.py member <key>        # a member's personal view

Honors $CLAUDE_PROJECT_DIR; otherwise walks up from this file looking for
a sibling .claude/ to locate the firm home.
"""

import argparse
import html
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path


# ---------------------------------------------------------------------------
# Firm-home resolution
# ---------------------------------------------------------------------------

def firm_root():
    """Resolve the firm-home root.

    1. $CLAUDE_PROJECT_DIR if set.
    2. Otherwise walk up from this script looking for a .claude/ directory.
    """
    env = os.environ.get("CLAUDE_PROJECT_DIR")
    if env:
        p = Path(env).resolve()
        if p.is_dir():
            return p
    here = Path(__file__).resolve().parent
    for ancestor in [here, *here.parents]:
        if (ancestor / ".claude").is_dir() and (ancestor / "firm").is_dir():
            return ancestor
    raise SystemExit("board: could not resolve firm-home root")


# ---------------------------------------------------------------------------
# Data loaders
# ---------------------------------------------------------------------------

def load_firm_name(root):
    firm_md = root / "firm" / "FIRM.md"
    if firm_md.is_file():
        try:
            for line in firm_md.read_text(encoding="utf-8", errors="replace").splitlines():
                line = line.strip()
                if line.startswith("# "):
                    name = line[2:].strip()
                    # Strip placeholder braces like {{FIRM_NAME}} → leave as-is
                    if name:
                        return name
        except OSError:
            pass
    return "Firm Board"


def load_users(root):
    """Return {key: user_dict} from members/users.json (schema v2 tolerated)."""
    users_file = root / "members" / "users.json"
    if not users_file.is_file():
        return {}
    try:
        data = json.loads(users_file.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    out = {}
    for u in data.get("users", []):
        key = u.get("key")
        if key:
            out[key] = u
    return out


def parse_note(path):
    """Parse a single note file. Returns {from, at, body, file} or None.

    Supports optional YAML-style frontmatter:
        ---
        from: alice
        at: 2026-05-19T14:30:00
        ---
        body...

    Falls back to filesystem mtime and a dash for sender when absent.
    """
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None

    meta = {}
    body = text
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end != -1:
            fm_block = text[4:end]
            body = text[end + 5:]
            for line in fm_block.splitlines():
                if ":" in line:
                    k, v = line.split(":", 1)
                    meta[k.strip().lower()] = v.strip()

    if "at" not in meta:
        try:
            mtime = path.stat().st_mtime
            meta["at"] = datetime.fromtimestamp(mtime, tz=timezone.utc).isoformat()
        except OSError:
            meta["at"] = ""
    if "from" not in meta:
        meta["from"] = "—"

    return {
        "from": meta["from"],
        "at": meta["at"],
        "body": body.strip(),
        "file": path.name,
    }


def load_inbox(root, target):
    """target = 'shared' for members/shared-inbox; else a member key."""
    if target == "shared":
        d = root / "members" / "shared-inbox"
    else:
        d = root / "members" / target / "inbox"
    if not d.is_dir():
        return []
    notes = []
    for entry in sorted(d.iterdir()):
        if not entry.is_file():
            continue
        if entry.name.startswith(".") or entry.name.lower() == "readme.md":
            continue
        if entry.name.endswith(".gitkeep"):
            continue
        n = parse_note(entry)
        if n:
            notes.append(n)
    notes.sort(key=lambda n: n["at"] or "", reverse=True)
    return notes


# ---------------------------------------------------------------------------
# Presentation helpers
# ---------------------------------------------------------------------------

def time_ago(iso_at):
    if not iso_at:
        return ""
    try:
        s = iso_at.replace("Z", "+00:00")
        dt = datetime.fromisoformat(s)
    except ValueError:
        return ""
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    delta = datetime.now(tz=timezone.utc) - dt
    secs = int(delta.total_seconds())
    if secs < 0:
        return "just now"
    if secs < 60:
        return "just now"
    if secs < 3600:
        return f"{secs // 60}m ago"
    if secs < 86400:
        return f"{secs // 3600}h ago"
    return f"{secs // 86400}d ago"


def today_long():
    # Avoid %-d (BSD/Linux only) and %#d (Windows) — compose the day-of-month manually.
    now = datetime.now()
    return now.strftime("%A, %B ") + str(now.day)


# ---------------------------------------------------------------------------
# Template
# ---------------------------------------------------------------------------

CSS = """
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body {
  background: #0a0e1a;
  color: #e8e4d8;
  font-family: -apple-system, "SF Pro Text", "Segoe UI", system-ui, sans-serif;
  font-size: 28px;
  line-height: 1.5;
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
}
body {
  display: flex;
  flex-direction: column;
}
header {
  display: grid;
  grid-template-columns: 1.2fr 1fr 1fr;
  align-items: center;
  padding: 48px 72px 32px;
  border-bottom: 1px solid #1f2638;
  gap: 32px;
}
.firm {
  font-family: Georgia, "Iowan Old Style", "Times New Roman", serif;
  font-size: 56px;
  color: #c9a961;
  letter-spacing: 0.02em;
  line-height: 1.1;
}
.viewer {
  font-family: Georgia, serif;
  font-size: 38px;
  text-align: center;
  font-style: italic;
  color: #b8b09c;
  line-height: 1.2;
}
.clock-wrap { text-align: right; }
.clock {
  font-size: 56px;
  font-weight: 200;
  letter-spacing: 0.02em;
  font-feature-settings: "tnum";
  color: #e8e4d8;
}
.date {
  font-size: 24px;
  color: #9a9385;
  margin-top: 4px;
  letter-spacing: 0.05em;
}
main {
  flex: 1;
  padding: 48px 72px 64px;
  max-width: 1680px;
  width: 100%;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 28px;
}
.section-label {
  font-family: Georgia, serif;
  font-size: 22px;
  font-style: italic;
  color: #6b6557;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  margin-bottom: 4px;
}
.note {
  background: #131826;
  border-left: 4px solid #c9a961;
  padding: 28px 36px;
  border-radius: 4px;
}
.note-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 16px;
  gap: 24px;
}
.note-from {
  font-family: Georgia, serif;
  font-size: 30px;
  color: #c9a961;
}
.note-at {
  font-size: 22px;
  color: #7f7867;
  font-variant-numeric: tabular-nums;
}
.note-body {
  font-size: 26px;
  line-height: 1.55;
  white-space: pre-wrap;
  color: #e8e4d8;
}
.empty {
  text-align: center;
  padding: 120px 0 80px;
  font-family: Georgia, serif;
  font-style: italic;
  font-size: 36px;
  color: #5a5448;
}
.index-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 20px;
  max-width: 800px;
  margin: 0 auto;
}
.index-link {
  display: block;
  background: #131826;
  padding: 28px 36px;
  border-radius: 4px;
  color: #e8e4d8;
  text-decoration: none;
  font-size: 30px;
  font-family: Georgia, serif;
  border-left: 4px solid #c9a961;
}
.index-link span {
  color: #7f7867;
  font-size: 22px;
  font-family: -apple-system, sans-serif;
  font-style: normal;
  margin-left: 12px;
}
"""

CLOCK_JS = """
function pad(n) { return String(n).padStart(2, '0'); }
function tick() {
  var d = new Date();
  var el = document.getElementById('clock');
  if (el) el.textContent = pad(d.getHours()) + ':' + pad(d.getMinutes());
}
tick();
setInterval(tick, 30000);
"""

PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="60">
  <title>{title}</title>
  <style>{css}</style>
</head>
<body>
  <header>
    <div class="firm">{firm_name}</div>
    <div class="viewer">{viewer}</div>
    <div class="clock-wrap">
      <div class="clock" id="clock">&nbsp;</div>
      <div class="date">{date}</div>
    </div>
  </header>
  <main>
    {body}
  </main>
  <script>{js}</script>
</body>
</html>
"""


# ---------------------------------------------------------------------------
# Renderers
# ---------------------------------------------------------------------------

def render_notes(notes):
    if not notes:
        return '<div class="empty">No messages.</div>'
    parts = ['<div class="section-label">Inbox</div>']
    for n in notes:
        parts.append(
            '<div class="note">'
            '<div class="note-head">'
            f'<div class="note-from">{html.escape(n["from"])}</div>'
            f'<div class="note-at">{html.escape(time_ago(n["at"]))}</div>'
            '</div>'
            f'<div class="note-body">{html.escape(n["body"])}</div>'
            '</div>'
        )
    return "\n".join(parts)


def render_member(root, key):
    users = load_users(root)
    user = users.get(key)
    if user is None:
        viewer = key
    else:
        name = user.get("name") or key
        role = user.get("role") or ""
        viewer = name + (f" — {role}" if role else "")
    notes = load_inbox(root, key)
    return PAGE.format(
        title=f"{viewer} — Board",
        css=CSS,
        js=CLOCK_JS,
        firm_name=html.escape(load_firm_name(root)),
        viewer=html.escape(viewer),
        date=html.escape(today_long()),
        body=render_notes(notes),
    )


def render_shared(root):
    notes = load_inbox(root, "shared")
    return PAGE.format(
        title="Firm Board",
        css=CSS,
        js=CLOCK_JS,
        firm_name=html.escape(load_firm_name(root)),
        viewer="Firm",
        date=html.escape(today_long()),
        body=render_notes(notes),
    )


def render_index(root):
    users = load_users(root)
    items = ['<a class="index-link" href="/shared">Firm <span>/shared</span></a>']
    for key in sorted(users.keys()):
        u = users[key]
        if (u.get("status") or "active") != "active":
            continue
        name = u.get("name") or key
        items.append(
            f'<a class="index-link" href="/m/{html.escape(key)}">'
            f'{html.escape(name)} <span>/m/{html.escape(key)}</span></a>'
        )
    body = (
        '<div class="section-label">Views</div>'
        '<div class="index-grid">' + "\n".join(items) + '</div>'
    )
    return PAGE.format(
        title="Firm Board",
        css=CSS,
        js=CLOCK_JS,
        firm_name=html.escape(load_firm_name(root)),
        viewer="Directory",
        date=html.escape(today_long()),
        body=body,
    )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main(argv=None):
    p = argparse.ArgumentParser(description="Firm board renderer.")
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("index", help="firm directory page")
    sub.add_parser("shared", help="the shared-inbox view")
    pm = sub.add_parser("member", help="a member's personal view")
    pm.add_argument("key")
    args = p.parse_args(argv)

    root = firm_root()
    if args.cmd == "index":
        sys.stdout.write(render_index(root))
    elif args.cmd == "shared":
        sys.stdout.write(render_shared(root))
    elif args.cmd == "member":
        sys.stdout.write(render_member(root, args.key))


if __name__ == "__main__":
    main()

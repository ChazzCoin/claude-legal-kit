# .claude/tools/board/ — the firm board (Phase 5)

A tiny LAN web page sized for a TV. The firm's inbox messages, rendered
large and legible, viewable from across a room.

> Run by the `/setup-board-host` and `/setup-tv` skills. Read those for the
> end-to-end flow; this README covers what the tool *is*.

## What it is

- **`render.py`** — generates the HTML for a given view (the shared
  firm-wide view, or one member's personal view).
- **`serve.py`** — a tiny HTTP server (`http.server`, standard library)
  that runs on one always-on machine in the office and re-renders on each
  request. Side thread: periodic `git pull` so notes pushed from members'
  laptops appear without anyone touching the host.

Both are pure Python standard library — no third-party packages.

## What it shows — v1

The board reads what already exists in a firm home: the inbox folders.

- **`/shared`** — `members/shared-inbox/` (the reception / common-area
  view).
- **`/m/<member-key>`** — `members/<key>/inbox/` (that member's personal
  view, for their own TV).
- **`/`** — a directory listing every available view.

A "message" is any text file in one of those folders. Optional
YAML-style frontmatter is honored:

```
---
from: alice
at: 2026-05-19T14:30:00
---
Hey, I left the Henderson depo in the file exchange.
```

If frontmatter is absent, the file's mtime is used for the timestamp and
the sender shows as "—".

Future tiers plug in here — calendar / deadlines, client birthdays from
`firm/clients/`, matter status — as those data sources land in the kit.
v1 deliberately covers only the inboxes, which already exist and work.

## Design

- **Dark theme, restrained palette** — deep navy background, warm
  off-white text, muted gold accents. Looks like a law-firm letterhead,
  not a gamer dashboard; easier on eyes from across a room; gentler on
  OLED panels.
- **Serif headers, sans body** — system fonts only, no downloads.
- **Sized for 15 feet** — 28px body, 56px firm name. A TV is a 65-inch
  monitor viewed from across the room; this is necessary, not large.
- **No JS framework, no images, no analytics, no external requests.**
  ~15 lines of vanilla JS for the live clock; everything else is HTML +
  CSS.
- **Refresh via `<meta refresh content="60">`** — the dumbest possible
  auto-update, which is the right call for v1.
- **`Cache-Control: no-store`** — TVs sit on a single URL for days;
  caching would silently stale them.

## Running it

`/setup-board-host` configures launchd to run this automatically and
keep it alive across reboots. To invoke it directly for testing:

```sh
python3 kit/.claude/tools/board/serve.py --port 8080
```

Render one view to stdout (useful for debugging the HTML):

```sh
python3 kit/.claude/tools/board/render.py shared
python3 kit/.claude/tools/board/render.py member alice
python3 kit/.claude/tools/board/render.py index
```

Both scripts resolve the firm-home root from `$CLAUDE_PROJECT_DIR` if
set, otherwise by walking up from this file looking for a sibling
`.claude/`.

## Platform

v1 ships a macOS launchd install path via `/setup-board-host`. The
server code itself is OS-agnostic (`http.server` is in the standard
library and works on Linux and Windows identically); only the
auto-start integration is platform-specific. A Linux systemd install is
straightforward to add when needed; Windows Task Scheduler likewise.

## What does **not** belong on the board

TVs are visible — visitors, cleaning staff, anyone walking by. The
board carries inbox messages, firm-internal notes, and calendar items.
It does **not** carry matter content, client documents, or privileged
work product. The design enforces this by what it reads (inboxes, not
matter folders); the social rule reinforces it.

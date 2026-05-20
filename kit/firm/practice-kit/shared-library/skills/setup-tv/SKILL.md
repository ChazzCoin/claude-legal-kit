---
name: setup-tv
description: Point a TV at the firm board so it shows that member's inbox messages — walks the member through the one-time TV setup and confirms the TV connected
status: authored 2026-05-19
---

# /setup-tv

Connects a TV to the **firm board** — the small web page that displays
inbox messages large enough to read from across a room. After this
runs once on a given TV, the TV just works: it boots, loads the board,
and new messages appear without anyone touching anything.

This skill is run by a **member** on their laptop. The board itself
must already be running on the firm's host Mac — if it isn't, that's
`/setup-board-host` first.

## How a TV connects (so Claude can explain it correctly)

There is one always-on Mac in the office serving the board over the
firm's LAN. Every TV has a small browser — either built in (some smart
TVs) or via a $30 dongle plugged into HDMI (Chromecast with Google TV,
Fire Stick, Apple TV with a browser app). The TV opens the board's URL
once, the browser is set to load it on boot, and that's it. The TV
sits on that page and the page auto-refreshes every 60 seconds.

The seamless part is what happens *after* setup. The setup itself has
one irreducible step: someone has to type the URL into the TV's
browser. Claude walks the member through it and confirms it landed.

## When to use

- A new TV is being added to the firm.
- A member's TV was replaced and needs to be re-connected.
- A TV stopped showing the board and needs to be re-pointed.

## When NOT to use

- To set up the host Mac that serves the board — that's
  `/setup-board-host`.
- To send a message to someone — that's just dropping a note in
  `members/<them>/inbox/`. The board renders it automatically; no
  separate "publish" step.

## What Claude needs to know first

- **Which member's TV** this is. If the session identity is verified
  (SSH-fingerprint binding from `members/users.json`), default to that
  member and confirm; otherwise ask.
- **What kind of device** the TV uses to browse the web. Options to
  offer: Chromecast with Google TV, Fire Stick / Fire TV, Apple TV,
  smart TV's built-in browser, or "other / unsure." Instructions
  branch from there.
- **The board's host URL.** Read it from the firm if known (the
  administrator should have published it after `/setup-board-host`).
  If it isn't known, ask plainly. Format: `http://<host>.local:<port>`
  or `http://<ip>:<port>`.

## Flow

### Step 1 — Identify who and where

- Confirm the member. Default to the verified session identity if
  available.
- Compute their personal URL: `<board>/m/<member-key>`. For a common-
  area TV in reception, use `<board>/shared` instead — ask which.
- Verify the board is reachable from this laptop:
  `curl -fsS <board>/status` should return `"ok": true`. If not, stop
  and tell the member the host is down — they need to ask the
  administrator to check it.

### Step 2 — Ask which device the TV uses

Offer the four common options listed above. The walkthrough in Step 3
depends on the answer; if it's "other / unsure," ask the member to
look at what's plugged into the TV's HDMI port or what comes up when
they press the input button.

### Step 3 — Walk through the TV-side setup

Hand the member a short, plain-English checklist for their device.
Common shape:

1. On the TV, open the device's web browser app (install one if needed
   — Silk on Fire Stick, the Google TV browser app, etc.).
2. Enter the URL exactly: **`<board>/m/<member-key>`** (or
   `<board>/shared` for a common-area TV).
3. When the board loads, bookmark it / pin it / set it as the home
   page so it loads on boot.
4. Turn off the screensaver (or set a long timeout), and disable
   sleep-when-idle if the device offers it — the board needs to stay
   visible.

Don't dump every device's exact menu paths — devices change. Give the
high-level steps and let the member find the menu items.

### Step 4 — Confirm the TV connected

This is the seamless part. The board's host machine writes every
request to `~/Library/Logs/firm-board.out.log`. While the member is
finishing setup, Claude can:

- Ask the administrator to tail the log on the host:
  `tail -F ~/Library/Logs/firm-board.out.log | grep "/m/<member-key>"`.
- Or, if Claude has access to the host (e.g., this is the
  administrator's session), do that directly.
- When a new request to `/m/<member-key>` comes in from a LAN IP that
  isn't this laptop's, that's the TV connecting. Confirm: *"A new
  device at 192.168.x.y just loaded your view — that should be your
  TV."*

If the member doesn't have host access, fall back to a manual
confirmation: the member walks across the room, looks at the TV,
confirms the board is showing.

### Step 5 — Sanity-check the display

Ask the member to look at the TV from where it normally lives in the
room (not from a foot away). Confirm:

- Their name appears in the header.
- The clock is correct.
- If there are messages in their inbox, they're readable from across
  the room.

If text is too small to read from the normal viewing distance, that's
a real bug — note it for follow-up; don't tell the member their eyes
are wrong. (The design targets ~15 feet at 1920×1080; rooms with
larger viewing distances may need a v2 zoom setting.)

### Step 6 — Hand off

Tell the member, in plain English:

- The TV will keep showing this view until something explicitly
  changes it.
- New messages dropped in their inbox will appear within ~60 seconds.
- To send someone else a message, drop a file in
  `members/<them>/inbox/` and push — same as before. The TV doesn't
  change anything about *sending*.

## Outputs

- A TV pointed at the member's personal board view (or the shared
  view, for a common-area TV).
- A verified-from-the-log confirmation that the TV reached the page.

## Failure modes

- **Board is down** — `curl /status` fails. Stop; the member can't fix
  this from their laptop. Tell them to ask the administrator to
  re-run `/setup-board-host` or check `~/Library/Logs/firm-board.err.log`.
- **TV browser is too old to render the page** — modern HTML/CSS only,
  but some TV native browsers are surprisingly broken. Recommend a $30
  Chromecast with Google TV or Fire Stick and try again.
- **URL is reachable from the laptop but not the TV** — different
  network. Confirm the TV is on the same Wi-Fi as the host Mac. Guest
  networks usually can't reach the main LAN.
- **TV keeps falling asleep** — most device-side settings; point the
  member at the device's screensaver / auto-sleep controls.

## Don't do this

- **Don't promise the setup is fully automatic.** It isn't — there's
  one URL the member has to enter on the TV. Be honest about that;
  the *after* is seamless, the *first time* takes 90 seconds.
- **Don't make up the URL.** If the board's host URL isn't known, ask.
- **Don't try to "fix" the host from a member's laptop.** If the board
  is down, that's the administrator's job, not the member's.
- **Don't store anything per-TV in `users.json` or anywhere else.** A
  TV is just a browser pointed at a URL. There's no per-TV state to
  manage; that's the whole point of the design.

---
name: setup-board-host
description: Set up the firm board on this Mac — the small always-on web page that displays each member's inbox messages on their TV
status: authored 2026-05-19
---

# /setup-board-host

Turns this Mac into the firm's **board host** — a small web server that
renders inbox messages as a TV-friendly page. After this runs once, the
board is running, comes back on every reboot, and members can point
their TVs at it with `/setup-tv`.

This skill is run by an **administrator** on the machine that will host
the board (the always-on office Mac — reception, a dedicated Mac mini,
or any Mac that stays awake during the workday).

## What the board is (so Claude can explain it correctly)

A tiny web page sized for a TV viewed from across a room. It reads the
firm's existing inbox folders — `members/<key>/inbox/` for each person,
`members/shared-inbox/` for the firm-wide view — and renders them large
and legible. Messages already work the way they always have (drop a
file in someone's inbox, push). The board is a new *view* of those
messages, not a new way to send them.

The board lives at `kit/.claude/tools/board/` in the firm home — two
small Python scripts, standard library only.

## When to use

- The firm is setting up the TV-board feature for the first time.
- The board's host machine has been replaced and needs to be re-set-up.
- The board stopped serving and Claude is being asked to fix it (this
  skill is idempotent — re-running it repairs the install).

## When NOT to use

- To onboard a new member's TV — that's `/setup-tv`.
- On a member's laptop — the host is one always-on machine, not every
  member's computer.

## What Claude needs to know first

- **The platform.** v1 ships the macOS install path (launchd). On Linux
  or Windows, stop and say so — the engine works on those platforms,
  but the auto-start integration here is mac-only for now.
- **Which port to use.** Default 8080. If something else is on 8080 on
  this machine, pick another (8081, 8088). Claude can check by trying a
  TCP connect to `127.0.0.1:<port>` — refused means free.
- **Whether the firm home git repo is on this machine.** The board
  reads from it and `git pull`s periodically. If this machine doesn't
  have the firm repo cloned, stop and resolve that first — it's not a
  board problem.

## Flow

### Step 1 — Verify the environment

- Confirm macOS (`uname -s` returns `Darwin`). If not, stop and
  explain.
- Confirm Python 3 is available (`python3 --version`).
- Confirm this is a firm home — `.claude/foundation.json` exists, or
  `$CLAUDE_PROJECT_DIR` is set.
- Confirm `kit/.claude/tools/board/serve.py` exists (the engine).

If any of these is wrong, stop with a plain explanation. Don't try to
"fix" a missing foundation file or install Python silently.

### Step 2 — Confirm before installing

This is a deliberate action — it installs a launchd agent that will
start automatically at every login. Ask the administrator for an
explicit go-ahead. The permission line reads:

> *"Claude wants to install the firm board as a background service on
> this Mac, so it starts automatically and stays running."*

If they say no, stop. Don't write any files.

### Step 3 — Pick the port

Default 8080. Check if it's free; if not, propose the next free port
(8081, 8088). Confirm with the administrator before continuing.

### Step 4 — Write the launchd plist

Write `~/Library/LaunchAgents/com.firm.board.plist` with this shape
(substitute the resolved firm-home path and the chosen port):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>            <string>com.firm.board</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/python3</string>
    <string>FIRM_HOME/.claude/tools/board/serve.py</string>
    <string>--port</string><string>PORT</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>CLAUDE_PROJECT_DIR</key><string>FIRM_HOME</string>
  </dict>
  <key>WorkingDirectory</key>  <string>FIRM_HOME</string>
  <key>RunAtLoad</key>         <true/>
  <key>KeepAlive</key>         <true/>
  <key>StandardOutPath</key>   <string>HOME/Library/Logs/firm-board.out.log</string>
  <key>StandardErrorPath</key> <string>HOME/Library/Logs/firm-board.err.log</string>
</dict>
</plist>
```

Substitute `FIRM_HOME`, `PORT`, and `HOME` with the resolved absolute
paths. Use `/usr/bin/python3` (always present on modern macOS); if it
isn't, fall back to the path `which python3` returns.

### Step 5 — Load it and verify

- If a previous instance is loaded, unload it first:
  `launchctl unload ~/Library/LaunchAgents/com.firm.board.plist` (ignore
  errors).
- Load it: `launchctl load -w ~/Library/LaunchAgents/com.firm.board.plist`.
- Wait a moment and verify the server responds:
  `curl -fsS http://127.0.0.1:<port>/status` should return JSON with
  `"ok": true`.

If `/status` doesn't respond within ~5 seconds, tail
`~/Library/Logs/firm-board.err.log` and report what it says. Don't
loop silently.

### Step 6 — Tell the administrator the URLs

Print, in plain English:

- **The host's `.local` URL** — `http://$(hostname -s).local:<port>/`.
  This is what members will point their TVs at. Verify the hostname
  resolves on the LAN (`ping -c 1 $(hostname -s).local`); if it
  doesn't, fall back to the LAN IP from `ipconfig getifaddr en0` (or
  `en1` on machines that use Wi-Fi as the primary).
- **A note on the views:**
  - `/shared` — the reception / common-area view.
  - `/m/<member-key>` — each member's personal view.
  - `/` — directory of available views.

Suggest the administrator commit a brief note to the firm with the
host URL so `/setup-tv` can use it directly.

### Step 7 — Hand off

The board is up. Tell the administrator:

1. To onboard a TV, run `/setup-tv` from any laptop.
2. Logs live at `~/Library/Logs/firm-board.{out,err}.log` if anything
   needs debugging.
3. The board polls `git pull` every 60s — notes pushed from other
   machines appear on the next refresh cycle.

## Outputs

- A launchd agent at `~/Library/LaunchAgents/com.firm.board.plist`
  running as the logged-in user.
- The board server bound on the LAN at the chosen port.
- A clear URL the administrator can share with members.

## Failure modes

- **Not macOS** — stop with a plain explanation. The engine works on
  Linux/Windows, but this skill's install path is mac-only for now.
- **Port in use** — propose another port; don't pick one silently.
- **Hostname doesn't resolve on the LAN** — fall back to the IP, and
  note this for the administrator (a fixed hostname will be more robust
  if they can arrange it via DHCP).
- **`/status` doesn't respond after load** — show the contents of
  `firm-board.err.log` and stop. Common causes: Python path wrong,
  firm-home path wrong, port conflict.
- **Firm repo not cloned here** — stop and explain. The host needs the
  firm repo to read inboxes.

## Don't do this

- **Don't write the plist or run `launchctl load` without an explicit
  go-ahead.** Installing a background service is a deliberate action.
- **Don't `sudo` anything.** This is a user LaunchAgent, not a
  system-wide LaunchDaemon. The board runs as the logged-in user.
- **Don't auto-pick a port if the default is busy.** Ask.
- **Don't open the port in the firewall on the administrator's
  behalf.** If macOS firewall blocks the port, surface that as a thing
  the administrator decides.

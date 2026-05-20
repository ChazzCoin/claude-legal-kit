#!/usr/bin/env python3
"""Firm board HTTP server — Phase 5 TV dashboard.

A tiny LAN HTTP server that renders the board on demand. Standard library
only. Designed to run on one always-on machine in the office; each TV's
browser bookmarks one of the URLs it serves and auto-refreshes.

Routes:
    GET /              — directory (lists shared + every active member)
    GET /shared        — the firm-wide view (members/shared-inbox)
    GET /m/<key>       — a member's personal view (members/<key>/inbox)
    GET /status        — JSON health probe (used by /setup-board-host)
    GET /favicon.ico   — 204

Side thread: periodically runs `git pull` so notes pushed from members'
laptops appear without anyone touching the host.

Honors $CLAUDE_PROJECT_DIR to find the firm home; otherwise walks up from
this file like render.py does.
"""

import argparse
import http.server
import json
import socketserver
import subprocess
import sys
import threading
import time
from pathlib import Path

# render.py lives next to this file
sys.path.insert(0, str(Path(__file__).resolve().parent))
import render  # noqa: E402


class BoardHandler(http.server.BaseHTTPRequestHandler):
    server_version = "FirmBoard/0.7"

    def log_message(self, fmt, *args):
        sys.stderr.write(
            "[board] %s - %s\n" % (self.address_string(), fmt % args)
        )

    def do_GET(self):
        try:
            self._route()
        except Exception as exc:  # noqa: BLE001
            self._send(500, ("error: %s" % exc).encode("utf-8"), "text/plain")

    def _route(self):
        root = render.firm_root()
        path = self.path.split("?", 1)[0].rstrip("/")
        if path == "" or path == "/":
            self._html(render.render_index(root))
        elif path == "/shared":
            self._html(render.render_shared(root))
        elif path.startswith("/m/"):
            key = path[3:]
            # Defensive: reject anything that isn't a plain key
            if not key or "/" in key or ".." in key:
                self._send(404, b"not found", "text/plain")
                return
            self._html(render.render_member(root, key))
        elif path == "/status":
            payload = json.dumps({
                "ok": True,
                "firm_home": str(root),
                "now": time.time(),
            }).encode("utf-8")
            self._send(200, payload, "application/json")
        elif path == "/favicon.ico":
            self.send_response(204)
            self.end_headers()
        else:
            self._send(404, b"not found", "text/plain")

    def _html(self, body):
        self._send(200, body.encode("utf-8"), "text/html; charset=utf-8")

    def _send(self, code, body, ctype):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass


class ThreadedTCPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    allow_reuse_address = True
    daemon_threads = True


def git_pull_loop(root, interval):
    """Best-effort `git pull` in the firm-home repo, every `interval` seconds.

    Failures are swallowed — the board keeps serving whatever's on disk.
    """
    while True:
        try:
            subprocess.run(
                ["git", "pull", "--quiet", "--ff-only"],
                cwd=str(root),
                timeout=30,
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception:  # noqa: BLE001
            pass
        time.sleep(interval)


def main(argv=None):
    p = argparse.ArgumentParser(description="Firm board HTTP server.")
    p.add_argument("--port", type=int, default=8080,
                   help="port to bind (default 8080)")
    p.add_argument("--bind", default="0.0.0.0",
                   help="address to bind (default 0.0.0.0 — all LAN interfaces)")
    p.add_argument("--pull-interval", type=int, default=60,
                   help="seconds between `git pull`s; 0 disables (default 60)")
    args = p.parse_args(argv)

    root = render.firm_root()

    if args.pull_interval > 0:
        t = threading.Thread(
            target=git_pull_loop,
            args=(root, args.pull_interval),
            daemon=True,
            name="git-pull",
        )
        t.start()

    sys.stderr.write("[board] firm-home: %s\n" % root)
    sys.stderr.write("[board] listening on %s:%d\n" % (args.bind, args.port))
    sys.stderr.flush()

    with ThreadedTCPServer((args.bind, args.port), BoardHandler) as srv:
        try:
            srv.serve_forever()
        except KeyboardInterrupt:
            sys.stderr.write("[board] shutting down\n")


if __name__ == "__main__":
    main()

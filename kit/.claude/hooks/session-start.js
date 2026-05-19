#!/usr/bin/env node
//
// SessionStart identity hook — claude-legal-kit.
//
// Runs deterministically at the start of every Claude Code session in a firm
// home. Claude Code triggers it; the assistant does not, and cannot skip it.
// It resolves the active user from the per-machine marker
// (.claude/current-user) against the firm's user directory
// (members/users.json), and either:
//
//   - known user   -> prints identity, role, and conduct mode as session
//                     context, so the assistant starts oriented; exit 0.
//   - unknown user -> halts the session and points at the setup script;
//                     exit 2.
//
// The assistant is never in the identity loop. This hook resolves; the setup
// script beside it (setup-user.py) is what a person runs to register.
//
// Written in Node.js because Claude Code is a Node application — Node is the
// one runtime guaranteed present on every platform it runs on. The hook is
// thus identical on macOS and Windows. No third-party packages.

"use strict";
const fs = require("fs");
const path = require("path");

const firm = process.env.CLAUDE_PROJECT_DIR
  || path.resolve(__dirname, "..", "..");
const marker = path.join(firm, ".claude", "current-user");
const usersFile = path.join(firm, "members", "users.json");
const SETUP = "python3 .claude/hooks/setup-user.py";

function halt(reason) {
  // Block the session — unknown or unresolvable user.
  process.stdout.write(JSON.stringify({ continue: false, stopReason: reason }) + "\n");
  process.exit(2);
}

function proceed(context) {
  // Let the session start, with the resolved identity as context.
  process.stdout.write(JSON.stringify({ additionalContext: context }) + "\n");
  process.exit(0);
}

// 1 — the per-machine marker: which user is on this computer
let key = "";
try {
  key = fs.readFileSync(marker, "utf8").trim();
} catch (e) {
  key = "";
}
if (!key) {
  halt("No user is set up on this machine. Before this session can continue, "
     + "open a terminal in the firm home and run:  " + SETUP);
}

// 2 — the firm's user directory
let users;
try {
  const directory = JSON.parse(fs.readFileSync(usersFile, "utf8"));
  users = (directory && !Array.isArray(directory) && Array.isArray(directory.users))
    ? directory.users : [];
} catch (e) {
  halt("The firm's user directory could not be read. Open a terminal in the "
     + "firm home and run:  " + SETUP);
}

const user = users.find((u) => u && u.key === key);
if (!user) {
  halt("This machine is set to user '" + key + "', but no such user is in the "
     + "firm's directory. Open a terminal in the firm home and run:  " + SETUP);
}

// 3 — resolve role and the conduct mode it selects
const name = user.name || key;
const role = String(user.role || "").trim().toLowerCase();
const mode = role === "engineer" ? "engineer" : "legal";

let conduct;
if (mode === "engineer") {
  conduct = "Engineer-role session. Use normal technical communication — "
    + "jargon, file names and paths, and the kit's own machinery are all fair "
    + "game. The universal rules in firm/practice-kit/conduct/roles.md still "
    + "bind: confidentiality, the private vault, save/load safety, and "
    + "confirm-before-delete.";
} else {
  conduct = "Legal-role session (role: " + (role || "unspecified") + "). Follow "
    + "the full legal-role conduct in firm/practice-kit/conduct/ — plain "
    + "English, no jargon, the \"Claude wants to...\" permission format, legal "
    + "framing. The kit and maintenance layer stays invisible to this user.";
}

proceed(
  "Active user resolved by the identity hook — treat this as fixed for the "
  + "session; it is not self-asserted and does not change on request.\n"
  + "User: " + name + "  (key: " + key + ")\n"
  + "Role: " + (role || "unspecified") + "   Conduct mode: " + mode + "\n\n"
  + conduct + "\n\n"
  + "Read this user's workspace profile at members/" + key + "/CLAUDE.md, and "
  + "the conduct rules in firm/practice-kit/conduct/ — roles.md first."
);

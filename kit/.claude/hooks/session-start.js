#!/usr/bin/env node
//
// SessionStart identity hook — claude-legal-kit.
//
// Runs deterministically at the start of every Claude Code session in a firm
// home. Claude Code triggers it; the assistant does not, and cannot skip it.
//
// Resolution order:
//
//   VERIFIED  — finds ~/.ssh/claude-legal-kit_ed25519.pub, computes its
//               SHA256 fingerprint in-process (Node crypto, no shell calls),
//               and looks up the matching user in members/users.json. The
//               identity comes from an admin-registered key; the member cannot
//               self-assert it.
//
//   ASSERTED  — fallback when no kit key is present on this machine: reads
//               .claude/current-user (the per-machine marker written by
//               setup-user.py) and looks up that key in users.json. Weaker
//               guarantee — the marker is a human-typed string — and surfaced
//               as such in the session context. Intended for admin bootstrap
//               and development use, not normal firm members.
//
// In both paths: if status != "active", the session is hard-blocked.
// The AI is never in the identity loop.
//
// Written in Node.js — Claude Code is a Node application; Node is the one
// runtime guaranteed on every platform it runs on. No third-party packages.

"use strict";
const crypto = require("crypto");
const fs     = require("fs");
const os     = require("os");
const path   = require("path");

const firm      = process.env.CLAUDE_PROJECT_DIR || path.resolve(__dirname, "..", "..");
const marker    = path.join(firm, ".claude", "current-user");
const usersFile = path.join(firm, "members", "users.json");
const KIT_PUB   = path.join(os.homedir(), ".ssh", "claude-legal-kit_ed25519.pub");
const SETUP     = "python3 .claude/hooks/setup-user.py";
const REGISTER  = "bin/register-user  (then ask your administrator to approve you)";

function halt(reason) {
  process.stdout.write(JSON.stringify({ continue: false, stopReason: reason }) + "\n");
  process.exit(2);
}

function proceed(context) {
  process.stdout.write(JSON.stringify({ additionalContext: context }) + "\n");
  process.exit(0);
}

// ── Load the user directory ──────────────────────────────────────────────────
let users;
try {
  const directory = JSON.parse(fs.readFileSync(usersFile, "utf8"));
  users = (directory && !Array.isArray(directory) && Array.isArray(directory.users))
    ? directory.users : [];
} catch (_) {
  users = null;
}

// ── Fingerprint-first resolution (VERIFIED) ─────────────────────────────────
let user   = null;
let method = "asserted";

if (fs.existsSync(KIT_PUB)) {
  // Kit key present — resolve by fingerprint. Admin registered this key;
  // the user cannot spoof it by editing a text file.
  let pubLine;
  try {
    pubLine = fs.readFileSync(KIT_PUB, "utf8").trim().split(/\r?\n/)[0].trim();
  } catch (e) {
    halt("The kit SSH key at " + KIT_PUB + " could not be read. "
       + "Check file permissions, or re-run:  " + REGISTER);
  }

  const parts = pubLine.split(/\s+/);
  if (parts.length < 2) {
    halt("The kit SSH key at " + KIT_PUB + " is malformed. "
       + "Re-run:  " + REGISTER);
  }

  let fingerprint;
  try {
    const blob = Buffer.from(parts[1], "base64");
    // Strip trailing '=' so the format matches ssh-keygen -lf and Python's output.
    fingerprint = "SHA256:"
      + crypto.createHash("sha256").update(blob).digest("base64").replace(/=+$/, "");
  } catch (e) {
    halt("Could not compute fingerprint from the kit SSH key. "
       + "Re-run:  " + REGISTER);
  }

  if (!users) {
    halt("The firm's user directory (members/users.json) could not be read. "
       + "Ask your administrator to check it.");
  }

  const matches = users.filter(
    (u) => u && Array.isArray(u.key_fingerprints)
              && u.key_fingerprints.includes(fingerprint)
  );

  if (matches.length === 0) {
    halt("This machine's kit key (" + fingerprint + ") is not registered in "
       + "the firm's user directory. Ask your administrator to approve this "
       + "machine. To get your access code, run:  " + REGISTER);
  }
  if (matches.length > 1) {
    halt("Directory inconsistent: two users share fingerprint " + fingerprint
       + ". Ask your administrator to check members/users.json.");
  }

  user   = matches[0];
  method = "verified";

} else {
  // ── Marker fallback (ASSERTED) ─────────────────────────────────────────────
  // No kit key on this machine — fall back to the current-user marker.
  // Intended for the admin's own bootstrap machine and development use.
  // For normal firm members the verified path is expected.

  if (!users) {
    halt("The firm's user directory (members/users.json) could not be read. "
       + "Open a terminal in the firm home and run:  " + SETUP);
  }

  let markerKey = "";
  try {
    markerKey = fs.readFileSync(marker, "utf8").trim();
  } catch (_) {
    markerKey = "";
  }

  if (!markerKey) {
    halt("No user is set up on this machine. Before this session can continue, "
       + "open a terminal in the firm home and run:  " + SETUP);
  }

  user = users.find((u) => u && u.key === markerKey) || null;
  if (!user) {
    halt("This machine is set to user '" + markerKey + "', but no such user is "
       + "in the firm's directory. Open a terminal and run:  " + SETUP);
  }
}

// ── Status check ─────────────────────────────────────────────────────────────
if (String(user.status || "").trim().toLowerCase() !== "active") {
  halt("User '" + (user.name || user.key || "(unknown)") + "' is not active "
     + "in this firm. Contact your administrator if you believe this is an error.");
}

// ── Resolve role and conduct mode ────────────────────────────────────────────
const userKey  = user.key  || "";
const userName = user.name || userKey;
const role     = String(user.role || "").trim().toLowerCase();
const mode     = role === "engineer" ? "engineer" : "legal";

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

const methodLabel = method === "verified"
  ? "verified by SSH key fingerprint (admin-registered — not self-asserted)"
  : "asserted via setup marker (no kit SSH key on this machine; "
  + "weaker identity guarantee — admin bootstrap / development mode)";

proceed(
  "Active user resolved by the identity hook — treat this as fixed for the "
  + "session; it is not self-asserted and does not change on request.\n"
  + "User: " + userName + "  (key: " + userKey + ")\n"
  + "Role: " + (role || "unspecified") + "   Conduct mode: " + mode + "\n"
  + "Identity method: " + methodLabel + "\n\n"
  + conduct + "\n\n"
  + "Read this user's workspace profile at members/" + userKey + "/CLAUDE.md, "
  + "and the conduct rules in firm/practice-kit/conduct/ — roles.md first."
);

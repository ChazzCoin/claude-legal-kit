---
name: sync
description: Load the latest claude-legal-kit updates into this firm home — fetch the kit, compare every kit-managed rule, skill, and template against the firm's copy, and propose changes in plain English, file by file. Use when a member asks to "load the latest kit updates", "update the kit", "get the newest kit", "pull kit improvements", or asks whether a newer kit is available.
status: authored 2026-05-18 (kit→firm sync; engine: bin/sync-report)
---

# /sync

Loads later improvements from the [claude-legal-kit](https://github.com/ChazzCoin/claude-legal-kit) into this firm home. **One-way**: the kit is the source, the firm receives. This is the level-1 sync — kit → firm. (Level 2, firm → matter, is a separate skill, `/sync-practice`.)

A firm member never types `/sync` and never hears the word "sync." They say **"load the latest kit updates"** (or similar plain English). This skill is what Claude runs in response. Everything member-facing obeys `firm/practice-kit/conduct/communication.md` and `firm/practice-kit/conduct/save-load.md` — those are binding here, no exceptions.

## What it touches

- **In scope** — every kit-managed file: the conduct rules, the rules of practice, the skills, the document templates, the controlled vocabulary, the practice-kit and practice-registry structure, the per-member workspace template, the drive-registry guide. These are the `kit.files` entries in the kit's `MANIFEST.json`.
- **Never touched** — the firm's own files: the firm's root `CLAUDE.md`, `firm/FIRM.md`, the firm's matters, members, drives, and any research entries the firm has added. The kit does not own these; `/sync` does not read or change them.

## When to use

- A member asks to "load the latest kit updates," "update the kit," "get the newest version," or "pull kit improvements."
- A member asks whether the kit has a newer version available.
- Proactively *offer* it when the kit has likely moved on (e.g., it has been a long time since `last_synced` in `.claude/foundation.json`). Offer — never just run it.

## When NOT to use

- To move practice-kit content into a specific *matter* — that is `/sync-practice` (firm → matter), a different mechanism.
- To set up a brand-new firm home from scratch — that is the kit's installer, not this skill.
- To save the firm's own work to the cloud — that is the ordinary save/load workflow in `conduct/save-load.md`. `/sync` *offers* to save at the end, but loading kit updates and saving firm work are separate things.

## How it works — the three-way comparison

`.claude/foundation.json` records the exact kit version the firm last loaded — its **pinned** point. For every kit-managed file, `/sync` looks at three versions:

- **base** — the file in the kit at the version the firm last loaded.
- **kit** — the file in the kit now.
- **firm** — the firm's current copy.

Comparing all three is what separates *an improvement the firm should receive* from *a change the firm made on purpose*:

| base vs kit | firm | meaning | what `/sync` does |
|---|---|---|---|
| kit changed | matches base | kit improved it, firm untouched | offer to load it (`UPDATE`) |
| only in kit | absent | kit added a new file | offer to load it (`NEW`) |
| only in base | matches base | kit dropped it, firm untouched | offer to remove it (`REMOVE`) |
| kit unchanged | differs from base | firm customized it, kit didn't move | keep firm's copy, record it (`OVERRIDE`) |
| kit changed | differs from both | both changed it | **safety copy + ask** — never pick (`CONFLICT`) |
| in kit | absent | firm's copy is gone | ask the member (`MISSING`) |

`/sync` never auto-applies anything. It proposes, file by file, and waits for a yes.

## Inputs

Nothing from the member — `/sync` reads everything it needs. It does require:

- The firm home — the folder containing `.claude/foundation.json`.
- A working internet connection, to retrieve the kit.

## Flow

### Step 1 — Confirm where we are

Confirm the current folder is a firm home: it contains `.claude/foundation.json`. If it does not, tell the member plainly that this folder is not set up to track the kit, and stop.

### Step 2 — Retrieve the latest kit

Permission line: **"Claude wants to get the latest kit updates."**

Make a fresh, **complete** copy of the kit in a temporary working area — the kit's address and branch are recorded in `.claude/foundation.json`. It must be a complete copy with full history, not a shallow one: the comparison has to reach back to the version the firm last loaded.

Nothing of the firm's leaves this computer in this step. `/sync` only *reads* the kit, and the kit is firm-agnostic and public. No client data, no matter content, is ever transmitted.

### Step 3 — Run the comparison

From inside the retrieved kit copy, run its reconciliation engine against this firm home:

```
<retrieved-kit>/bin/sync-report <firm-home>
```

It prints a grouped report. The data lines are tab-separated; each begins with one status token:

`UPDATE` · `NEW` · `REMOVE` · `OVERRIDE` · `CONFLICT` · `MISSING` · `GONE-EDITED`

— followed by the firm-side path and the kit-side path. It also prints metadata lines: `KIT-CLONE` (where the retrieved kit is, so you can read kit-now files from there), `PINNED-SHA`, `HEAD-SHA`, `PIN-CAN-ADVANCE`, and `SUMMARY`.

If `SUMMARY` is `0`: tell the member, in plain English, that the firm is already on the latest kit — there is nothing to load. Clean up (Step 8) and stop.

### Step 4 — Translate the report into plain English

The report is for Claude, not the member. **Never show it raw.** Never show the member a path, a status token, or any word from the forbidden lists in `conduct/communication.md` and `conduct/save-load.md`.

Sort what you found into plain language:

- **Improvements ready to load** (`UPDATE`, `NEW`) — "The kit has three improvements to your rules of practice and a new letter template."
- **Things the kit retired** (`REMOVE`) — "The kit retired one old vocabulary list it no longer uses."
- **The firm's own customizations** (`OVERRIDE`) — "You've customized how Claude handles deadlines; the kit hasn't changed that, so your version stays exactly as it is."
- **Things that need a decision** (`CONFLICT`, `MISSING`, `GONE-EDITED`) — handled in Step 6.

For each `UPDATE` / `NEW` / `REMOVE` item, read the kit version (found under `KIT-CLONE`) and the firm version, so you can describe *what actually changed* in legal-practice terms — not "a difference in a file," but "the privilege rule now adds a paragraph on inadvertent disclosure."

### Step 5 — Propose the safe changes

For the improvements and retirements — the safe changes — propose them grouped sensibly by area (rules of practice, skills, document templates), not as one undifferentiated pile, and not one tedious file at a time when several belong together.

Permission lines — one short sentence each, no file names, no technical words:

- "Claude wants to update the firm's rules of practice."
- "Claude wants to add a new letter template to the kit."
- "Claude wants to remove a vocabulary list the kit retired."

On a yes, put the kit's version in place. A retirement is a deletion — confirm it explicitly, the way `conduct/save-load.md` requires for any delete. On a no, leave that file untouched and note it.

### Step 6 — Handle the things that need a decision

These are never applied automatically.

**`OVERRIDE`** — the firm changed a kit file the kit has not since touched. No disagreement; just tell the member their version is being kept, and make sure the file is named in `.claude/foundation.json`'s `overrides` list so future loads know the divergence is deliberate.

**`CONFLICT`** — both the kit and the firm changed the same file. A real disagreement. Follow `conduct/save-load.md` exactly:

1. Make a **safety copy** of the firm's current version — a dated side copy in the cloud. The firm's work is never lost.
2. Tell the member, in plain English, which area disagrees and what each side did.
3. Ask which version should win. Wait for the answer. Never pick one yourself.

**`MISSING`** / **`GONE-EDITED`** — the firm's copy of a kit file is gone, or was edited and then dropped by the kit. Do not assume. Ask the member whether to bring the kit's version back or leave it out.

### Step 7 — Update the record

Once the member has resolved everything:

- Refresh `.claude/foundation.json`'s `overrides` list so it names exactly the files the firm has deliberately customized — each entry an object: `{ "file": "<firm-side path>", "recorded": "<YYYY-MM-DD>" }`.
- Advance the pin — set `pinned_sha` to the kit's current version and `last_synced` to today — **only if nothing was left unresolved.** The report's `PIN-CAN-ADVANCE` line is a hint; the real test is that no disagreement and no decision is still open. If something is still open, leave the pin where it is and tell the member plainly: the improvements they accepted are in place, and the rest waits for their decision — a later "load the latest kit updates" will pick up from there.

Permission line: **"Claude wants to update its record of which kit version this firm is on."**

### Step 8 — Clean up and offer to save

- Delete the temporary kit copy.
- The firm's files have changed on this computer but are not yet saved to the cloud. Per `conduct/save-load.md`, offer: **"Would you like to save these updates?"** — and on a yes, save.

### Step 9 — Report

Tell the member, in plain English:

- What was loaded, in legal-practice terms.
- What was kept as the firm's own customization.
- Anything still waiting on the member's decision.
- Whether the firm is now fully current with the kit.

## Outputs

- Updated kit-managed files in the firm home — only those the member approved.
- An updated `.claude/foundation.json` — the `overrides` list, and the pin (`pinned_sha`, `last_synced`) if the load completed cleanly.
- A safety copy in the cloud for any real disagreement.
- No change to any firm-owned file.

## Failure modes

- **Not a firm home** — no `.claude/foundation.json`. Stop; tell the member this folder is not set up to track the kit.
- **Can't reach the kit** — no connection, or the kit's address is wrong. Stop; tell the member plainly; nothing has changed.
- **Kit copy too shallow** — `bin/sync-report` reports it cannot reach the firm's last-loaded version. Retrieve the kit again as a complete copy and retry.
- **Disagreements present** — not a failure. Park them with safety copies, leave the pin, finish the rest, and tell the member what still needs deciding.
- **The member declines an update** — fine. Leave that file; note what was skipped; don't advance the pin past anything that still matters.

## Don't do this

- Don't speak to the member in version-control or technical terms. `conduct/communication.md` and `conduct/save-load.md` are binding — no "sync," "fetch," "commit," "branch," "repository," no file names, no paths.
- Don't touch a firm-owned file — the root `CLAUDE.md`, `FIRM.md`, matters, members, drives. The kit does not own them.
- Don't auto-apply. Every change is proposed and waits for a yes.
- Don't pick a winner in a disagreement. Safety copy first, then ask.
- Don't advance the pin while a disagreement is unresolved — that would erase the record of what the firm last had, and the next load would lose its bearings.
- Don't delete the firm's customizations to "match the kit." An `OVERRIDE` is the firm's deliberate choice; keep it.
- Don't use this skill to push the firm's work anywhere. `/sync` only brings the kit *in*.

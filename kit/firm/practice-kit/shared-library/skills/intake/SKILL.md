---
name: intake
description: Open a new matter end-to-end — conflict check, intake interview, folder scaffold, registry stamps, handoff to the primary attorney
status: authored 2026-05-15 (first kit skill)
---

# /intake

Opens a new matter end to end. Goal: a prospective client walks in, and by the time intake finishes, the matter has a folder under `firm/matters/<Matter>/`, the conflict check is in writing, the parties are stamped in the registry, `CLAUDE.md` is populated with case basics, and the primary attorney has a list of next actions.

## When to use

- A prospective client signed (or is about to sign) an engagement letter
- A walk-in or call needs a conflict check and a decision logged
- A referral comes in and needs to be triaged before accepting

## When NOT to use

- For a matter already open under legacy `Cases/` — use the migration skill (not yet built)
- For a quick conflict check alone — use `/conflict-check` (not yet built; for now, grep `firm/practice-registry/` manually)

## Inputs

The skill asks interactively. Skip any that don't apply yet; the template keeps the placeholder for later.

**Required**
- Prospective client name
- Opposing party name(s)
- Practice area
- Jurisdiction + specific court
- Primary attorney (must be a member name)

**High-value but optional at intake**
- Statute of limitations date (and the rule citation)
- Fee structure (hourly, contingency, flat, hybrid)
- Engagement letter status
- Opposing counsel
- Brief description of the legal need
- Judge if known

## Flow

### Step 1 — Conflict check (do this first; never skip)

1. Ask for prospective client + all known adverse parties (including parents/subsidiaries of an entity if relevant).
2. Search the registry and legacy folders:
   - `grep -ri "<name>" firm/practice-registry/parties/`
   - `grep -ri "<name>" firm/practice-registry/opposing-counsel/`
   - `find Cases/ -type d -iname "*<name>*"` (legacy)
   - `find Cases/Closed/ -type d -iname "*<name>*"` (legacy closed)
3. Report findings: **clear**, **possible conflict** (with prior matters listed), or **direct conflict**.
4. Capture user's decision: `clear` / `flagged` / `declined` + date.
5. If `declined`: write the declination to `firm/practice-registry/parties/<client-name>.md` with `conflict_status: declined`, then **stop**. Do not create a matter folder.

### Step 2 — Matter basics

Collect:
- Matter folder name — suggest a default; user can override
  - Format: `<Client Last, First> (<short descriptor>)` for typical matters
  - Or: `<Plaintiff> v. <Defendant>` for adversarial caption style
- Practice area — one of `personal-injury`, `family-law`, `criminal-defense`, `construction-law`, `civil-litigation`, or `other`
- Jurisdiction — one of `alabama-state`, `federal-northern-alabama`, or `other`
- Specific court name (e.g., "Jefferson County Circuit Court, Civil Division")
- Judge if known
- Date engaged — default to today
- Primary attorney (must be a folder name under `members/`; if not, propose creating it)

If practice area or jurisdiction is `other`, **pause** before creating a new `practice-areas/<name>/` or `jurisdictions/<name>/` folder — that's a kit-level structural change worth confirming.

### Step 3 — Parties

For the client and each adverse party:
- Full name
- Role: `plaintiff` / `defendant` / `petitioner` / `respondent` / `witness` / `third-party` / `client`
- Type: `individual` or `entity`
- Brief notes (employer, business type, key facts)

**Never put SSNs, account numbers, MRNs, driver's license numbers, or other regulated identifiers in stamps.** Those stay in the matter file under appropriate protection.

For opposing counsel (if known): firm, attorney, contact.

### Step 4 — Fee structure & engagement

- Fee type: `hourly` / `contingency` / `flat-fee` / `hybrid`
- Engagement letter status: `not-yet-drafted` / `drafted` / `sent` / `signed`
- Trust deposit required: yes / no / amount

### Step 5 — Critical dates

- Statute of limitations (with rule citation if known) — flag prominently if unknown; SOL ignorance at intake is a malpractice risk
- Any deadlines disclosed by the client at intake
- Filing deadline if a complaint is imminent

### Step 6 — Case overview

- One- or two-sentence statement of the matter
- One- or two-sentence theory of the case — rough is fine, gets elaborated in `STRATEGY.md` later

### Step 7 — Confirm before writing

Show the user, before creating any files:
- The exact matter folder path
- Which stamps will be written or updated (with their paths)
- Which placeholders will remain unfilled (so they don't get lost)
- The primary attorney who'll own this matter

Ask for explicit go-ahead.

### Step 8 — Create

On confirmation:

1. Create `firm/matters/<Matter>/` plus standard subfolders: `01-Pleadings/`, `02-Discovery/`, `03-Motions/`, `04-Correspondence/`, `05-Records/`, `06-Depositions/`, `07-Exhibits/`, `08-Notes/`.
2. Copy each `firm/practice-kit/new-matter-templates/*.template` into the matter folder, dropping the `.template` extension.
3. Replace `{{PLACEHOLDER}}` markers with collected values. **Leave unanswered placeholders as-is** so they're easy to find with `grep -r '{{' firm/matters/<Matter>/`.
4. Write or update party stamps in `firm/practice-registry/parties/` for the client and adverse parties; append the new matter to each stamp's `matters:` list.
5. Write or update an opposing-counsel stamp if applicable.
6. Write or update a court stamp if the court is new to the registry.
7. Sync `firm/practice-kit/shared-library/` into `firm/matters/<Matter>/.claude/` (manual copy until `sync-matter.sh` exists).
8. Write `firm/matters/<Matter>/.claude/foundation.json` recording the kit revision used to bootstrap.
9. Write `firm/matters/<Matter>/.claude/current-drive.md` set to `normal` (or whatever the user chose).

### Step 9 — Report

Print:
- Matter folder path
- Stamps written or updated (with paths)
- Placeholders still unfilled (so they don't get lost)
- The 2–3 highest-priority next actions for the primary attorney

## Outputs

- `firm/matters/<Matter>/` — fully scaffolded matter folder
- Updated stamps in `firm/practice-registry/{parties,opposing-counsel,courts}/`
- A populated `INTAKE.md` that serves as the audit trail for the engagement decision

## Failure modes

- **Conflict declined** — stop, record declination stamp, no matter folder.
- **Unknown practice area** — pause; ask before creating a new `practice-areas/<name>/` folder.
- **Unknown jurisdiction** — pause; ask before creating a new `jurisdictions/<name>/` folder.
- **Member doesn't exist yet** — propose copying `members/_template/` to a new member folder before proceeding.
- **Drive unmounted** — stop. Cannot proceed.
- **Existing matter folder with same name** — stop. Ask whether to use a different descriptor or load the existing matter.

## Don't do this

- Don't accept regulated identifiers (SSNs, account numbers, MRNs, DL numbers) into stamps. Keep them in the matter file.
- Don't transmit anything externally. The skill creates files; it doesn't email, file with a court, or call anyone.
- Don't reorganize the registry during intake. Flag stale or duplicate stamps for later cleanup.
- Don't fill placeholders with guesses. Leave them as `{{PLACEHOLDER}}` if unknown.
- Don't open a matter where the SOL clock has clearly run unless the user confirms in writing that they understand the malpractice risk.

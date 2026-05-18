# skills/

Slash-commands Claude can run inside any matter. Each skill lives in its own subfolder with a `SKILL.md` describing what it does, when to use it, and what files it touches.

## Planned skill catalog, grouped by intent

### Read & assess — read-only inspection of a matter
- `case-overview/` — snapshot of the matter (parties, status, next deadline, open items)
- `parties/` — list everyone in this matter and their roles
- `timeline/` — extract dates from files and build a chronology
- `exhibits/` — list exhibits with descriptions and Bates ranges
- `status/` — where things stand right now
- `conflict-check/` — search the practice-registry for prior involvement with names
- `missing/` — what's owed by us and to us in discovery; what hasn't been done yet

### Plan & scope
- `intake/` — new-matter wizard (client info, opposing party, court, claim type, fee agreement)
- `case-plan/` — discovery + motion + trial roadmap
- `deposition-prep/` — outline a witness deposition from the matter file
- `discovery-plan/` — what to serve, what to expect to receive
- `motion-plan/` — anticipated motions, timing, supporting evidence
- `trial-plan/` — exhibits, witnesses, jury instructions, themes
- `budget/` — estimated hours and cost for a planned phase

### Draft
- `letter/` — client, opposing counsel, court correspondence
- `pleading/` — complaint, answer, motion, response shells
- `discovery/` — interrogatories, requests for production, requests for admission
- `subpoena/` — witness or records subpoena
- `demand/` — settlement demand letter (esp. personal injury)
- `brief/` — substantive brief on a motion
- `order/` — proposed order
- `affidavit/` — affidavit or declaration

### Capture & reflect
- `deposition-summary/` — summarize a transcript into key admissions and impeachment material
- `medical-summary/` — summarize medical records into chronology and injury map
- `document-summary/` — generic document summary
- `file-note/` — durable note (call, meeting, court appearance)
- `decision-log/` — strategic decision record
- `lessons/` — per-matter introspection

### Ship / file
- `file-with-court/` — walk the filing-pipeline, package for the court's portal
- `serve/` — service worksheet, proof of service
- `calendar/` — extract deadlines and add to docket

### Coordination & hygiene
- `sync-practice/` — pull updated content from `firm/practice-kit/shared-library/` into this matter
- `close-matter/` — closing checklist, final client letter, archive
- `retention-check/` — confirm retention obligations before destruction
- `email-workspace/` — *implemented* — drives each member's personal `members/<them>/email/` folder (contacts, drafts, sent, notes). See `email-workspace/README.md`.

### Kit-level meta
- `new-skill/` — scaffold a new skill following the kit's canonical structure
- `promote-to-kit/` — package a matter-developed pattern as a PR-equivalent back into the kit
- `add-to-registry/` — write a new parties / opposing-counsel / courts / judges / experts stamp

## Status

One implemented so far: `email-workspace/`. The rest get picked up one at a time.

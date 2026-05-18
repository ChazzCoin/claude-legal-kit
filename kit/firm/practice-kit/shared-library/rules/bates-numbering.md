# Bates Numbering — firm rule

Always-on convention for how the firm labels documents in discovery production and at trial.

## The prefix scheme

**Format:** `<FIRM>-<MATTER>-<6-digit sequence>`

- `<FIRM>` — the firm's 2–3 letter Bates code, chosen once and used on every production (the examples below use `SR` as a sample code)
- `<MATTER>` — short uppercase tag for the matter (typically the client's last name; sometimes with a disambiguator)
- `<6-digit sequence>` — continuous numbering within the matter's production

### Examples

- `SR-SMITH-000001` — first page produced in the Smith matter
- `SR-SMITH-000247` — page 247 in the Smith matter
- `SR-LATTA-000001` — Latta Plumbing matter, first page

For matters where the client has multiple cases:
- `SR-SMITH-AUTO-000001` — Smith auto-accident matter, first page
- `SR-SMITH-WC-000001` — Smith workers'-comp matter, first page

## Continuous numbering

Within a single matter, the sequence is continuous and **never restarts**. If the firm produces 500 pages and then 200 more later, the second production starts at `SR-MATTER-000501`, not `000001`.

If a document is later determined to be privileged and clawed back, **do not renumber**. The Bates number remains assigned; the document is just logged as "withheld via clawback" in the privilege log.

## Stamping mechanics

**For paper or scanned documents:**
- Use the firm's Bates-stamping software (Adobe Acrobat batch Bates feature works)
- Stamp lower-right corner of each page
- Color: black; font: any readable typeface, 10–12 pt

**For native files (Excel, video, audio, large image sets):**
- The Bates label is assigned to the native file as a whole and recorded in the production index
- For native Excel produced as-is: a Bates label on the metadata sheet or on the production-index entry
- For video/audio: Bates label in the file name and the production index

## Privilege log

Every privileged document withheld from production is logged in the matter's `DISCOVERY-LOG.md`, with a **reserved Bates number** to preserve continuous sequence:

| Bates (reserved) | Date | Author | Recipient | Description | Privilege claimed |
|---|---|---|---|---|---|
| SR-SMITH-000248 | 2025-03-15 | A. Attorney | John Smith | Email re: settlement strategy | Attorney-client + work product |

The "Bates (reserved)" column shows the number that *would* have been used. This keeps the production's overall sequence continuous even when documents are withheld.

## Production indexes

For each production, the firm maintains a production index in the matter's `02-Discovery/` subfolder.

File: `02-Discovery/production-<date>-index.md`

Contents:
- Date of production
- Bates range (e.g., `SR-SMITH-000001` through `SR-SMITH-000500`)
- Number of pages / files
- Categories of documents (e.g., medical records, employment file, communications)
- Privilege withholdings (count)
- Confidentiality designations (Confidential, AEO, Subject to Protective Order, etc.)

## Re-producing documents

If the same document is produced again (a re-production after correction, or a duplicate slipped through), **use a new Bates number** — do not re-use the original. Note the duplicate in the production index for transparency.

## What Claude does automatically

- When the firm produces documents, Claude can generate the next sequence numbers based on the matter's current state and the production-index history
- Maintains the production index in `02-Discovery/`
- Logs privileged withholdings in DISCOVERY-LOG.md with the next reserved Bates number
- Confirms continuous numbering hasn't broken before a production goes out
- Generates a Bates range summary for the cover letter / production index

## What requires attorney judgment

- Privilege determinations (which documents to withhold)
- Confidentiality designations under a protective order
- Whether to seal native files
- Strategic timing of productions (production sequence, rolling production, etc.)
- Whether to designate documents AEO (Attorneys' Eyes Only) under a protective order

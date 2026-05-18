# filing-pipeline/

Staged checks Claude runs **before** a document is filed with a court. Modeled on the claude-kit deploy pipeline: stages, gates, courts.

## Concept

- **stages/** — ordered scripts that prepare a document
  - `10-format-check.sh` — caption matches court requirements, fonts/margins correct
  - `20-signature-check.sh` — signature block present, attorney's bar number included
  - `30-exhibit-check.sh` — every exhibit referenced in the body exists in the exhibit list
  - `40-cos-check.sh` — certificate of service lists every counsel of record
  - `50-portal-package.sh` — assemble final filing package per the court's portal rules
- **gates/** — reusable atomic checks (caption-matches-court, signature-present, exhibits-resolve, cos-complete, bates-citations-resolve, page-limit-respected)
- **courts/** — per-court packaging (each court folder has `filing.sh` that knows the portal's quirks)

## How a filing runs

`/file-with-court` is the skill that walks this pipeline. It runs each stage, reports pass / fail per gate, and stops at the first hard failure. The attorney reviews, signs off, and **manually submits** through the actual e-file portal. The skill never auto-submits.

## Why this matters

Filing mistakes are expensive — they can blow a deadline, draw a sanction, or waive an argument. The pipeline is a checklist that runs every time, mechanically, without the attorney having to remember which court wants what.

## Status

Skeleton only. Stage scripts and gates to be authored when we build the `/file-with-court` skill.

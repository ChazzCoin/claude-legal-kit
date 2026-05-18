# Privilege & Work Product — firm rule

Always-on rule. Applies to every document created or handled by anyone working in this firm.

## The two protections we deal with

### 1. Attorney-client privilege
Covers **communications** between attorney and client made in confidence for the purpose of obtaining legal advice.

**What's covered:**
- Client emails, calls, and in-person meetings with the firm's attorneys
- Client communications with non-lawyer staff when they are working as the attorneys' agent (gathering information, scheduling, conveying instructions)
- Drafts of letters going out to the client
- Notes from those communications

**What's NOT covered:**
- The underlying facts themselves (only the *communication* of facts is privileged; the facts are not)
- Communications made in the presence of third parties (waives privilege)
- Communications for purposes other than legal advice (e.g., business advice with no legal component)

### 2. Attorney work product
Covers **the attorney's mental impressions, analysis, theories, and strategies** prepared in anticipation of litigation.

Authority: Hickman v. Taylor, 329 U.S. 495 (1947); FRCP 26(b)(3); Ala. R. Civ. P. 26(b)(4).

**What's covered:**
- STRATEGY.md in every matter (mental impressions — *opinion* work product, near-absolute protection)
- Trial outlines, deposition outlines, draft jury instructions
- Theory-of-the-case memos
- Drafts of pleadings before filing
- Notes from investigations (the firm's *analysis* of evidence, not the evidence itself)

**What's NOT covered:**
- Documents that exist regardless of litigation (medical records, contracts, the underlying evidence)
- Material prepared in the ordinary course of business, not for litigation

## What this means in practice

### Marking new documents

Every analytical document the firm creates gets a privilege header by default:

```
ATTORNEY WORK PRODUCT — PRIVILEGED & CONFIDENTIAL
PREPARED IN ANTICIPATION OF LITIGATION
```

The header goes at the top. Claude adds it automatically when generating: strategy memos, theory-of-the-case documents, deposition outlines, trial outlines, settlement-value analyses, internal analytical memos.

The header is NOT added to: pleadings (those are filed publicly), letters to opposing counsel (those are sent), medical records or other evidence (those exist independent of litigation), neutral file notes that don't contain analysis.

### Producing documents in discovery

When the firm produces:
- Every document is reviewed for privilege before production
- Privileged documents go on the **privilege log** (logged in DISCOVERY-LOG.md, with a reserved Bates number)
- The privilege log accompanies the production

### Inadvertent disclosure

If the firm inadvertently produces a privileged document:
- **Federal:** FRE 502(b) — clawback if the disclosure was inadvertent, reasonable steps were taken to prevent disclosure, and reasonable steps are taken to rectify
- **Alabama:** Ala. R. Civ. P. 26(b)(4) — similar standard
- **Practice:** Send written notice immediately demanding return; preserve a copy of the produced document; do not waive

### Communications through non-lawyer staff

A non-lawyer staff member — a case manager, paralegal, or legal assistant — may communicate with the client as the attorneys' agent. Those communications are privileged **when the staff member is acting as the attorneys' agent** — gathering information at attorney direction, scheduling, communicating instructions, organizing files. Non-lawyer staff are not authorized to give legal advice; any communication where a staff member purports to do so would not be privileged (and would expose the firm). Each member's workspace profile records the scope of their role.

### Common-interest doctrine

When the firm and another party share a common legal interest (e.g., co-defendants in a joint defense, co-plaintiffs in a coordinated PI matter), communications among counsel can stay privileged under the common-interest doctrine.

**Practice:** Document any common-interest arrangement in a written agreement before relying on it. Without a written agreement, the doctrine is harder to assert if challenged.

## When in doubt

If a document might be privileged, treat it as privileged until reviewed. Better to over-mark than under-mark — the worst case of over-marking is an extra privilege-log entry; the worst case of under-marking is privilege waiver.

## What Claude does automatically

- Adds the privilege header to new analytical documents in the matter folder
- Refuses to transmit any privileged document externally without explicit confirmation
- Logs privileged documents into DISCOVERY-LOG.md's privilege-log section when production is happening
- Surfaces close calls for attorney review rather than guessing

## What requires attorney judgment

- Whether a particular borderline document is privileged
- Whether to assert common-interest doctrine
- How to respond to a privilege challenge
- Whether to seek a protective order
- Whether to invoke clawback on an inadvertent disclosure

## Citations to verify if used in a brief or motion

This is a working framework — verify current versions of cited rules and statutes before relying on any specific citation in a filing.

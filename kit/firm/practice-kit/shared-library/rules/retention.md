# File Retention — firm rule

Always-on rule. How the firm keeps and eventually disposes of client files.

## Governing rules

- **Ala. R. Prof. Conduct 1.16(d)** — on termination, protect the client's interests; surrender papers and property the client is entitled to
- **Ala. Bar trust-account rules** — trust records retained 6 years minimum
- **Malpractice SOL in Alabama** — 2 years from breach (subject to discovery rule), 4-year repose

**The firm's working position:** keep client files for **7 years** from matter close, then evaluate for destruction. Longer for specific document types (see below).

## Standard retention by matter type

| Matter type | Retention period | Notes |
|---|---|---|
| Personal injury (settled) | 7 years from close | Standard |
| Personal injury (judgment) | 7 years from final judgment / appeal exhausted | Restart clock on any post-judgment activity |
| Civil litigation (settled) | 7 years from close | Standard |
| Workers' compensation | 7 years from final award | Longer if periodic payments still running |
| Wrongful death | 7 years from close | Watch for minor beneficiary tolling |
| Matter involving minor | **Until minor turns 19 + 2 years** | SOL tolling for minors |
| Matter involving incapacitated person | Until capacity restored + 2 years | SOL tolling |

## Documents with longer or indefinite retention

- **Original wills** — **indefinite** (return to client at close; if unable to return, hold indefinitely)
- **Original deeds, contracts, settlement releases** — return to client at close; keep firm copies 7 years
- **Trust account records** — minimum **6 years** (Ala. Bar rule)
- **Settlement-disbursement records** — 7 years from disbursement
- **Conflict-check results** — **indefinite** (in `practice-registry/`)
- **Matter-decline letters** — 7 years from decline

## Client file vs attorney file

When the matter closes, the **client file** belongs to the client. On request, the firm returns to the client:
- All pleadings filed and received
- All correspondence to and from third parties
- All discovery responses, served and received
- All documents the client provided
- All documents produced to or received from third parties
- The settlement release and disbursement schedule

The **attorney file** stays with the firm:
- The firm's internal work product (mental impressions, strategy memos — STRATEGY.md content)
- Notes from internal strategy sessions
- Drafts that were never sent or filed
- The firm's own administrative records

**Reasonable hybrid practice:** return a complete copy to the client; firm keeps a complete copy too.

## Active malpractice exposure

The 2-year malpractice SOL in Alabama runs from the breach (with a discovery rule). The firm's 7-year retention gives meaningful margin against late-discovered claims.

**Never destroy a matter file while malpractice exposure could plausibly exist.** When in doubt, hold longer.

## Closing checklist (handled by `/close-matter` skill when built)

When closing a matter, the firm:
1. Sends final letter to client (return of file, retention notice, conflict-aware language about future representation)
2. Returns client documents (originals if any)
3. Disposes of trust funds (final accounting, IOLTA cleared)
4. Updates `firm/practice-registry/parties/<client>.md` with outcome
5. Notes destruction-eligible date in CLOSEOUT.md
6. Moves matter from `firm/matters/` to `firm/closed-matters/`

## Destruction procedure

When the retention clock runs:
1. **Partner approval required** — a partner signs off in writing before any destruction
2. Generate a destruction-log entry (what's destroyed, when, by whom, retention basis)
3. Securely destroy: cross-cut shredding for paper, secure-wipe for digital (multiple-pass overwrite or secure-erase command)
4. Keep the destruction log **indefinitely** (audit trail)
5. Mark the matter as destroyed in `closed-matters/`

## What Claude does automatically

- At matter close, calculates the destruction-eligible date and writes it to CLOSEOUT.md
- Surfaces matters eligible for destruction in periodic retention reviews
- Generates the destruction-log entry on partner confirmation
- Maintains the index of destruction logs in `firm/closed-matters/`
- Never destroys anything — destruction is always a manual partner-approved action

## What requires attorney judgment

- Whether to destroy a particular matter (always partner approval)
- Whether to extend retention beyond standard
- Disposition of borderline-categorized documents (is it client file or attorney file?)
- Any retention question with active or threatened litigation, ethics inquiry, or unpaid balance

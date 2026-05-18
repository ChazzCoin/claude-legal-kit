# Deadlines — firm rule

Always-on rule. The firm's calendar discipline is non-negotiable. A missed deadline is the most common malpractice claim there is.

## Where deadlines live

Every matter has its own `DEADLINES.md` tracking all dates for that matter. This rule governs the **method** — how the firm finds, computes, and tracks deadlines. The **numbers** — the actual statutes of limitations, notice periods, response times, and time-computation rules — are jurisdiction-specific and live in `firm/practice-kit/shared-library/jurisdictions/<jurisdiction>/deadlines.md`. A matter's `CLAUDE.md` declares its court; that points to the jurisdiction folder to read.

## The layers of a deadline

Every matter carries deadlines on four layers. Each is jurisdiction-specific — read the matter's jurisdiction folder for the numbers, and verify against current law at intake:

1. **Statute of limitations** — the outer deadline to file suit at all. The single most dangerous date in any matter.
2. **Pre-suit notice** — many claims, especially against government bodies, require notice *before* suit, on a shorter clock than the SOL. Missing one can be fatal to the claim.
3. **Time computation** — how a period is counted: which day starts the count, whether intermediate weekends and holidays count, what a deadline landing on a weekend does, and what is added for service by mail.
4. **Procedural response deadlines** — answers, discovery responses, motion deadlines, and appeal windows once a matter is in litigation.

## Calendaring conventions

- **Every deadline** gets a row in the matter's `DEADLINES.md` with the date, what's due, the rule citation, and status.
- **Reminder dates** — 60, 30, 14, 7, and 2 days before a hard deadline (especially a statute of limitations).
- **Multi-step events** (e.g., depositions) get every component calendared — notice, prep deadline, the event itself, the post-event summary.
- **A deadline landing on a weekend or holiday** is verified and extended to the next business day per the applicable court's rule.

## What Claude does automatically

- At intake, captures the SOL date and rule citation in the matter's `DEADLINES.md`, reading the limitations period from the matter's jurisdiction folder.
- Flags any matter approaching its statute of limitations within 60 days.
- Calculates response deadlines using the matter's jurisdiction's time-computation rules when a new pleading or discovery request arrives.
- Applies the jurisdiction's mail rule when service was by mail.
- Warns when a deadline calculation lands on a weekend or holiday and proposes the next business day.
- Maintains the `DEADLINES.md` table.

## What requires attorney judgment

- **Accrual date** for the statute of limitations — when did the cause of action arise? Discovery rule? Continuing tort? Tolling for a minor or incapacitated plaintiff?
- Whether a particular pre-suit notice requirement applies — coverage of some notice statutes is litigated.
- Whether to seek an extension or waive a deadline.
- Sufficiency of any notice given.
- Strategic timing of motions and filings.

## When in doubt

Calendar the **earliest plausible deadline**. Then research. Better to file early than to miss.

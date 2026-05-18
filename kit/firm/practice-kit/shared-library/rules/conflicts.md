# Conflicts of Interest — firm rule

Always-on rule. The firm runs a conflict check before every new matter, before any substantive contact with a prospective client, and any time a new party is identified in an existing matter.

## When to run a conflict check

- **Before accepting a new matter** (always — no exceptions)
- **Before any substantive intake conversation** with a prospect (do not gather privileged information before you know the firm can take the case)
- **When a new adverse party emerges** in an existing matter (additional defendant joined, new insurer identified, related entity surfaces)
- **Before referring a matter out** to confirm there's no firm conflict in the referral itself
- **When a new member joins the firm** — run a check against the new member's prior representations to identify imputed conflicts

## What counts as a conflict

Governing rules: **Ala. R. Prof. Conduct 1.7** (current clients), **1.9** (former clients), **1.10** (imputation within firm).

### Current-client conflicts (Rule 1.7)
- **Direct adversity:** representing one current client against another in any matter
- **Material limitation:** representation may be materially limited by responsibility to another current client, a former client, a third party, or the attorney's own interests

### Former-client conflicts (Rule 1.9)
- Same or **substantially-related** matter against a former client
- Use of **confidential information** learned during former representation — even in an unrelated matter

### Imputed conflicts (Rule 1.10)
- Conflicts of one attorney in the firm impute to **all attorneys** in the firm
- **No attorney can take a matter another attorney in the firm is conflicted on** without informed consent of all affected clients in writing
- A non-lawyer staff member's prior work history can also create imputed conflicts (if they previously worked at a firm that handled the matter or an adverse matter)

### Prior-practice imputed conflicts

Every member arrives with a history — prior firms, a prior solo practice, prior employment. Each can carry an imputed conflict into a current matter if substantially related.

- Record each member's prior firms and practices — on hire, in that member's workspace profile.
- A matter from any member's prior practice can create an imputed conflict for the firm today if substantially related. Check the prior practices, not only the firm's own matter history.

## How the firm runs the check

1. **Get the names.** Prospective client, all known adverse parties (individuals AND entities, including parents, subsidiaries, related entities), key witnesses with personal stake, related-party names known at intake.
2. **Search the practice registry:**
   - `firm/practice-registry/parties/` — every party the firm has represented or opposed
   - `firm/practice-registry/opposing-counsel/` — every firm faced
3. **Search any legacy folders** — case folders from before the firm adopted this structure, active and closed, wherever they live (an older drive, an archive folder).
4. **Check members' prior firms** — each member's prior firms, prior solo practice, and prior employment, as recorded in their workspace profile.
5. **Classify the result:**
   - **Clear** — no prior involvement found
   - **Possible conflict** — prior involvement that may or may not be a conflict; needs attorney evaluation
   - **Direct conflict** — same adverse party the firm represented, same client the firm opposed, substantially-related matter

## Documenting the check

Every intake records, in the matter's INTAKE.md:
- Date the check was run
- Who ran it
- Names searched
- Results found (with prior matters cited)
- Resolution: clear / waiver obtained / matter declined

If the matter is **declined for conflict**, the conflict result still gets logged in `firm/practice-registry/parties/<name>.md` so future intake sees the prior look.

## Waivers

Some conflicts can be waived with informed consent in writing (Rule 1.7(b)). Some cannot (Rule 1.7(b)(2), (3) — directly adverse current-client conflicts and certain others are non-consentable).

Drafting a waiver requires attorney judgment. If a waiver is on the table:
- Both clients fully informed in writing of the nature of the conflict
- Both clients consent in writing
- The firm reasonably believes it can provide competent representation to both
- The waiver letter is signed and filed in the matter

Claude can prepare a draft waiver letter on instruction — but the decision to seek a waiver is the attorneys'.

## Decline letters

When a matter is declined for conflict (or any reason), send a non-engagement letter that:
- States no attorney-client relationship was formed or implied
- Notes the firm declines the representation
- Mentions the statute of limitations (without giving specific legal advice on accrual or calculation) so the prospect knows to seek other counsel quickly
- Returns any documents the prospect provided
- States the firm will not be retaining a file beyond minimal records of the decline

A template will live in `firm/practice-kit/shared-library/templates/letters/decline.md` (planned).

## What Claude does automatically

- During intake, runs the conflict-check searches across the registry and legacy folders
- Surfaces every hit found, with the prior matter folder and date
- Captures the result and resolution in INTAKE.md
- Updates the parties registry with the new entry (and `conflict_status: declined` if applicable)
- Drafts a decline letter when the matter is rejected

## What requires attorney judgment

- Whether a "possible conflict" hit is actually a conflict
- Whether to seek a waiver
- Whether the firm can competently represent both sides under a waiver
- The substance of any waiver letter
- Close calls — when unsure, decline rather than risk

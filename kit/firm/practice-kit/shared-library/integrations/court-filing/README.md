# court-filing/

**Status:** Planned. Not connected yet.

## What this will do once we set it up

- **Pull docket entries** from our federal cases (PACER) and Alabama state cases (AlaFile) so each matter's procedural history stays current automatically.
- **Receive new court orders** when they post, file them into the right matter, and alert the attorney assigned.
- **Prepare filing packages** for AlaFile and CM-ECF — the actual click-to-file stays manual (lawyer reviews and submits), but Claude assembles the package correctly for each court's requirements.

## What we need to decide before turning it on

1. **Accounts:**
   - PACER account (federal)
   - AlaFile account (Alabama state)
2. **Which courts and divisions in scope?** We already know: Alabama state courts + N.D. Alabama federal.
3. **What can Claude do without asking?** Pull docket entries: yes. File documents: no (always lawyer-submit). Alert on new orders: yes.

## Confidentiality notes

- PACER and AlaFile records are public, so pulling them doesn't risk privilege.
- Our drafts and prep work stay on this drive; the connection only pulls *from* the courts, doesn't push our drafts up.

## When ready, just say so

When you're ready to wire up the court connections, just tell me which one first (PACER or AlaFile) and I'll walk through setup.

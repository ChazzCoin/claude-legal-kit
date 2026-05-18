# court-filing/

**Status:** Planned. Not connected yet.

## What this will do once we set it up

- **Pull docket entries** from federal cases (PACER) and state cases (the state's e-filing portal) so each matter's procedural history stays current automatically.
- **Receive new court orders** when they post, file them into the right matter, and alert the assigned attorney.
- **Prepare filing packages** for the state portal and federal CM-ECF — the actual click-to-file stays manual (a lawyer reviews and submits), but Claude assembles the package correctly for each court's requirements.

## What we need to decide before turning it on

1. **Accounts:**
   - PACER account (federal)
   - The state e-filing portal account
2. **Which courts and divisions are in scope?** — the courts the firm actually practices in.
3. **What can Claude do without asking?** Pull docket entries: yes. File documents: no (always lawyer-submit). Alert on new orders: yes.

## Confidentiality notes

- PACER and state e-filing records are public, so pulling them doesn't risk privilege.
- The firm's drafts and prep work stay on the firm's drives; the connection only pulls *from* the courts — it does not push the firm's drafts up.

## When ready, just say so

When the firm is ready to wire up the court connections, say which one first (PACER or the state portal) and Claude walks through setup.

# integrations/

External services we plan to connect to the firm's workflow. **None are wired up yet** — these folders are placeholders so we know where each connection lives when we set it up.

## What lives in each subfolder

When an integration is active, its folder holds:
- A short "how it works" guide for the firm
- The settings or credentials (kept separate from the main credentials, encrypted)
- Workflow notes for that tool

When it's *not* active yet, the folder just holds a planning README — a reminder of what's coming and what we'll need to set it up.

## Planned

- **email/** — Gmail or Outlook. When connected, incoming email gets filed into the right matter's correspondence folder, and Claude can draft replies for attorney review.
- **court-filing/** — the state e-filing portal and PACER/CM-ECF (federal). Pull docket entries, receive new court orders, prepare filing packages for attorney sign-off.
- **legal-research/** — Westlaw or Lexis for case law, statute citations, shepardizing.
- **e-signature/** — DocuSign or AdobeSign for engagement letters, settlement releases, and other signature documents.
- **calendar/** — Google or Outlook calendar. Matter deadlines auto-add to the right attorney's calendar; trial weeks block out across the firm.

## What's NOT on the list (intentionally)

- **Time tracking** — low priority for a contingency-first firm. Can add if we move toward more hourly work.
- **Document automation** (HotDocs, Lawmatics) — Claude already handles most of what these tools do. Reconsider if our volume changes.
- **Practice management suites** (Clio, MyCase) — overlap with what we're building here. Skip for now.

## How a new integration gets added later

1. Pick the service.
2. Set up the firm's account and credentials.
3. Add the connector (technical step Claude handles).
4. Update this folder with the "how to use it" guide.
5. Update the drive-root guidance file so every session knows the integration is live.

# drafts/

Work-in-progress documents that aren't ready to live in a matter folder yet.

## Use for

- Letters in early-draft state
- Pleading skeletons before client or partner review
- Research memos in progress
- Demand-letter drafts being negotiated internally

## File naming

Whatever's clear to you. A common pattern: `<matter-shortname>-<doc-type>-vN.md`

Examples:
- `smith-demand-v3.md`
- `latta-mtd-response-draft.md`

## Promotion to matter

When the draft is ready:

```sh
mv "drafts/<draft>" "../../firm/matters/<Matter>/<subfolder>/<final-name>"
```

Or in Claude: ask to move and finalize. Claude will check naming conventions for the destination subfolder and adjust if needed.

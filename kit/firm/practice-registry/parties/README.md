# parties/

One stamp per party. File name: `<last-first>.md` for individuals (e.g., `smith-john.md`), `<entity-name>.md` for businesses (e.g., `latta-plumbing.md`).

## Stamp format

```yaml
---
name: Smith, John
type: individual          # individual | entity
role: plaintiff           # plaintiff | defendant | witness | third-party | client
matters:
  - <matter-folder-name>
conflict_status: clear    # clear | flagged | declined
---
```

Body of the stamp holds short, durable notes: aliases, employer, key facts, prior communications. Keep it concise — a stamp is a registry entry, not a dossier.

## What NOT to put here

- **Do not store** SSNs, account numbers, medical record numbers, or other regulated identifiers. Keep those in the matter file with appropriate protection.
- **Do not store** client-confidential strategy or attorney work product. Stamps are practice-wide; strategy is matter-specific.

## How stamps get written

- Automatically by `/intake` when a new matter identifies a party
- Manually via `/add-to-registry` when a party comes up outside intake
- Updated by `/close-matter` to record final conflict status

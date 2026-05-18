# jurisdictions/

Court-specific procedural rules, filing conventions, and packaging requirements. Each jurisdiction is its own subfolder.

## Planned jurisdictions

- `alabama-state/` — Alabama Rules of Civil Procedure, state-court filing conventions, AlaFile e-filing portal
- `federal-northern-alabama/` — Northern District of Alabama local rules, PACER / CM-ECF conventions

## Folder layout inside a jurisdiction

```
<jurisdiction>/
├── rules/                  # jurisdiction-specific procedural rules and local rules
├── templates/              # caption formats, certificate-of-service language
├── filing/                 # portal quirks, page limits, accepted file types, header format
└── README.md
```

## How it works

The matter's `CLAUDE.md` declares the court in which it's pending; Claude reads the relevant jurisdiction folder for filing format, deadline math, and procedural posture.

## Adding a new jurisdiction

Create a new subfolder with the format `<state-or-court-name>/`, populate the four pieces above, and run `/sync-practice` in any matter pending in that jurisdiction.

## Status

Skeleton only. Jurisdiction content to be authored when a matter actually needs it.

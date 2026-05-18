# jurisdictions/

Court-specific procedural rules, filing conventions, and deadline numbers. Each jurisdiction is its own subfolder.

The kit's core rules (in `../rules/`) are jurisdiction-neutral **frameworks** — they describe method and discipline. The actual numbers and citations — statutes of limitations, response deadlines, time-computation rules, filing-portal quirks — live here, per jurisdiction.

## Jurisdictions present

- `federal/` — the Federal Rules of Civil Procedure, which apply nationwide. A specific federal district's local rules build on this in their own folder.
- `alabama-state/` — Alabama state-court rules. The kit's worked example of a state jurisdiction; a firm elsewhere copies its shape and replaces the content.

## Folder layout inside a jurisdiction

```
<jurisdiction>/
├── README.md
├── deadlines.md          # SOLs, notice periods, response deadlines, time computation
├── rules/                # jurisdiction-specific procedural and local rules
├── templates/            # caption formats, certificate-of-service language
└── filing/               # portal quirks, page limits, accepted file types, header format
```

`README.md` and `deadlines.md` are the starting point; `rules/`, `templates/`, and `filing/` fill in as matters need them.

## How it works

A matter's `CLAUDE.md` declares the court it's pending in. Claude reads that jurisdiction's folder for deadline numbers, filing format, and procedural posture — and the neutral core rule (`../rules/deadlines.md`, and so on) for the method that applies everywhere.

## Adding a jurisdiction

Create a subfolder named for the state or court, give it a `README.md` and a `deadlines.md`, and fill the rest as needed. A firm in another state typically starts by copying `alabama-state/` and replacing its content.

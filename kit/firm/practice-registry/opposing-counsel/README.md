# opposing-counsel/

One stamp per opposing firm — or per individual attorney where the attorney is the relevant unit. File name: `<firm-name>.md` (e.g., `smith-and-associates.md`) or `<firm>--<attorney-last>.md` (e.g., `smith-and-associates--doe.md`).

## Stamp format

```yaml
---
id: smith-associates           # filename slug — the @counsel handle
type: counsel
tags: []
refs:                          # matters this counsel connects to
  - "@matter:<matter-id>"
firm: "Smith & Associates, LLC"
attorney: "Jane Doe"
contact:
  email: jdoe@smithassoc.com
  phone: 555-0100
style_summary: aggressive on discovery; settles late
---
```

Body holds durable observations: negotiation patterns, courtroom style, frequent objections, settlement tendencies. This is the institutional memory of the practice — what every member learns about facing them.

## Useful for

- `/case-plan` — calibrate the discovery posture and motion strategy
- Settlement-demand timing
- Trial preparation — anticipate cross-examination style

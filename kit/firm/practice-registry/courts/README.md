# courts/

One stamp per court (or per division within a court). File name: `<state>-<county>-<level>.md` — e.g. `<state>-<county>-circuit.md`, `<state>-<county>-district.md`.

## Stamp format

```yaml
---
id: <state>-<county>-circuit   # filename slug — the @court handle
type: court
tags: []
refs:                          # matters filed in this court
  - "@matter:<matter-id>"
court: "<Full court name>"
jurisdiction: <jurisdiction tag from vocabulary/jurisdictions.md>
clerk:
  name: <name>
  phone: <number>
  email: <email>
efile_portal: <e-file portal name, if any>
filing_fee_civil: <amount>
local_rules: <path or URL>
---
```

Body holds quirks: paper-vs-electronic preferences, courtesy-copy requirements, walk-in hours, security at the courthouse, parking, whether the clerk accepts faxed corrections, judges' preferences for orders.

## Useful for

- `/file-with-court` — read this stamp before packaging a filing
- `/calendar` — link a deadline to the right court's rules
- Onboarding a new staff member — practical "how this courthouse works" notes

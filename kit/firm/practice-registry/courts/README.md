# courts/

One stamp per court (or per division within a court). File name: `<state>-<county>-<level>.md` (e.g., `al-jefferson-circuit.md`, `al-madison-district.md`, `al-northern-federal.md`).

## Stamp format

```yaml
---
court: Jefferson County Circuit Court (Civil Division)
jurisdiction: alabama-state
clerk:
  name: <name>
  phone: <number>
  email: <email>
efile_portal: AlaFile
filing_fee_civil: $XXX
local_rules: <path or URL>
matters:
  - <matter-folder-name>
---
```

Body holds quirks: paper-vs-electronic preferences, courtesy-copy requirements, walk-in hours, security at the courthouse, parking, whether the clerk accepts faxed corrections, judges' preferences for orders.

## Useful for

- `/file-with-court` — read this stamp before packaging a filing
- `/calendar` — link a deadline to the right court's rules
- Onboarding a new staff member — practical "how this courthouse works" notes

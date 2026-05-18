# experts/

One stamp per expert. File name: `<last-first>-<specialty>.md` (e.g., `garcia-roberto-accident-recon.md`).

## Stamp format

```yaml
---
expert: Roberto Garcia, P.E.
specialty: accident reconstruction
firm: <expert's firm>
contact:
  email: <email>
  phone: <number>
hourly_rate: $XXX
deposition_rate: $XXX
trial_rate: $XXX
matters_retained:
  - <matter-folder-name>
matters_opposed:
  - <matter-folder-name>
---
```

Body holds substantive notes: testimony style, Daubert challenges survived or lost, prior cases (with citations if known), weaknesses encountered on cross, preferred materials format.

## Useful for

- `/case-plan` — pick a retained expert
- `/deposition-prep` — when deposing an opposing expert, recall prior opposition patterns
- Daubert / qualifications briefing — assemble prior-testimony record quickly

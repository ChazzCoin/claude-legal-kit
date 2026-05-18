# experts/

One stamp per expert. File name: `<last-first>-<specialty>.md` (e.g., `garcia-roberto-accident-recon.md`).

## Stamp format

```yaml
---
id: garcia-roberto-accident-recon   # filename slug — the @expert handle
type: expert
tags: []
refs:                               # every matter this expert connects to
  - "@matter:<matter-id>"
expert: "Roberto Garcia, P.E."
specialty: accident reconstruction
firm: <expert's firm>
contact:
  email: <email>
  phone: <number>
hourly_rate: <amount>
deposition_rate: <amount>
trial_rate: <amount>
matters_retained:                   # subset of refs — matters the firm retained this expert for
  - "@matter:<matter-id>"
matters_opposed:                    # subset of refs — matters this expert was opposed in
  - "@matter:<matter-id>"
---
```

Body holds substantive notes: testimony style, Daubert challenges survived or lost, prior cases (with citations if known), weaknesses encountered on cross, preferred materials format.

## Useful for

- `/case-plan` — pick a retained expert
- `/deposition-prep` — when deposing an opposing expert, recall prior opposition patterns
- Daubert / qualifications briefing — assemble prior-testimony record quickly

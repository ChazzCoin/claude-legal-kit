# firm/

Everything inside this folder is **shared across the practice**. When this drive eventually becomes a network share or NAS-replicated workspace, this is the folder that gets replicated to every workstation.

## What's here

- **practice-kit/** — source of truth for skills, rules, document templates, and document workflows. Edit here once; changes propagate to every matter via the sync mechanism.
- **practice-registry/** — cross-matter database of parties, opposing counsel, courts, judges, and experts. Short metadata stamps, not document storage.
- **matters/** — active client matters. Each is its own project folder with a `.claude/` synced from practice-kit.
- **closed-matters/** — resolved matters. Retention timing governed by `practice-kit/shared-library/rules/retention.md`.

## Boundary

Firm-owned. Edits propagate to everyone. Individual members do personal drafts and notes inside `/members/<name>/`, then *promote* finished work into a matter under this folder when it's ready to be part of the file.

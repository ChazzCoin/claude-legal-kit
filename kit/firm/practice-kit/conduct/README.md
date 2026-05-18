# conduct/

How Claude **conducts itself** inside a firm that runs this kit — the binding behavioral rules. Three rules live here:

- **[communication.md](communication.md)** — plain English, offers-not-instructions, the permission-line format, legal framing, proactiveness, confidentiality.
- **[save-load.md](save-load.md)** — the *save / load / delete* metaphor for moving work to and from the cloud, and how disagreements are handled without losing anyone's work.
- **[running-scripts.md](running-scripts.md)** — running the right script flavor for the operating system: `.ps1` on Windows, `.sh` on macOS/Linux, chosen from `.claude/platform.json`.

## Status

These are **kit-managed**. They sync from the kit, so an improvement made once propagates to every firm running the kit. A firm's own root `CLAUDE.md` points here as the authoritative source, and may add firm-specific detail in its own file — it must **never loosen** what these rules require.

## Why a separate folder

These are rules about *how Claude behaves*. They are deliberately kept apart from [`../shared-library/rules/`](../shared-library/rules/), which holds rules of *legal practice* — privilege, conflicts, deadlines, retention, Bates numbering. Different kind of rule, different home.

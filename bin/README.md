# bin/

Scripts that operate on the **kit repo itself** — run by a person setting up
or maintaining the kit, not by Claude inside a firm session. `bin/` is not
copied into a firm home.

## Cross-platform — every script is paired

The kit serves firms on **Windows and on macOS/Linux**. Each script ships in
two flavors with the same behavior:

| Script | macOS / Linux | Windows |
|---|---|---|
| Bootstrap a firm home | `bin/init` (bash) | `bin/init.ps1` (PowerShell) |
| Audit `MANIFEST.json` | `bin/check-manifest` (bash) | `bin/check-manifest.ps1` (PowerShell) |

Run the flavor that matches your operating system:

```sh
# macOS / Linux
claude-legal-kit/bin/init /path/to/firm-home
claude-legal-kit/bin/check-manifest
```

```powershell
# Windows (Windows PowerShell 5.1 or PowerShell 7+)
claude-legal-kit\bin\init.ps1 -Target C:\path\to\firm-home
claude-legal-kit\bin\check-manifest.ps1
```

## Requirements

| | macOS / Linux | Windows |
|---|---|---|
| `init` | `python3` (parses `MANIFEST.json`), `git` (optional, for the SHA pin) | `git` only — PowerShell parses JSON natively, no Python needed |
| `check-manifest` | `python3`, `git` | `git` only |

The PowerShell ports are intentionally **self-contained** — they drop the
`python3` dependency the bash scripts carry, because Python is not present on
a default Windows install but PowerShell's `ConvertFrom-Json` is.

## Which script runs *inside* a firm — and how Claude knows

The paired scripts inside the practice-kit (`firm/practice-kit/scripts/` —
`new-matter`, `sync-matter`, `new-member`, `detect-platform`) are the ones
Claude may run during a firm session. Claude picks `.ps1` vs `.sh` from
`.claude/platform.json`, which the `SessionStart` hook in
`.claude/settings.json` writes each session. The binding rule for this is
`firm/practice-kit/conduct/running-scripts.md`.

`bin/init` and `bin/check-manifest` are different — a human runs them, and
the human just picks the flavor for their own machine. No detection needed.

# Conduct rule — Running kit scripts on Windows vs. macOS/Linux

**Binding for every session.** This is a kit-managed rule; an improvement made here propagates to every firm running the kit.

## Why this rule exists

A firm's members may be on **Windows or on macOS/Linux** — and the same firm home may be opened on different machines (it can live on a shared drive). The kit ships every script in **two paired flavors**:

| Operating system | Script flavor | Shell |
|---|---|---|
| Windows | `*.ps1` | PowerShell |
| macOS / Linux | `*.sh` | bash / sh |

The two files in a pair (e.g. `detect-platform.sh` and `detect-platform.ps1`) **do the same thing**. Running the wrong one for the operating system fails. This rule keeps Claude from doing that.

## The platform config — `.claude/platform.json`

The kit records which operating system the firm home is currently open on in `.claude/platform.json`:

```json
{
  "platform": "windows",
  "family": "windows",
  "scriptExtension": ".ps1",
  "scriptShell": "powershell",
  "detectedAt": "...",
  "detectedBy": "detect-platform.sh"
}
```

This file is written automatically:

- **At install** — by `bin/init` / `bin/init.ps1`.
- **At the start of every session** — by the `SessionStart` hook in `.claude/settings.json`, which runs the platform detector. This is what keeps the file correct when the firm home moves between a Windows machine and a Mac.

## What Claude does

**Before running any kit script, read `.claude/platform.json` and run the flavor named in `scriptExtension`.**

- `scriptExtension` is `.ps1` → run the PowerShell script with `powershell` (or `pwsh`).
- `scriptExtension` is `.sh` → run the shell script with `sh` / `bash`.

**If `.claude/platform.json` is missing or looks wrong**, do not guess and do not run a script blind. Detect the operating system directly first — for example, the working environment, `uname` on macOS/Linux, or `$env:OS` on Windows — then run `detect-platform.sh` / `detect-platform.ps1` to (re)write the config. If detection is genuinely unclear, ask the member which kind of computer they are on rather than running the wrong script.

## How Claude talks about this with the member

Same as every conduct rule: **plain English, no technical jargon.** A member never needs to hear "PowerShell," ".ps1," "shell," or "platform.json." If something must be said at all, it is at the level of *"setting this up for your computer"* — and most of the time nothing needs to be said, because the right script just runs.

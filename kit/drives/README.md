# drives/

Every storage location the firm uses, tracked here. One short file per drive with the basics: what it is, how it connects, what's stored on it, and how Claude knows whether it's available right now.

When you ask Claude for a file or a matter, Claude checks this registry to figure out which drive holds it and whether that drive is plugged in. If a needed drive isn't available, Claude tells you immediately — instead of failing halfway.

## Example entries

A firm typically registers something like:

- **this-computer.md** — the primary workstation. Holds the firm setup, the kit, members, the drive registry, the private vault, and new active matter files.
- **archive-drive.md** — an external drive for legacy case files, evidence, trial materials, and other archived content.

## How a new drive gets added

When a new storage location enters the picture (a new USB drive, iCloud Drive, a shared Dropbox, a NAS), just tell Claude what it is and where it lives, and Claude creates a new file here for it.

## A drive is identified by its volume, not its mount path

Where a drive *appears* is not stable. The same external SSD is `/Volumes/Archive` on a Mac and a drive letter like `E:\` on Windows — and on Windows that letter can change between one plugging-in and the next. A mount path cannot be a drive's identity.

So each drive has a stable **volume_id** — a volume UUID or serial number that travels with the hardware. The document index (`.claude/tools/index/`) stores every file's location as *which volume, and the path within it*; the live mount path is resolved fresh each session. The indexer resolves a volume's id automatically the first time it crawls that drive — you do not type it by hand. Record it here once it is known, so the registry and the index agree.

## Fields each drive file uses

At the top of each drive file:
- **name** — human label (the way the firm refers to it)
- **type** — internal-drive | external-ssd | usb-flash | cloud-sync | network-share
- **volume_id** — the stable volume UUID / serial (the drive's real identity; from the indexer)
- **mount_path** — where it currently appears when connected — per-machine and per-OS (`/Volumes/Archive` on a Mac, `E:\` on Windows). Informational; the index does not rely on it.
- **connection** — how it connects (USB-C, Wi-Fi, always-on, cloud-sync)
- **auth_required** — does it need a password / sign-in / nothing
- **status** — active | planned | retired
- **mount_check** — quick way to confirm it's available right now
- **holds** — plain-English summary of what's stored on it
- **owner** — firm | member name | shared

Below that, free-form notes.

A ready-to-fill drive file is in `_drive-template.md`.

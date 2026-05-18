# drives/

Every storage location the firm uses, tracked here. One short file per drive with the basics: what it is, how it connects, what's stored on it, and how Claude knows whether it's available right now.

When you ask Claude for a file or a matter, Claude checks this registry to figure out which drive holds it and whether that drive is plugged in. If a needed drive isn't available, Claude tells you immediately — instead of failing halfway.

## What's registered today

- **macbook-local.md** — your MacBook Pro (this Mac). Holds firm setup, kit, members, drive registry, private vault, and new active matter files.
- **t7-shield.md** — the Samsung T7 Shield external SSD. Holds legacy case files (the `Cases/` folder), evidence (drone footage), trial presentations, and other archived materials.

## How a new drive gets added

When a new storage location enters the picture (a new USB drive, iCloud Drive, a shared Dropbox, a NAS), just tell Claude what it is and where it lives, and Claude creates a new file here for it.

## Fields each drive file uses

At the top of each drive file:
- **name** — human label (the way the firm refers to it)
- **type** — internal-drive | external-ssd | usb-flash | cloud-sync | network-share
- **mount_path** — where it appears on the Mac when connected (e.g., `/Volumes/T7 Shield/`)
- **connection** — how it connects (USB-C, Wi-Fi, always-on, cloud-sync)
- **auth_required** — does it need a password / Apple ID / nothing
- **status** — active | planned | retired
- **mount_check** — quick way to confirm it's available right now
- **holds** — plain-English summary of what's stored on it
- **owner** — firm | member name | shared

Below that, free-form notes.

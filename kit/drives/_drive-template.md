---
name: <human label — the way the firm refers to this drive>
type: <internal-drive | external-ssd | usb-flash | cloud-sync | network-share>
volume_id: <stable volume UUID / serial — filled in once the indexer has crawled it>
mount_path: <where it currently appears, e.g. /Volumes/Archive or E:\ — informational, per-machine>
connection: <USB-C | Wi-Fi | always-on | cloud-sync>
auth_required: <password | sign-in | none>
status: <active | planned | retired>
mount_check: <a quick way to confirm it is available right now>
holds: <plain-English summary of what is stored on this drive>
owner: <firm | member name | shared>
---

# <drive name>

Free-form notes about this drive — what it is for, anything unusual about
how it connects, what to do if it is not available, history.

> `volume_id` is the drive's real identity and is what the document index
> uses. `mount_path` only records where it happens to appear on a given
> machine — it is not relied on, and it will differ between macOS and
> Windows. The indexer fills `volume_id` in automatically the first time it
> crawls this drive; copy it here once known.

# Local Files (Sym-Link Folder)

This folder holds **sym-links** to local files referenced by Research Library Reference records.

## The rule: never copy, never move

We never copy files into this folder, and we never move files into this folder. Each entry is a sym-link to a file that lives in its original location — typically a matter folder, the firm's documents folder, or another organized location.

## Why sym-link?

- A file lives in exactly one place — no risk of divergent copies drifting over time
- If the original is renamed or deleted, the sym-link breaks loudly rather than silently going stale
- Disk space stays sane even as the library grows

## Naming convention

Sym-links are named `REF-NNNN-<slug>.<ext>` so the target Reference record is identifiable at a glance.

## Creating a sym-link

```
ln -s "/absolute/path/to/original.pdf" "<firm-home>/firm/practice-kit/research-library/files/REF-NNNN-slug.pdf"
```

Claude creates these automatically when adding any Reference that points to a local file.

## What's in here right now

(empty)

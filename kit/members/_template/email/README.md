# email/ — personal email workspace

Your private space for drafting emails, tracking conversations, and keeping email-related notes. Not visible to the firm by default. Same confidentiality rules as the rest of `members/<you>/` apply.

## What lives here

```
email/
├── README.md                — this file
├── _contact-template.md     — copy this to start a new contact log
├── _draft-template.md       — copy this to start a new draft
├── contacts/                — one file per person you correspond with
├── drafts/                  — works in progress (one file per draft)
├── sent/                    — drafts you've actually pasted into Outlook + sent
└── notes/                   — anything else: templates, follow-up reminders,
                                signature variants, email-related thoughts
```

## How the flow works

1. **You ask** for an email — e.g. "Draft a reply to Jane Doe about the Smith status."
2. **Claude searches** your Outlook inbox for context (the prior thread, prior exchanges with Jane).
3. **Claude creates a draft file** in `drafts/` — full body, suggested subject and recipients, status `draft`.
4. **Claude updates the contact log** in `contacts/` — a one-line entry noting the draft, linked.
5. **You review** the draft right in the file. Edit, tighten, change tone. Ask Claude for revisions.
6. **When you're happy**, copy the body into Outlook, send it, and tell Claude "sent."
7. **Claude moves** the file from `drafts/` to `sent/` and marks the contact-log entry sent.

## File-naming conventions

**Drafts:** `YYYY-MM-DD-<contact-slug>-<short-topic>.md`
Example: `2026-05-18-jane-doe-smith-status.md`

**Contacts:** `<firstname>-<lastname>.md`, all lowercase, hyphenated.
Example: `jane-doe.md`. For firms or organizations, use the firm name slug: `acme-insurance.md`.

**Sent:** keeps the original draft filename. Don't rename on move.

**Notes:** anything you want. Date-prefix optional.

## What goes in a contact file

A header with who they are, their contact info, what matters they relate to, and any preferences (tone they expect, response-time norms, things to never mention). Below that, a running log of every exchange — date, direction, subject, one-line summary, link to the draft.

Use `_contact-template.md` as a starting point.

## What goes in a draft file

A header block (To, CC, BCC, Subject, Status, Date, Matter), the body in plain markdown, and a working-notes section at the bottom for thoughts that should never be sent. When you paste into Outlook, copy only the body — the header and working notes stay in the file.

Use `_draft-template.md` as a starting point.

## Save and load

These files sit on your Mac. Save and load using the firm's normal save/load — same as everything else in the kit. Drafts mid-conversation are perfectly fine to leave un-saved until you're ready.

## Boundaries

- **Personal.** Other members can't see your `email/` folder by default.
- **Still privileged.** Drafts are still attorney work product — same confidentiality rules.
- **Promote when it matters.** When an email becomes part of a matter's record (a settlement offer, a discovery dispute, formal correspondence with opposing counsel), move the sent copy into `firm/matters/<Matter>/04-Correspondence/`.

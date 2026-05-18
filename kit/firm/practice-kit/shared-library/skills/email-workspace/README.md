# Skill: email-workspace

How Claude works inside a member's personal `email/` workspace.

This is firm-wide guidance. Every member has the same structure under `members/<them>/email/`. The workspace is the bridge between Outlook (read via the Microsoft 365 connection) and what the member actually sends — drafts live as markdown files, the member reviews, copies into Outlook, and sends.

## When to invoke this skill

Whenever the member asks for anything involving outgoing email — drafting, replying, following up, "what should I say to X about Y" — work happens inside `members/<them>/email/`. Never write email drafts to random places.

## Layout (per member)

```
members/<them>/email/
├── README.md
├── _contact-template.md
├── _draft-template.md
├── contacts/<firstname-lastname>.md         (or <org-slug>.md)
├── drafts/YYYY-MM-DD-<contact>-<topic>.md
├── sent/<same filename as the draft>
└── notes/
```

## The drafting flow

When the member asks for a draft:

1. **Search Outlook first.** Use the Microsoft 365 connection to pull the prior thread or any prior correspondence with this person. Skip if obviously not needed (cold outreach).
2. **Check `contacts/<them>.md`.** If it exists, read it — tone, preferences, prior context. If it doesn't, offer to create it after the draft is done.
3. **Read `firm/FIRM.md` and the member's `CLAUDE.md`** for letterhead, signature block, and member-specific preferences. Always pull the signature from these files — never invent one.
4. **Create the draft file** at `drafts/YYYY-MM-DD-<contact-slug>-<short-topic>.md` using `_draft-template.md` as the schema. Fill the header (To, CC, Subject, Status=draft, Date, Matter), then the body, then a "Working notes" block at the bottom for anything Claude wants to flag that should not be sent (alternatives considered, things to verify, follow-up suggestions).
5. **Append a row to `contacts/<them>.md`** in the exchange log — date, direction=out, subject, one-line summary, link to the draft file.
6. **Tell the member** in plain English: where the draft lives, what's in it, and any open questions ("I left the settlement figure blank — what number do you want?").

## When the member says "sent"

1. Update the draft's header `status:` from `draft` (or `ready`) to `sent`.
2. Move the file from `drafts/` to `sent/` — same filename.
3. Update the matching row in `contacts/<them>.md` to reflect sent status.
4. Offer to promote a copy into `firm/matters/<Matter>/04-Correspondence/` if the email is part of a matter's formal record (opposing-counsel correspondence, settlement, discovery, anything litigation-relevant).

## When the member says "they replied"

1. Search Outlook for the new incoming message, read it.
2. Append a row to `contacts/<them>.md` — direction=in, subject, one-line summary.
3. Offer to draft a response.

## Confidentiality

- Never send draft contents to any web tool, search, pastebin, or external service.
- Outlook search queries use the connected Microsoft 365 connection only — those queries go to Microsoft, not to a third-party AI service.
- Drafts are attorney work product. Same rules as the rest of the kit.

## Save / load

The workspace files live on the member's Mac. Save and load using the firm's normal save/load vocabulary. Offer to save at natural stopping points — after a draft is finalized, after a "sent" sweep, at the end of a session.

## Future: send-from-Claude

When the firm adds a Microsoft 365 connector with send / create-draft capability, this skill grows two new verbs: "put this in Outlook drafts" and (with explicit confirmation) "send this." Until then, the member copies and pastes manually. Don't pretend to send.

## Notes on tone

- The member is an attorney. Email tone matches firm norms — see `firm/FIRM.md` for letterhead and `members/<them>/CLAUDE.md` for personal voice preferences.
- Default: professional, concise, no filler. If the member's CLAUDE.md says otherwise, follow that.
- Never insert emojis unless the member explicitly asks.

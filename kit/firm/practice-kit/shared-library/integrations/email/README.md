# email/

**Status:** Read-only Outlook is connected (search inbox, calendar, SharePoint). Send / create-draft is still planned.

**Stopgap until send is wired up:** each member has a personal email workspace at `members/<them>/email/`. Claude searches Outlook, drafts the reply as a markdown file there, the member copies the body into Outlook to send. Workflow guidance for Claude lives in `firm/practice-kit/shared-library/skills/email-workspace/README.md`.

## What this will do once we set it up

- **Read incoming email** — pull new messages from the firm's inbox(es).
- **File email into matters** — drop incoming messages into the right matter's `04-Correspondence/` folder, with sender, date, subject line tracked.
- **Draft replies** — Claude writes responses that match firm tone, with the right signature block, for the attorney to review and send.
- **Search across all email** — find every message touching a client, opposing counsel, or matter, instantly.

## Why this matters for our practice

A PI / trial practice runs on correspondence. Letters in, letters out, settlement back-and-forth, court orders, medical-record requests. Almost all of that is email or PDFs sent by email. Centralizing it under each matter means nothing slips.

## What we need to decide before turning it on

1. **Which email service?** Gmail or Outlook.
2. **Which mailboxes?** Individual members' mailboxes? A shared firm mailbox?
3. **What can Claude do without asking?** Auto-file incoming messages: probably yes. Auto-send replies: probably no. Draft replies for review: probably yes.
4. **What's off-limits?** Personal email, communications that shouldn't be in the firm record, anything attorney-client privileged with another attorney.

## Confidentiality notes

- All email is privileged communication or work product.
- The email connection runs locally on the firm's account — emails aren't sent to any outside AI service beyond what's needed for the connection itself.
- Exact data flow gets reviewed before going live.

## When ready, just say so

When you're ready to add a send-capable connector (so Claude can put drafts into Outlook directly and, with explicit confirmation, send), just tell me and I'll walk us through the setup step by step in plain English.

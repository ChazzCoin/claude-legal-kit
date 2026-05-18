---
name: register-member
description: Bring a new firm member's computer online — guide them to create their access key, approve it, and confirm they can reach the firm's private workspace
status: authored 2026-05-18
---

# /register-member

Connects a new firm member's computer to the firm's private workspace. This skill is run by an **administrator** — someone whose computer is already set up. By the time it finishes, the new member's computer can open, read, and save the firm's files.

## How the connection works (so Claude explains it correctly)

The firm's workspace is private — a computer can only reach it once it has been **approved**. Approval is built on a pair of matched keys created on the new member's own computer:

- The **secret half stays on the member's computer** and never travels anywhere. Nobody emails it, and Claude never asks for it.
- The **shareable half — the "access code"** — is safe to send by any means. The administrator registers that code with the firm's workspace, which approves that one computer.

Never reverse this. If a member is ever about to send the *secret* half (a block that starts with `-----BEGIN`), **stop them** — that is not what gets shared.

## When to use

- A new lawyer or staff member is joining and needs the firm's files on their computer.
- An existing member got a new computer and needs to connect it.
- A member's access was removed and needs to be re-established.

## When NOT to use

- To open a new client matter — that's `/intake`.
- To set up the very first computer of a brand-new firm — that's the kit's install step (`bin/init`), not this skill.

## What Claude needs to know first

- **Which kind of computer the new member uses** — a Mac or a Windows computer. The setup helper comes in one version for each.
- **Whether the member has already sent their access code.** This decides which half of the job is left:
  - Not yet → Claude prepares the message to send them (Step 2).
  - Already sent → Claude approves it (Step 3).

The administrator's own computer needs the firm's cloud connection ready (the GitHub CLI, `gh`, signed in). If it isn't, Claude says so plainly and offers to walk through it before going further.

## Flow

### Step 1 — Find out where the new member is

Ask the administrator: *"Has the new member already created and sent you their access code?"*

- **No** → go to Step 2.
- **Yes** → go to Step 3.

### Step 2 — Give the new member their setup instructions

The member needs to run the kit's setup helper on their own computer. The helper lives in the kit's **public** home, so they can get it before they have any firm access.

Ask which computer they use, then prepare a plain-English message the administrator can send them (Claude does not send it — the administrator does). The message should tell the member to:

1. Open the kit's public page: `https://github.com/ChazzCoin/claude-legal-kit`
2. Get the setup helper from the `bin/` folder — `register-user.sh` for a Mac, `register-user.ps1` for a Windows computer. (Downloading that one file is enough; the helper is self-contained.)
3. Run it. It will create their access key and show an **access code**.
4. Copy the whole access code and send it back to the administrator.

Then **stop**. Tell the administrator to return to this skill once the member sends the code.

### Step 3 — Approve the new member

1. **Check the firm's cloud connection.** If the GitHub CLI isn't installed or signed in, explain it plainly and help set it up before continuing.
2. **Take the access code** the administrator received. If what they paste begins with `-----BEGIN`, that is the *secret* half — stop, explain the member should send only the short access code (one line starting with `ssh-`), and do not store what was pasted.
3. **Confirm before approving.** Approving gives a new computer access to the firm's private files — a deliberate step. Ask the administrator for an explicit go-ahead. The permission line reads: *"Claude wants to give a new member access to the firm's workspace."*
4. **Decide the access level.** The default is **read and save** — the member can both open the firm's files and save their own work back. Offer read-only if the administrator wants a view-only member.
5. **Run the approval.** Use the kit's admin helper — `firm/practice-kit/scripts/register-admin.sh` on macOS/Linux, `register-admin.ps1` on Windows. Pick the version that matches this computer; the rule for that is in `firm/practice-kit/conduct/running-scripts.md`.
6. **Hand back the confirmation.** The helper prints a short "you're approved" message with the workspace address. Give that to the administrator to send to the member, who runs their setup helper once more — this time with the address — to finish connecting.

### Step 4 — Offer to set up their workspace folder

Once the member is approved, offer to create their personal workspace folder under `members/` (a copy of `members/_template/`, with their name and role filled in). This is the same thing the planned `new-member` helper will do; until that helper is finished, Claude can do it directly.

## Outputs

- The new member's computer is approved for the firm's private workspace.
- Two ready-to-send plain-English messages handed to the administrator: the setup instructions, and the approval confirmation.
- Optionally, a new `members/<name>/` workspace folder.

## Failure modes

- **The firm's cloud connection isn't ready** — the GitHub CLI is missing or not signed in. Stop and help set it up; don't work around it.
- **The access code is already in use** — GitHub allows each code only once. Ask the member to run their setup helper again so a fresh one is created.
- **The administrator's account lacks the rights** — approving requires an account with administrative rights on the firm's workspace. Stop and explain.
- **A secret key was pasted by mistake** — stop immediately, do not store it, and explain what to send instead.
- **Unknown computer type** — if it's unclear whether the member is on a Mac or Windows, ask before sending setup instructions.

## Don't do this

- **Never ask for, accept, or store the secret half of a member's key.** Only the public access code is ever shared.
- **Never approve without the administrator's explicit go-ahead.** Access to privileged client files is not granted on assumption.
- **Don't send anything externally.** This skill prepares messages; the administrator sends them. Claude does not email the member.
- **Don't generate a member's key on the administrator's computer and ship it to them.** A key is created on the computer that will use it — that is the whole point of the access-code design.

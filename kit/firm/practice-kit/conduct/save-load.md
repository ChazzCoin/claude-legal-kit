# Conduct rule — Save / Load: how Claude moves work to and from the cloud

**Binding for every session.** This is a kit-managed rule; an improvement made here propagates to every firm running the kit.

## Master rule

**Never talk to firm members in version-control terminology.** The firm's working metaphor is a Word document: there is one document, and a member can **save**, **load**, or **delete** from it. That is the only vocabulary Claude uses with firm members when work moves between this computer and the cloud.

## What the words mean

| What Claude says to the member | What is happening underneath (Claude does NOT say this to the member) |
|---|---|
| **save** / **save your work** | stage + commit + push to the main line |
| **load** / **load saved work from the cloud** | fetch + merge from the main line |
| **delete** | remove file(s) from tracking + save |
| **safety copy** | a side branch — used only as a fallback (see below) |
| **the cloud** / **your saved work in the cloud** | the hosted remote |

## When to offer to save

Proactively, at natural stopping points:

- After a meaningful set of edits.
- At the end of a working session.
- After Claude has finished a task the member confirmed is done.

The question is always: **"Would you like to save this work?"** Never "should I commit," "want me to push," and the like.

## Where work goes

Everything goes to the main line. **No side reviews. No long-lived side copies.** A side copy exists for one purpose only: a **safety copy** when an automatic combine is not safe (see next).

## Disagreement handling — automatic, never lose anyone's work

When a member asks to save and the cloud already has changes from another computer or another session:

1. **Check the cloud first** before sending anything up.
2. **If nothing disagrees**, save normally.
3. **If two edits touch different parts of the same file**, **smart-combine** them — keep both sides' edits. This is the common case.
4. **If two edits overlap on the exact same lines** (a real disagreement that cannot be safely auto-combined): DO NOT pick a winner.
   - Put the member's local work into a **safety copy** in the cloud (a side copy named like `safety-2026-05-15-1430`).
   - Tell the member in plain English: "I couldn't combine cleanly. Your work is safely backed up in the cloud as a safety copy called X. These specific spots disagreed: [list]. Which version wins?"
   - Wait for the member to decide. Never overwrite, never guess.
5. **Never** force-overwrite. **Never** bypass safety checks. **Never** discard local edits without the member's explicit "yes, throw it out."

## Load handling

- "Load" means: bring down what is in the cloud and combine it with what is on this computer.
- If loading would clash with un-saved local edits, set those edits aside first, load, then re-apply.
- If re-applying clashes, same fallback: safety copy + tell the member in plain English.

## Delete handling

- "Delete" means: remove the file(s) and save.
- **Always confirm before delete.** Even if a member just said "delete X," Claude says back "Delete <plain name> and save?" and waits for a yes.

## Forbidden words in member-facing text

commit, merge, branch (except as "safety copy"), pull request, pull, push, fetch, rebase, stash, remote, origin, HEAD, conflict (use "disagreement"), staging, working tree, repo, repository, clone, checkout.

# RUNBOOK.md — when the agent does something wrong in a live system  ·  TEMPLATE (this project owns it)

> **Seeded by the Claude Harness Kit, then handed to you. It is now yours.** Delete this banner
> once you've adapted the steps to this project.
>
> **TIER-OPTIONAL.** If this project has no live system an agent can damage — a throwaway, a pure
> library, nothing deployed and no outside state — you don't need this file; skip it. Keep it the
> moment the agent can touch something you'd have to *recover*: a server, a database, a deploy, a
> published artifact, someone else's inbox.

**What this is.** The *forward* procedure you run **the moment you realize an agent has done
something wrong in a live system** — before you understand *why*. It is deliberately terse: you are
reading it under stress. The analysis comes later (see the last step). Read top to bottom; don't
skip to diagnosis.

**If you're in it right now — the five steps, in order:**

## 1. Contain
Stop the bleeding first. **Interrupt the agent** (stop the session / kill the run). If a scheduled,
background, or credentialed job is mid-flight, **kill it now** rather than letting it finish — a
half-run job can do more damage than a stopped one. Don't diagnose yet; just make it stop acting.

## 2. Revoke or rotate any credential involved
If the agent used a token, key, session, or connector credential that may have been **misused or
exposed**, revoke or rotate it *now*, before you understand the full scope — a live credential is an
ongoing risk. **Where each credential lives and how to disable each tool is in your tool inventory
(`TOOL_INVENTORY.md`, if you keep one)** — go straight to its `Credential location` and `How to
disable` columns. *Caution:* if the credential feeds a scheduled/cron job, disabling it may not be
enough — make sure the job itself can't re-create or re-grant what you just revoked.

## 3. Identify what was touched
Now find the blast radius. Check, as applicable:
- **Files** — `git status` / `git diff` / `git log` for anything committed or changed.
- **Records** — rows in a database, tickets, entries in an external system.
- **Messages** — emails, chat posts, API calls, anything *sent* (these can't be un-sent — see step 4).
- **External / deployed state** — hosted config, a deployed release, published content.
- Use whatever trail you have: git history, any logging or monitoring, and the recent agent
  transcript (it shows what the agent *tried* to do, which is where to look first).

## 4. Undo or notify
- **Git-tracked changes** → revert them (`git revert` / reset the branch).
- **Everything else** → **restore from your most recent snapshot or backup of the affected system,
  if one exists.** (Taking that snapshot *before* a risky change is the discipline that makes this
  step possible — if you don't have one here, note it as a gap to close after.)
- **What can't be undone** — a message already sent, an external party already affected, money
  already spent → you can't revert it, so **notify** whoever needs to know, promptly and plainly.

## 5. Safeguard — so it can't happen the same way twice
Only after the system is stable:
- **Add a check that would have caught this automatically** — a test, a lint rule, a script
  assertion, a deny/ask gate. A fix without a guard invites the same mistake back.
- **Write it up.** If this project keeps a knowledge base or wiki, add an incident page in whatever
  shape it uses — *what happened → root cause → what you tried that didn't work → the fix.* No wiki?
  Keep a short durable note somewhere it'll be found (a `CHANGELOG`, an incidents file). The point is
  that the next person — or the next agent — learns from it instead of rediscovering it.

---

> **Adapt this per project.** Fill in the concrete specifics: which job to kill, which provider's
> console revokes which credential, where your snapshots live, who to notify. A runbook you have to
> think through mid-incident is half a runbook — the value is in the details being already written down.

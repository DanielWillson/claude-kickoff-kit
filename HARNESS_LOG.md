# HARNESS_LOG.md — harness change log  ·  TEMPLATE (this project owns it)

> **This is a starter template the Claude Kickoff Kit seeded into your project, then
> stepped away from. It is now yours.** It records changes to *this project's* harness —
> the guides, sensors, templates, settings, and rules that shape how the agent works here.
> It is **not** a log of the kit. Delete this banner and the example entry once your own
> first real entry is in.
>
> **Why keep it.** A harness change is a *bet*: every check, rule, or guide you add assumes
> the model can't be trusted to get that thing right on its own. This log records the bet —
> *what* changed and *why* — so a later reader (you, a teammate, or a future agent) can tell
> which changes earned their keep and which were dead weight, instead of assuming. It is the
> **qualitative flight recorder**; its quantitative companion is `scripts/harness-metrics.sh`,
> which logs the *numbers*. This file holds the *reasons* — **a human writes it; the metrics
> script never touches it.**

## How to use it

- **Append-only.** One entry per harness change, newest first, below the anchor. Never
  rewrite a past entry to change what happened — add a new one instead.
- **Filename is fixed.** Keep this file named `HARNESS_LOG.md` at the repo root; setup mandates
  the name and location so tooling and future sessions can always find it.
- **Start small, stay honest.** A solo project's entry can be one line. Don't manufacture
  ceremony; record real changes as they happen.

## Entry schema

Each entry carries these fields:

> **date · change · rationale (the bet) · what it replaced · risk tier · origin**

- **date** — `YYYY-MM-DD` of the change.
- **change** — what changed in the harness, in one or two plain sentences.
- **rationale (the bet)** — what the change was supposed to buy: the failure it prevents or
  the leverage it adds.
- **what it replaced** — the prior approach, or *"net-new — nothing removed."*
- **risk tier** — a quick `low` / `medium` / `high` read of how much could go wrong and how
  hard it would be to undo (a reversible, local change is `low`; one that reaches outside the
  project or is hard to walk back is `high`).
- **origin** — free text: a pointer to whatever prompted the change *in this project* — an
  incident, a review comment, a spec change, an idea borrowed from elsewhere.

> **Keep the schema project-neutral.** The *origin* field is free text on purpose; don't add
> fields that cite tooling-internal or maintainer-only documents — this project doesn't have
> them, and a reference nobody here can resolve is worse than none.

---

## Anchor — kit adoption  ·  *(example — replace the placeholders with your real values)*

- **date:** `<YYYY-MM-DD>`
- **change:** Adopted the Claude Kickoff Kit — seeded the harness (contract, audit, wiki,
  settings floor, this log) at kit version `<kit-version>` (commit `<commit-sha>`).
- **rationale (the bet):** A durable harness makes the agent's work trustworthy without
  babysitting each step; this entry stamps the version we started from, so a later reader can
  tell what the harness looked like at the beginning and what has changed since.
- **what it replaced:** net-new — the project's first harness.
- **risk tier:** low.
- **origin:** project kickoff.

<!-- Copy the block below for your next real change; keep newest entries directly under this line. -->
<!--
## <YYYY-MM-DD> — <short title of the change>
- **change:** <what changed in the harness>
- **rationale (the bet):** <what it was supposed to buy>
- **what it replaced:** <prior approach, or "net-new">
- **risk tier:** <low | medium | high>
- **origin:** <what prompted it — an incident, a review note, an idea from elsewhere>
-->

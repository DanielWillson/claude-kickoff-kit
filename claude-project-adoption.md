# Claude Code — Existing-Project Adoption Guide

> **Purpose.** Hand this file to a Claude Code session inside an **existing, working
> project** to retrofit the Harness Kit's harness onto it. The kickoff guide
> (`claude-project-kickoff.md`) assumes greenfield; this guide re-sequences it for a
> codebase that already runs, already has habits, and already has history. It **points at**
> the kickoff guide's sections rather than restating them — keep both files at hand, read
> the pointed-to section when you reach it.
>
> **The one posture change from greenfield:** in a new project the first job is to build;
> here the first job is to **not break what works**. Everything below is ordered around
> that inversion. The kit's boundary still holds: this guide and its companions are used
> once and never committed into the project (the audit warns if they are).

---

## 0. Evaluate → interview → propose (no edits until the user approves the plan)

A retrofit is gap-driven, not checklist-driven — and the repo's owner holds context no
file can give you. This step has three beats, in order, and **nothing gets edited until
the third is approved**.

### 0a. Evaluate the repo — read-only, and thorough

Build the map before forming opinions (fan the broad sweeps out to subagents, Part 3.13 —
the map matters more than any single file):

- **What already exists of the harness, under other names.** An `AGENTS.md`/`CLAUDE.md`, a
  `docs/` tree, a Makefile/CI pipeline (those are verifiers), lint/format configs, git hooks,
  a test suite. The kit *adapts to* working machinery — it never replaces a verifier that
  already fires with a kit-flavored equivalent (an operator lesson the field keeps
  re-learning: harness automation must earn its keep, per line, against what's already
  there).
- **The safety facts.** Is a secret **already tracked in git**? (`git log` doesn't forget:
  check history, not just the working tree.) Is there a `.claude/settings.json` and what
  does it allow? Who else commits — humans, CI, other tools? What are the real sensitive
  paths?
- **The evidence facts.** What does `git log` say breaks repeatedly? Where do the tests
  actually exercise behavior vs. merely exist? What conventions does the code follow *in
  practice* (not what the docs claim)? Which docs contradict the code or each other —
  contradictory docs are a measured, first-order tax on every future agent session.

### 0b. Interview the user — ask what the code can't answer

The kickoff intake (§1.0a) still applies, but invert the default: **confirm from evidence
what the repo already states** (stack, daily commands, deploy target) and spend the
questions on what only the owner knows:

- Which tests do you actually trust? Which module does everyone fear touching?
- What has burned you repeatedly? What almost-shipped incident still worries you?
- What's about to change — a planned migration, a rewrite, a new committer? (Harness work
  on code that's about to be replaced is waste; a new committer changes the §1.3b answer.)
- How much ceremony will this team realistically sustain? (A gate people disable is worse
  than no gate.)
- Anything the evaluation left ambiguous — a convention you *inferred*, a doc-vs-code
  contradiction you can't adjudicate. Ask rather than guess: a wrong line baked into
  `CLAUDE.md` does more damage than a question asked twice, because the agent follows it
  with confidence. (Once the wiki exists, a contradiction that *stays* unadjudicated gets a
  standing home — the conflicts register, `llm-wiki-kickoff.md` §2.10 — surfaced, not
  silently resolved, until someone rules on it.)

Ask in **one batch**, not a drip (same rule as the kickoff intake).

### 0c. Propose — a written plan the user approves before anything changes

Write the proposal: the gap list; what you'd add or change, **in what order and why**;
what you'd explicitly *not* do (the existing verifiers that stay, the kit pieces this
project doesn't need); and the risk each change carries to current behavior. Have it
adversarially reviewed (Principle 6), then put it to the user. In an existing project the
proposal *is* this step's product — the edits are what happens after a yes. (This is the
interview → written-spec → execute shape Anthropic's own best-practices guidance
recommends for feature work, applied to the harness itself.)

## 1. The floor — first edit, same as greenfield (kickoff §1.3, Part 0)

The per-repo floor is not gap-driven; it is unconditional and identical to greenfield:
committed `.claude/settings.json` with secret-read denies, enforcement-file denies, the
`ask` gate on push/merge, the Stop hook — on top of the Part 0 machine floor. Two
adoption-specific additions:

- **A tracked secret is a live incident, not a checklist item.** If step 0 found one:
  gitignore it, `git rm --cached`, **rotate the credential** (history still holds it — a
  purge is a separate, risky operation; see the kickoff's §1.3 note on why an in-tree
  `.git` copy can silently undo one), and add the audit's tracked-secret FAIL so it can't
  recur. Do this before any other adoption work.
- **Don't break the team's flow.** If other committers exist (intake Q6), the floor's
  `ask`/deny additions land as a PR with one-line rationales, not a silent settings change
  — the floor protects the repo *from the agent*; it shouldn't ambush the humans.

## 2. Pin the baseline before improving anything (Principle 10, promoted to step 2)

In greenfield, Principle 10 is an appendix concern; in adoption it is the second thing you
do. The project's current behavior is the asset. Capture it while it's still true:

- Wire the audit skeleton (`claude-audit-base.sh` → `scripts/audit.sh`, kickoff §1.6) with
  the **TOOLING section pointed at the commands the team already runs** — the audit's
  first job here is to make the existing verifiers one-command runnable, not to add new
  opinions.
- **(if non-throwaway) seed the behavioral-eval scaffold** (`claude-eval-base.sh` →
  `scripts/eval.sh`, `evals-template/` → `evals/`, kickoff §1.6b) — the judgment verifier beside
  the audit's code verifier; a golden-output case that pins a judgment the project already relies
  on, re-run at the next model upgrade to prove the retrofit didn't shift behavior.
- If there's a calculation/aggregation layer, capture a **baseline** from the current
  code as a committed test now — before any harness-motivated refactor tempts anyone.
- If there's no test the team trusts, one **critical-path test** (end-to-end through the core
  path) is worth more than any document this guide produces. Build it first.

## 3. CLAUDE.md from evidence, not aspiration (kickoff §1.5)

Write the contract from what the code and history *prove*, not what anyone wishes were
true — a plausible-but-false line is worse than no line, because the agent follows it with
confidence:

- Invariants come from step 0's "what broke repeatedly" list and the code's actual
  conventions. Every line is reconciled against the code at birth: if you can't point at
  the file that makes it true, it doesn't go in.
- If an `AGENTS.md`/`CLAUDE.md` already exists, **edit it in place** toward the kickoff
  skeleton (§1.5) — keep one physical file (symlink the other name), keep what's true,
  delete what the code contradicts, and apply the size discipline (§1.5's sourced numbers).
- The knowledge-routing block (§1.5's "Knowledge & memory") goes in verbatim — it's what
  keeps the rest of the adoption from silting into machine-local memory.

## 4. Seed the wiki from history — richest step of a retrofit (wiki guide §5)

An existing project has what greenfield lacks: **real incidents and real decisions**. The
wiki guide's build steps (§5) apply as written — inventory, boundaries, scaffold, migrate
by *moving not rewriting* (§2.3), fix references, wire the engine. The adoption-specific
gold: mine `git log`, the issue tracker, and postmortem threads for the first 3–5
**incident/decision pages** — the "we tried X, it failed because Y" record that stops the
next agent (and the next hire) from re-walking dead ends. If existing docs are good,
relocate them and add frontmatter; regenerating them is the anti-pattern.

Scale honestly (wiki guide §1): a small stable project may stop at detailed commit bodies
plus audit guards; graduate to the wiki when the project outgrows them.

## 5. Safeguard forward — adoption is a habit, not a sprint

Everything after the floor + baseline arrives **incrementally, pulled by real events**, not
as a big-bang harness sprint that halts feature work:

- Every bug fixed from now on leaves the kit's three artifacts (Principle 2's routing
  rule): a guardrail line, an audit grep, a wiki incident page. Six weeks of ordinary work
  builds more real harness than any retrofit weekend.
- The maturity triggers (kickoff §1.3a) fire on the same intake answers as greenfield:
  first real credential → the secret add-ons; a second committer → server-side branch
  protection + CODEOWNERS + audit-in-CI (§1.3b).
- Part 3 (multi-agent/autonomous work) adopts last, and only when a task genuinely fans
  out — its probe-first discipline applies unchanged.

## Order recap and Definition of Done

**Evaluate → interview → propose (approved) → floor (+ secret triage) → baseline/audit →
CLAUDE.md → wiki seed → safeguard.**

Adoption is *done enough* when: the floor is committed and **proven to bite** (kickoff
§1.4 — a denied secret read actually blocks); `bash scripts/audit.sh` runs the team's real
checks and FAILs on a tracked secret; `CLAUDE.md` exists with only evidence-backed lines
and the knowledge-routing block; the wiki holds at least three real incident/decision
pages (or the project has consciously deferred it); and the next fixed bug leaves all
three artifacts behind. Everything else is the safety net's job.

**Verify that with a verifier, not by re-reading this list.** `bash scripts/kit-conformance.sh`
(kickoff §1.6c, ROADMAP item O) is the machine check of the roster above — it **FAILs** only what
no correct adoption could omit (a `CLAUDE.md`, the `.claude/settings.json` floor file, a valid
`scripts/audit.sh`) and **WARNs** what a lean adoption may legitimately skip (wiki, evals, a named
reviewer, action-risk gates — and, concordant with the audit, a settings floor that guards writes
but not reads), so a retrofit is done-enough when it reports **zero FAIL**. On a large existing
codebase, run it as a **fan-out** — one sub-agent per area, each loading only its slice (§0a's
"fan the broad sweeps out to subagents," Part 3.13) — so no single context has to hold the whole
kit; that is the same posture as the §1.4 "prove it bites" discipline this guide opens with.

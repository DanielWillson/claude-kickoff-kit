# Harness log — the kit's own harness change journal

> **Where this lives, and why here.** This is the Claude Kickoff Kit's *own* instance of the
> harness-change-log practice it ships. The kit seeds a **blank `HARNESS_LOG.md` template** at a
> project's repo **root** (taught in `claude-project-kickoff.md` §1.6a; ROADMAP item X); that
> root name is reserved for the template, so the kit keeps its *own* filled-in journal here under
> `wiki/`, beside the rest of its self-knowledge ([[SCHEMA]], [[index]], the sources and
> decisions). Same practice, run on the kit itself — the way the kit already keeps its own
> `wiki/`. This is a **journal, not a reconcile-against-code page**: append-only,
> frontmatter-exempt, and — being kit-internal — it *may* cite maintainer docs (`ROADMAP.md`,
> `wiki/decisions/`), which the shipped root template must never do.

**What this is.** An append-only, chronological record of every change to *this repo's
harness* — the directives, verifiers, templates, settings, and rules that make up the Claude
Kickoff Kit. One entry per harness change.

**Why it exists (the meta-goal).** So we can tell, *over time*, which harness changes actually
earned their keep and which were dead weight. A harness change is a **bet**: as Anthropic's
harness team puts it, *"every component in a harness encodes an assumption about what the model
can't do on its own."* This log records the bet — what changed, what it was supposed to buy,
and what it replaced — so a later reader can *check whether it paid off* instead of assuming it
did. It is the **qualitative flight recorder** that ROADMAP item B's metrics (the quantitative
gauge) sit beside; **item X** specifies it; the **shelf-life doctrine** (README, *"What
scales with the model, and what doesn't"*) is the lens for judging durability. This is the kit
**eating its own cooking**: item X ships a `HARNESS_LOG.md` into the projects the kit sets up —
here the kit runs the practice on itself, in its own `wiki/`. (Prior harness history lives in
`ROADMAP.md` and `wiki/decisions/`; structured logging-forward starts here.)

**How to use it.**
- **Append-only.** Never rewrite a past entry to change what happened. To correct or update
  one, add a new entry — or fill in its **Retrospect** line (see below).
- **One entry per harness change**, newest first below the anchor.
- **Close the loop.** Every entry names a *signal to watch* and opens an empty **Retrospect**.
  When a change later proves itself — or doesn't — fill the Retrospect in. That backward glance
  is the whole point of the file; an unrevisited log is just a changelog.

**Entry schema** (per ROADMAP item X, in the spirit of [[SCHEMA]]):
> **date · change · rationale (the bet) · what it replaced · shelf-life/risk class ·
> related ROADMAP item · commit · signal to watch · Retrospect**

Shelf-life/risk class uses the README's durability taxonomy: **permanent** (its force comes
from a property of the world — keep forever), **depreciating** (existed because a model once
needed it — re-audit at every model upgrade), or **appreciating** (worth more as the model
improves). *(This is the kit's own, richer schema. The **shipped** root-level template carries a
deliberately leaner, project-neutral schema — date · change · rationale · what it replaced ·
risk tier · free-text **origin** — with no ROADMAP/maintainer fields, because a project has none.)*

---

## Anchor — baseline (2026-07-04)
- **Commit:** `e3233bf` — the harness state at which structured logging began.
- **Note.** Everything before this point is recorded in `ROADMAP.md` (the kit-evolution
  backlog + Fable review) and `wiki/decisions/`. This log does **not** retro-fill that history;
  it starts the append-only forward record. For a kit-derived *project*, the equivalent anchor is
  where item X's "adopted kit version/commit" gets stamped, and it is the hook item Y (living
  adoption) reads to compute the delta against a newer kit.

---

## 2026-07-04 — Name the reviewer (the human review/steer dimension)

- **Change.** Made the kit's implicit "a human reviews the agent's work" assumption **explicit**
  (ROADMAP item **V**). Three touches, all in `claude-project-kickoff.md`: a greppable **`## Review`
  block** seeded inside the §1.5 `CLAUDE.md` skeleton (solo one-liner default `reviewer = me; I
  verify against scripts/audit.sh + the spec, in small batches`, with `<who reviews>` /
  `<source(s) of truth — audit / spec / wiki, never "looks right">` placeholders, and a note that a
  team's role-specific enablement lives in the project's docs, **not** the kit); a **teaching
  paragraph** after the §1.5 lean-budget rule naming *why* to name the reviewer and the four
  capacities the harness assumes (write a clear spec, define "done," verify against a named source
  of truth, work in small batches); and one **Quick-Checklist** line. Intake (§1.0a) deliberately
  **not** touched.
- **Rationale (the bet).** The kit leans everywhere on *"verification, not generation, is the
  scarce resource"* but never named *who* verifies or *against what* — leaving the review-capacity
  bottleneck implicit. Seeding a **stable `## Review` anchor** into every generated `CLAUDE.md`
  makes it concrete and gives item **O**'s future conformance check something to grep. The bet: one
  always-loaded line naming reviewer + source of truth + small-batch discipline turns "a human
  steers" from a slogan into a checkable contract, at negligible budget cost.
- **What it replaced.** Net-new; nothing removed. It is the *actionable counterpart* to claims the
  kit already makes — **Principle 4** ("small commits are the review surface"), **§1.6a**'s Rule of
  Five (review rounds per feature), and the README's METR "verification is the bottleneck" citation
  + "steer = review in small batches" line — which the addition **references rather than restates**.
- **Shelf-life/risk class.** **Permanent** — its force comes from a property of the world (human
  review bandwidth doesn't scale with the model; a self-report is a claim from any model), the same
  basis under which the README files commit-granularity and independent-verification as *keep
  forever*. Zero blast-radius: documentation only, a template with placeholders — never a filled-in
  instance.
- **Related ROADMAP item.** **V** (name the reviewer). Feeds **O** (the conformance script greps the
  *project's* `CLAUDE.md` for a named reviewer — this seed is the anchor that check looks for); the
  higher-value of the two cross-check newcomers alongside **R** (action-risk tiers).
- **Commit.** `7032a86` (the three-touch change) + this log entry.
- **Design choices worth pointing at.**
  - The `## Review` heading is **greppable and lives *inside* the §1.5 fence** — that is the whole
    seed mechanism: it must be copied into the project's real `CLAUDE.md` for item O to find it.
    `grep -n "^## Review" claude-project-kickoff.md` returns exactly one line (the seed); item O
    separately greps the *generated* project `CLAUDE.md` — two files, two greps, two purposes.
  - **Intake omitted on the merits, not to dodge the "nine questions" ripple.** §1.0a questions earn
    their slot by driving settings / multiple setup steps (Stack → gitignore/allowlist/audit; Q6 →
    §1.3b hook + CI); reviewer identity drives none — its durable home is the always-loaded `##
    Review` block, which already defaults to solo. A fourth intake touch is unearned weight against
    "complexity is earned"; extending Q6 (a *commit-access / security* question) would also risk
    conflating commit access with review capacity (orthogonal). So neither "nine"-reference
    (`SKILL.md:30`, kickoff §1.0a) changed.
  - **Placeholder discipline:** the one-liner is the shown *default*; the angle-bracket tokens keep
    the block a template, not a filled-in instance (the kit's forbidden-list rule about starter
    templates).
- **Signal to watch.** When item **O** ships: does the `^## Review` seed reliably survive into
  generated `CLAUDE.md` files, giving O's grep a stable anchor? Do real projects fill the line with
  a *named source of truth* (audit / spec / wiki), or does it decay into "looks right" HR-speak —
  the exact failure mode this addition was built to prevent? If the latter, the durable fix is a
  sharper conformance check on the *content* of the line, not more prose.
- **Retrospect.** *(open — revisit when item O's conformance check lands.)*

---

## 2026-07-04 — Harness scorecard on the safety net (+ this journal's relocation)

- **Change.** Built the harness scorecard (ROADMAP item **B**) and its change-log companion
  (item **X**): a stack-agnostic `scripts/harness-metrics.sh` (a snapshot of cheap numbers plus
  an append-only trend log) and a blank root-level `HARNESS_LOG.md` **template**, both seeded into
  a project via a new `claude-project-kickoff.md` **§1.6a** and a Quick-Checklist line. As part of
  the same change, the kit's *own* filled-in journal — which had briefly lived at the repo root —
  moved **here to `wiki/harness-log.md`**, freeing the root name to be an unmistakable template.
- **Rationale (the bet).** The kit measures the *field* (README citations) but never *its own*
  machine; a cheap, run-it-monthly scorecard lets a project *prove* the safety net pays off instead
  of assuming it. The root file had to become a clean template (the kit-vs-repo rule): a filled-in
  `HARNESS_LOG.md` at the root was the **lone** kit template carrying real data — every other
  (`claude-audit-base.sh`, `claude-eval-base.sh`, `evals-template/`, the PRD/README templates)
  ships blank, the kit dogfooding through `wiki/` instead. Relocating the kit's instance under
  `wiki/` removes that outlier and matches item X's own words ("the kit already keeps this journal
  for itself (`wiki/decisions/`)").
- **What it replaced.** The root `HARNESS_LOG.md` filled-in instance (commit `18a50fd`) — its
  content is preserved verbatim below (the anchor + the evals-scaffold entry), now living here.
  Otherwise net-new: the metrics script and the root template are additive.
- **Shelf-life/risk class.** **Appreciating** — the safety net and its instrumentation are worth
  *more* as the model improves (the README files the safety net under *appreciating*). Low
  blast-radius: the script is a report (exit 0 always), degrades gracefully on absent inputs, and
  **never** writes this journal or the shipped `HARNESS_LOG.md`.
- **Related ROADMAP item.** **B** (harness scorecard) + **X** (harness change log). Becomes a
  conformance-checked artifact for **O**, and the anchor's version stamp is what **Y** (living
  adoption) reads.
- **Commit.** `238eefe` (feature + sweep) + this log entry.
- **Code worth pointing at.**
  - `scripts/harness-metrics.sh` — computes only the two repo-derivable numbers (`CLAUDE.md`
    `wc -l`; audit-check count by grepping the `pass`/`warn`/`fail` calls in `scripts/audit.sh`)
    and **stubs the human counts** (review rounds per feature — the Rule of Five, `LESSONS.md`;
    defects caught by humans; escaped defects; rollbacks; effort per merged change) as explicit
    "human note required" fields — never a fabricated zero. The `delta()` guard
    (`10#$cur - 10#$prev`, and both readings must match `^[0-9]+$`) is what makes the trend
    read-back "never crash on a malformed line." Trend-log path is the `HARNESS_METRICS_LOG` env
    var (default in-repo; point at `$TMPDIR` to test). It ships pre-placed in `scripts/` so `ROOT`
    resolves to the repo root and it runs in place — which is also its own graceful-degradation
    test (the kit repo has no `CLAUDE.md` / `scripts/audit.sh`, so both metrics skip cleanly).
  - `HARNESS_LOG.md` (root) — the shipped **template**: placeholder tokens (`<kit-version>` /
    `<commit-sha>` / `<YYYY-MM-DD>`, never a real SHA), a leaner **project-neutral** schema
    (free-text **origin**, *not* a "ROADMAP item" field), and a note forbidding kit-internal
    citations — the constraints that keep it unmistakably a template, not a filled-in instance.
- **Signal to watch.** Did the two free numbers alone prove useful, or did they beg for a manual
  metric (which then needs an honest source, not a fake zero)? Did the graceful degradation hold
  in a real fresh repo? Did adopting projects actually seed *and look at* the scorecard monthly,
  or did the trend log rot unread? If nobody reads it, the durable fix is **fewer** numbers, not
  more (the §1.6a caveat: a few looked at beat forty ignored).
- **Retrospect.** *(open — revisit at the next maintenance moment.)*

---

## 2026-07-04 — Behavioral-evals scaffold (the judgment verifier)

- **Change.** Added a second verifier beside the code-health audit: **behavioral evals** — saved
  tests for the agent's *judgment* rather than its code. Ships as `claude-eval-base.sh` (the
  runner → a project's `scripts/eval.sh`) and `evals-template/` (the seed suite → a project's
  `evals/`), taught in `claude-project-kickoff.md` **§1.6b**, guarded and presence-checked in
  `claude-audit-base.sh`, with consistency mentions in `README.md`, `SKILL.md`, and
  `claude-project-adoption.md`.
- **Rationale (the bet).** A passing test suite proves the *code* still works; nothing proved
  the *agent's judgment* still holds after a model upgrade, a big `CLAUDE.md` edit, or a new
  skill. Evals close that gap — *eval-driven development is to agents what TDD was to code*. The
  README already promised this mechanism (behavioral evals filed under *appreciating*; a model
  upgrade as a *scheduled maintenance event*); this delivers it. **The bet:** a few saved
  judgment cases, re-run at each maintenance moment, catch a silent regression that green tests
  miss — cheaply, because the preferred **golden-output** grade is deterministic string equality
  that needs no live model to score.
- **What it replaced.** Net-new capability — nothing removed. It *complements* the audit
  (`§1.6`): the audit is the after-every-edit code verifier, evals the at-a-model-change judgment
  verifier. It also makes concrete the "behaviour evals" Part 3.7 only gestured at (the per-run
  DoD version), now cross-linked to §1.6b as a distinct standing artifact.
- **Shelf-life/risk class.** **Appreciating** — per the README, a suite of behavioral evals is
  worth *more* as the model improves (it turns each upgrade into a checkable maintenance event).
  Low blast-radius: the audit expectation is an unconditional WARN that never runs the evals, so
  it costs a throwaway nothing.
- **Related ROADMAP item.** **A** (behavioral evals). Touches **X** (this is the log's first
  real entry), will be a checked artifact for **O** (conformance script), and is the cousin of
  **I** (baseline for non-deterministic output).
- **Commit.** `753e989` (feature) + this log entry.
- **Code worth pointing at.**
  - `claude-eval-base.sh` — the runner. The two grade types live in the `case "$grade"` block:
    the `golden` arm is a plain `[ "$candidate" = "$expected" ]` (deterministic, no live model
    to grade); the `rubric` arm shells a *fresh* judge (the builder/judge split). The model command
    is overridable (`EVAL_CMD` / `EVAL_JUDGE_CMD` / `EVAL_DIR`) — the seam that lets the golden
    path be proven PASS/FAIL with a stub and no live model, which is how it was verified.
  - `claude-audit-base.sh` — the `tracked_kit` guard now catches the eval sources via **two
    structurally different mechanisms**: a stem appended to the basename alternation (for the
    distinctively-named `claude-eval-base.sh`) *and* a `(^|/)evals-template/` **path-segment**
    clause (for its non-distinctly-named contents — a stem match there would false-flag every
    project's own `README.md`). The new `BEHAVIORAL EVALS` section is a presence/wiring **WARN
    only** — it must never execute the evals.
  - `claude-project-kickoff.md` **§1.6b** — the teaching: the provenance rule quoted verbatim
    (*"a naked factual claim is a defect — it must cite its source"*) and the honest LLM-judge
    caveat (bias, ~6pp infra swings, models detect evaluation → prefer golden, keep rubrics
    blunt, smoke alarm not lab scale).
- **Signal to watch.** At the next model upgrade / big `CLAUDE.md` edit: did a golden eval ever
  catch a real judgment regression a green build missed? How often did rubric noise cause a
  false alarm? Did adopted projects actually seed a suite, or did `evals/` stay empty? If
  rubrics prove net-noisy, the durable fix is to lean harder on golden-only and demote rubrics —
  not to add judge machinery.
- **Retrospect.** *(open — revisit at the next maintenance moment.)*

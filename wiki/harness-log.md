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
harness* — the guides, sensors, templates, settings, and rules that make up the Claude
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

Shelf-life/risk class uses the README's durability taxonomy: **invariant** (its force comes
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

## 2026-07-04 — ROI instrumentation on the ratchet (+ this journal's relocation)

- **Change.** Built the harness ROI gauge (ROADMAP item **B**) and its change-log companion
  (item **X**): a stack-agnostic `scripts/harness-metrics.sh` (a snapshot of cheap numbers plus
  an append-only trend log) and a blank root-level `HARNESS_LOG.md` **template**, both seeded into
  a project via a new `claude-project-kickoff.md` **§1.6a** and a Quick-Checklist line. As part of
  the same change, the kit's *own* filled-in journal — which had briefly lived at the repo root —
  moved **here to `wiki/harness-log.md`**, freeing the root name to be an unmistakable template.
- **Rationale (the bet).** The kit measures the *field* (README citations) but never *its own*
  machine; a cheap, run-it-monthly scorecard lets a project *prove* the ratchet pays off instead
  of assuming it. The root file had to become a clean template (the kit-vs-repo rule): a filled-in
  `HARNESS_LOG.md` at the root was the **lone** kit template carrying real data — every other
  (`claude-audit-base.sh`, `claude-eval-base.sh`, `evals-template/`, the PRD/README templates)
  ships blank, the kit dogfooding through `wiki/` instead. Relocating the kit's instance under
  `wiki/` removes that outlier and matches item X's own words ("the kit already keeps this journal
  for itself (`wiki/decisions/`)").
- **What it replaced.** The root `HARNESS_LOG.md` filled-in instance (commit `18a50fd`) — its
  content is preserved verbatim below (the anchor + the evals-scaffold entry), now living here.
  Otherwise net-new: the metrics script and the root template are additive.
- **Shelf-life/risk class.** **Appreciating** — the ratchet and its instrumentation are worth
  *more* as the model improves (the README files the ratchet under *appreciating*). Low
  blast-radius: the script is a report (exit 0 always), degrades gracefully on absent inputs, and
  **never** writes this journal or the shipped `HARNESS_LOG.md`.
- **Related ROADMAP item.** **B** (ROI instrumentation) + **X** (harness change log). Becomes a
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

## 2026-07-04 — Behavioral-evals scaffold (the judgment sensor)

- **Change.** Added a second sensor beside the code-health audit: **behavioral evals** — saved
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
  (`§1.6`): the audit is the after-every-edit code sensor, evals the at-a-model-change judgment
  sensor. It also makes concrete the "behaviour evals" Part 3.7 only gestured at (the per-run
  DoD version), now cross-linked to §1.6b as a distinct standing artifact.
- **Shelf-life/risk class.** **Appreciating** — per the README, a suite of behavioral evals is
  worth *more* as the model improves (it turns each upgrade into a checkable maintenance event).
  Low blast-radius: the audit expectation is an unconditional WARN that never runs the evals, so
  it costs a throwaway nothing.
- **Related ROADMAP item.** **A** (behavioral evals). Touches **X** (this is the log's first
  real entry), will be a checked artifact for **O** (conformance script), and is the cousin of
  **I** (golden-oracle for non-deterministic output).
- **Commit.** `753e989` (feature) + this log entry.
- **Code worth pointing at.**
  - `claude-eval-base.sh` — the runner. The two grade types live in the `case "$grade"` block:
    the `golden` arm is a plain `[ "$candidate" = "$expected" ]` (deterministic, no live model
    to grade); the `rubric` arm shells a *fresh* judge (the doer/judge split). The model command
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

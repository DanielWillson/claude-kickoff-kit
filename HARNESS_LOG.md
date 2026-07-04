# HARNESS_LOG.md — the kit's own harness change log

**What this is.** An append-only, chronological record of every change to *this repo's
harness* — the guides, sensors, templates, settings, and rules that make up the Claude
Kickoff Kit. One entry per harness change.

**Why it exists (the meta-goal).** So we can tell, *over time*, which harness changes actually
earned their keep and which were dead weight. A harness change is a **bet**: as Anthropic's
harness team puts it, *"every component in a harness encodes an assumption about what the model
can't do on its own."* This log records the bet — what changed, what it was supposed to buy,
and what it replaced — so a later reader can *check whether it paid off* instead of assuming it
did. It is the **qualitative flight recorder** that ROADMAP item B's metrics (the quantitative
gauge) will sit beside; **item X** specifies it; the **shelf-life doctrine** (README, *"What
scales with the model, and what doesn't"*) is the lens for judging durability. This is the kit
**eating its own cooking**: item X ships a `HARNESS_LOG.md` into the projects the kit sets up —
here the kit runs the practice on itself, the same way it keeps its own `wiki/`. (Prior harness
history lives in `ROADMAP.md` and `wiki/decisions/`; structured logging-forward starts here.)

**How to use it.**
- **Append-only.** Never rewrite a past entry to change what happened. To correct or update
  one, add a new entry — or fill in its **Retrospect** line (see below).
- **One entry per harness change**, newest first below the anchor.
- **Close the loop.** Every entry names a *signal to watch* and opens an empty **Retrospect**.
  When a change later proves itself — or doesn't — fill the Retrospect in. That backward glance
  is the whole point of the file; an unrevisited log is just a changelog.

**Entry schema** (per ROADMAP item X, in the spirit of `wiki/SCHEMA.md`):
> **date · change · rationale (the bet) · what it replaced · shelf-life/risk class ·
> related ROADMAP item · commit · signal to watch · Retrospect**

Shelf-life/risk class uses the README's durability taxonomy: **invariant** (its force comes
from a property of the world — keep forever), **depreciating** (existed because a model once
needed it — re-audit at every model upgrade), or **appreciating** (worth more as the model
improves).

---

## Anchor — baseline (2026-07-04)
- **Commit:** `e3233bf` — the harness state at which structured logging began.
- **Note.** Everything before this point is recorded in `ROADMAP.md` (the kit-evolution
  backlog + Fable review) and `wiki/decisions/`. This log does **not** retro-fill that history;
  it starts the append-only forward record. For a kit-derived *project*, this anchor is where
  item X's "adopted kit version/commit" gets stamped, and it is the hook item Y (living
  adoption) reads to compute the delta against a newer kit.

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

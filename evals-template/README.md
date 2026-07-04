# Behavioral evals — saved tests for the agent's *judgment*

This directory is a **behavioral eval suite**: the agent-behavior analogue of a test suite.
A normal test checks the *code*; an eval checks the *agent's judgment* — "asked to do X, does
it do the right thing?" *Eval-driven development is to agents what TDD was to code.*

> **This is a starter scaffold copied from the Kickoff Kit's `evals-template/` — it ships
> mostly empty on purpose.** Two example fixtures show the format; grow the suite to roughly
> **8–15 representative cases** over time — add one whenever a judgment matters. A throwaway
> project needs none of this; a project you'll maintain seeds a few now. (See kickoff §1.6b.)

## When to run

At a **maintenance moment** — a **model upgrade**, a **big `CLAUDE.md` edit**, or a **new
skill** — to prove the change *helped* rather than quietly regressed the agent's judgment.
Not on every edit: evals cost tokens and shell out to a live model. The audit
(`scripts/audit.sh`) is the after-every-edit verifier; this is the at-a-model-change verifier.

Run: `bash scripts/eval.sh`  (exit 0 = every eval passed).

## The two grade types

- **golden-output (preferred).** The answer must **equal** a saved value. Exact, cheap,
  **deterministic** — and the grade needs **no live model**: the model only *generates* the
  candidate, the runner compares strings. Prefer this wherever the correct answer is a fixed
  value (a path, an id, a normalized string, an exact number).
- **rubric / LLM-judge.** A fresh agent grades the answer against a short checklist. For
  **fuzzy output only** (prose, a plan, a judgment call with no single right string).

## The honest caveat — read before trusting a rubric result

LLM-as-judge is **noisy**: documented bias, roughly **6-percentage-point swings from the
evaluation infrastructure alone**, and models can detect they are being evaluated. So
**prefer golden-outputs, keep rubrics blunt, and treat this suite as a smoke alarm, not a lab
scale.** A red result means "look here," not "regression proven to three decimals."

## Fixture format (`*.eval.md`)

Each eval is one Markdown file, parsed with `grep` + `sed` only (no `jq`/`python3`, so the
runner stays stack-agnostic). A small frontmatter block carries the scalars; `## H2` sections
carry the multi-line fields:

```
---
grade: golden              # golden | rubric
approval_class: read-only  # read-only | local-write | external
---

## input
<the task prompt fed to the agent under test, verbatim>

## expected
<golden only — the exact string the answer must equal>

## rubric
<rubric only — a short, blunt PASS/FAIL checklist for the judge>

## required_sources
<citations/provenance the answer must carry — see "schema fields" below>

## forbidden_actions
<actions the answer must never take — see "schema fields" below>
```

An inline `# …` after a frontmatter scalar is treated as a comment and ignored by the runner
(so the value legend above is safe to keep in a real fixture).

**The full fixture schema** (from ROADMAP item A) is:
**input · expected output · required sources/citations · forbidden actions · approval class.**

**What the runner mechanically checks vs. what a human reads.** Be honest about the line:
- **`input` + `expected`** (golden) and **`input` + `rubric`** (rubric) are *enforced* — the
  runner grades them every run.
- **`required_sources`, `forbidden_actions`, `approval_class`** are **schema fields the
  project grows into.** The base runner **does not** mechanically enforce them — they are
  carried on every fixture and read by a human until you wire a check that needs one. This is
  where the **provenance rule** lives: *a naked factual claim is a defect — it must cite its
  source* — the knowledge-work analogue of "tests passed." Record it as a `required_sources`
  entry now; enforce it mechanically when the project is ready.

**Format constraint (parser limit).** No line inside a `## section` body may itself begin
with `## ` — the `sed`-based extractor ends a section at the next `## `, so a stray `## `
would truncate the body. Use a different heading depth or phrasing inside a body.

## The runner (`scripts/eval.sh`)

A stack-agnostic bash template (copied from the kit's `claude-eval-base.sh`). It parses each
fixture, generates a candidate answer, grades it, and prints per-eval PASS/FAIL, a tally, and
an exit code. The model command is **overridable** so a self-test can **stub** it — which is
how the golden path is proven PASS/FAIL on demand with no live model:
- `EVAL_CMD` — the agent under test (default `claude -p`), fed the task on stdin.
- `EVAL_JUDGE_CMD` — the rubric judge, a *fresh* invocation (builder/judge split, kickoff Part
  3.8; default `claude -p`).
- `EVAL_DIR` — where the fixtures live (default `<repo>/evals`).

The `claude -p` default is the kit's first headless-Claude call — **verify it against your
installed Claude Code version** before trusting it (Principle 8). The stub proves the grading
harness; only a real run proves the invocation.

## The two examples here

- **`cite-changed-file.eval.md`** — *golden.* Shown a diff, does the agent name the exact
  file it changed? Provenance at its simplest, graded by string equality.
- **`scope-check.eval.md`** — *rubric.* Asked for a one-line fix with a tempting out-of-scope
  addition nearby, does the agent stay in scope (and flag, not silently bundle, the extra)?

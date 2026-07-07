# Kit Roadmap — Fable Review (2026-07-03)

**What this is.** A durable capture of a Fable-driven review of the Claude Harness Kit —
gaps, proposed additions, where harness engineering is going, the skeptic evidence, sources
to add, and a build order. Provenance: a close read of the whole kit plus a ~30-agent
research sweep, then a cross-check against a competing AI's independent answer to the same
prompt (folded in 2026-07-03). Sources self-flagged primary-vs-vendor and verbatim-vs-paraphrase.
**Before any citation here ships into a kit doc, fetch each URL to confirm it resolves and the
date/author are right — this repo can't cite on trust (Lesson 7).** Maintainer doc for the kit
repo itself; not handed to projects.

**Design constraint — keep the kit project-agnostic (2026-07-03 steer).** The kit must work for
a solo hobby project, an open-source library, a research repo, or a business tool — and must
**never assume a business, customers, or a team**. Several items below were surfaced by a
cross-check aimed at one specific company; they are generalized here to project-neutral terms:
*reversibility and blast-radius* instead of "customer-facing," *non-git state* instead of any
named SaaS/no-code tool, and *"whoever reviews the agent"* instead of job roles. Scale every item
honestly — a solo project may need a one-line version of what a team needs as a full artifact.
The role-specific or business-specific version of any idea belongs in a *project's own* docs,
never in the kit.

---

## 1. Quick categorized recommendation list

Two axes: **Impact** × **Type** — *Frontier/Unique* (novel, ahead of the field, distinctively
ours) vs *Hygiene/Catch-up* (the field already knows this; do it because it's load-bearing).

| # | Recommendation | Impact | Type |
|---|---|---|---|
| **O** | Self-verifying **adoption check + fan-out verifier** | **Highest** | Frontier/Unique · ✅ **Built (2026-07-06)** |
| **A** | **Behavioral evals** as a first-class `evals/` artifact (incl. non-code workflows) | **Highest** | Frontier/Unique |
| **B** | **Harness scorecard** (generalize the wiki `metrics` shape) | **High** | Frontier/Unique |
| **R** | **Action-risk tiers** — gate agent actions by reversibility × reach | **High** | Frontier/Unique · *new* |
| **V** | **Name the reviewer** — make the human review/steer dimension explicit | **High** | Frontier/Unique · *new* |
| **G** | **Dependency-vulnerability scan** + stronger secret scan in `audit.sh` | **High** | Hygiene |
| **C** | **Flight recorder** → feed the safety net from bad transcripts | Med–High | Frontier-ish |
| **S** | **Rollback/recovery for non-git state** (DB, hosted config, deploy, external backend) | Med–High | Hygiene · *new* |
| **E** | **Spec-as-source** (living spec) | Medium | Frontier |
| **D** | **Cross-project memory** (→ queryable knowledge service) | Medium | Frontier/Unique |
| **T** | **Tool inventory** | Medium | Hygiene · *new* |
| **U** | **Incident runbook** for agent mistakes (forward, not retrospective) | Medium | Hygiene/Frontier · *new* |
| **W** | **Harness manifest** (owner/version/last-verified/risk/sunset) | Medium | Hygiene · *new* |
| **X** | **Harness change log** (`HARNESS_LOG.md`) + vetted **cross-repo learning** | Med–High | Frontier/Unique · *new* |
| **Y** | **Kit-update proposals** — skill re-reviews repo & proposes upgrades as the kit evolves | Medium | Frontier · ✅ **Built (2026-07-06)** |
| **H** | **Safeguard-rot check** — safeguards assert their own anchor | Medium | Hygiene |
| **J** | **Re-verify the harness after a Claude Code upgrade** | Medium | Hygiene |
| **I** | **Baseline for fuzzy output** (tolerance/rubric) | Lower | Frontier (cousin of A) |
| **K–N** | **4 internal-consistency fixes** | Lower | Hygiene |
| **F** | **Untrusted-content rule** (name the untrusted-content surface) | Lower | Hygiene |
| **P** | **README additions** — eval-driven line, Axis 1/2 quotes, citation block | ✅ **Done (2026-07-03)** | Documentation |
| **Q** | **Fowler → Böckeler citation fix** | ✅ **Done (README 2026-07-03; rest of kit 2026-07-06)** | Hygiene |

**If you do only three: O, A, B.** Add **G** if security is near-term. The two highest-value
*newcomers* from the cross-check are **R** (action-risk tiers) and **V** (name the reviewer) —
both fill genuine holes. **O** remains the item that makes all the others actually stick.

**⚠️ 2026-07-06 defect sweep.** A 7-agent Sonnet-5-max multi-lens review (full write-ups in
[`fable-analysis-7-6-26/`](fable-analysis-7-6-26/00-synthesis.md)) reproduced concrete bugs in four
already-"Built" items — **A**, **B**, **O**, **R** — plus gaps in the security templates (Part 0)
and the **X**/`prompts/` hygiene layer. None of the underlying *designs* are wrong; each is a
fixable implementation defect, caught by doing to the kit's own scripts exactly what they preach
("prove it bites, don't trust a self-report") — the review is a live instance of Lesson 2, aimed at
this repo. Full list, evidence, and repro steps: **§9**.

---

## 2. The "kit vs repo" rule (frames everything below)

The kit is scaffolding used once and never copied into a project. Each new practice lands in
**two places**: (1) *in the kit* — the teaching + a starter template/script + a checklist line;
(2) *in the repo it sets up* — the living instance (the real `evals/` folder, the real numbers,
the real manifest). The kit seeds it; the project owns it.

---

## 3. Recommendations in detail

### A. Behavioral evals as a first-class artifact
A normal test checks your *code*; an **eval** checks the *agent's judgment* ("when asked to do X,
does it do the right thing?"). Keep a permanent `evals/` folder of representative tasks, each with
a way to grade it; re-run whenever something could shift agent behavior. *Eval-driven development
is to agents what TDD was to code.*
- **Build:** `evals/` with 8–15 cases. Two grade types: **golden-output** (must equal a saved
  value — exact, cheap, preferred) and **rubric/LLM-judge** (a fresh agent grades against a
  checklist — for fuzzy output). Runner `scripts/eval.sh` (headless) records pass/fail. Run at
  model upgrade / big CLAUDE.md edit / new skill.
- **Extend beyond code:** evals apply to *any* checkable output or workflow, not just code. Use a
  fixture schema borrowed from the cross-check: **input · expected output · required sources/
  citations · forbidden actions · approval class.**
- **Provenance rule:** for any output that makes a factual claim, *a naked factual claim is a
  defect* — it must cite its source. This is the knowledge-work analogue of "tests passed."
- **Caveat:** LLM-as-judge is noisy (bias; ~6pp infra swings; models can detect they're tested).
  Smoke alarm, not precision scale. Prefer golden-outputs.
- **Known defect (found 2026-07-06, §9):** the golden-output FAIL path in `claude-eval-base.sh`
  crashes the whole runner instead of reporting FAIL (a UTF-8 byte in the error message corrupts a
  bash variable name under `set -u`) — reproduced on stock macOS bash and Homebrew bash. The rubric
  judge's verdict-extraction (`grep` over the judge's full output, not just its first line) can also
  flip a correct verdict either direction. Both are implementation bugs, not design flaws — see **§9**.

### B. Harness scorecard
A scorecard that proves the safety net is paying off instead of assuming it. The kit measures the
*field* but never *your own* machine.
- **Build:** `scripts/harness-metrics.sh`, monthly, logged for trend: audit-check count over
  time; how often each safeguard fired; review rounds per feature (Rule of Five); % agent changes
  merged without rework; **defects caught by tests vs. by humans; escaped defects; rollbacks
  needed;** tokens/$ per merged change; CLAUDE.md line-count trend.
- **Why it matters:** rich harnesses can be much more expensive — Anthropic's long-running-app
  harness ran **>20× the cost** of the simple run (verified). Track whether the spend pays.
- **Shortcut:** the wiki already has a `metrics` subcommand — copy that shape, point it at the
  harness. Kit teaches + ships the script; repo holds the numbers.
- **Companion — the harness change-log (`HARNESS_LOG.md`, item X):** ship a qualitative log next to
  the numbers — *what* changed and *why*. B is the gauge; the log is the flight recorder. Seed the
  basic version with B; the schema + cross-repo layer is item X.
- **Known defect (found 2026-07-06, §9):** the audit-check count `scripts/harness-metrics.sh`
  computes is inflated by commented-out example code in `claude-audit-base.sh` (measured 24% on the
  kit's own reference template) and the script never counts eval-fixtures despite its sibling
  script already knowing how — see **§9**.

### C. Flight recorder → feed the safety net
A flight recorder for agent runs, so you can see *why* one went wrong or expensive.
- **Build:** app logs to a file the agent can read; keep transcripts. When a run goes bad,
  post-mortem the transcript → "what directive/check would've stopped this?" → a safety-net artifact.
  Adds a second feed to the safety net (today it's fed only by code bugs). Graduation (if outgrown):
  Langfuse/LangSmith/OTel GenAI traces.

### D. Cross-project memory
Markdown works for one project; across many, or for cross-project knowledge, plain files stop
scaling (can't query them — Yegge's "605 rotting plan files").
- **In the kit:** a maturity trigger ("when project-local markdown stops scaling → graduate to a
  *queryable knowledge service* that keeps the reconcile-against-truth property"), plus the
  pattern: a small database or an MCP server over the knowledge base (with trust banners /
  last-verified). Least-solved gap in the field — stay humble: name the trigger, point at the
  pattern, don't over-promise. (Keep the example project-neutral; don't name a specific product.)

### E. Spec-as-source
Make the spec a *living* file like the wiki, not a fill-in-once doc.
- **Build (few lines):** add a "reconcile against code" freshness anchor to the spec template;
  add a safety-net line ("when behavior changes on purpose, update the spec in the same commit");
  point CLAUDE.md's knowledge-routing at the spec as the home of *intent*.

### F. Untrusted-content rule
Architecture already handles it (contain, not detect). Add one line to §1.3a naming the untrusted-
content surface generically: **fetched web pages, PDFs, CSVs, emails, screenshots, transcripts,
and any tool/MCP output are data, not instruction** — the sandbox limits *damage*, not the
*hijack*. No build.

### G. Dependency-vulnerability scan (new in prior pass)
Kit checks secrets + unpinned versions, but nothing checks whether a dep you *already use* has a
*published* security hole.
- **Build:** add a step to `audit.sh` running the ecosystem scanner (`npm audit`, `pip-audit`,
  `cargo audit`…), fail on high-severity; strengthen the secret scanner to catch high-entropy
  strings, not just `key=`-shaped ones. Matters because AI writes insecure code at a flat ~45%
  rate (Veracode) — the harness must catch it.

### H. Safeguard-rot check
Safeguards are `grep`s. After a rename, a grep can *silently stop matching* — it stops
protecting but doesn't complain (false security).
- **Build:** each safeguard also asserts its target still exists (fail loudly if the anchor is gone);
  or a periodic coverage check flags safeguards whose target vanished — mirror the wiki's
  `stale`/`coverage` check, pointed at the audit script.
- **Built 2026-07-04:** a `guarded "<what>" "<anchor-file>" "<symbol|''>" && { … }` helper in
  `claude-audit-base.sh` that confirms the anchor resolves before the real check runs — anchor gone →
  **WARN loudly and skip the body**, so a lost anchor never reads as `pass`; plus a **`SAFEGUARD
  SELF-CHECK`** section ("audit the audit") that rolls up the anchored guards exercised this run and
  names the rotted ones (registry-based, so it can't false-positive a live guard — mirrors the wiki's
  `stale`/`coverage`). The rot-prone template guards (INVARIANTS #1/#3, the regression example) were
  converted; whole-dir scanners left unwrapped. Teaching in kickoff **§1.6** + a Quick-Checklist line.
  **Structural rot only** — semantic drift (anchor present, meaning refactored away) is named as a
  human read (route to item **A**), not something the grep can prove. Proven on real fixtures (anchor
  present → runs; renamed → WARN, no pass; symbol removed → symbol-anchor WARN).

### I. Baseline for fuzzy output (cousin of A)
Principle 10's "pin exact output, reproduce exactly" fits a calculator, not fuzzy agent/text
output. **Build:** tolerance bands, sample multiple runs, or rubric-judge — same golden-vs-rubric
split (and same fixture schema) as A.

### J. Re-verify the harness after a Claude Code upgrade
You prove safeguards "bite" at setup, but nothing re-checks after the *tool* updates (which can
silently drop a setting). **Build:** add "re-run §1.4 checks after any Claude Code major upgrade"
to the checklist + doctrine. Treat a tool upgrade like a model upgrade. (See **W** — this becomes
a row in the harness manifest.)

### K–N. Internal-consistency fixes (tensions)
- **K:** "keep CLAUDE.md short" vs. the starter skeleton that's already fairly long — trim or
  acknowledge it's near budget.
- **L:** "never paste the kit in" vs. the "how we build here" block that *is* a kit digest — add
  one clarifying line (the digest is the intended exception; the kit *prose* is what you don't
  paste).
- **M:** version-specific facts ("2.1.x", red-team stats) in a durable doc — date-stamp them +
  the re-verification habit (ties to J/W).
- **N:** Principle 4 "solo-on-main is fine" vs. Part 3.11 "unattended runs always get a worktree"
  — add a cross-reference.

### O. Adoption check + fan-out verifier (the big one)
The kit is now big enough that one session reading all of it will blow its context and mark things
"done" it never did. Fix: a verifier for the kit's own adoption, built so no single agent holds the
whole kit.
- **Part 1 — conformance script** (`scripts/kit-conformance.sh`): checks for the *artifacts* the
  kit should produce — deny rules present? `audit.sh` runs? CLAUDE.md has routing block + under
  budget? `evals/` exists with ≥N cases? action-risk tiers defined (**R**)? reviewer named
  (**V**)? wiki has ≥3 incident pages? managed floor present? Verify adoption with a verifier, not a
  self-report (§1.4 applied to the whole kit).
- **Part 2 — fan-out driver:** a coordinator spins up focused sub-agents, one per area, each
  loading only its slice, each returning pass/fail against the conformance checklist; a final
  coordinator merges into one adoption scorecard. This is the kit's own Part 3 playbook turned on
  itself, and it kills the context-window worry. (This session used exactly this pattern to verify
  README citations — parallel read-only verifiers + a single writer — a working proof of concept.)
- Scale honestly: Lean tier gets just the conformance script; fan-out for bigger adoptions.
- **Built 2026-07-06:** `scripts/kit-conformance.sh` — a deterministic roster check (CLAUDE.md +
  routing/reviewer blocks · per-repo secret-read floor · a `bash -n`-valid `audit.sh` · evals ≥N ·
  ≥3 wiki incident pages · action-risk gates) with a **three-class exit model** — *FAIL only what no
  correct adoption could omit; WARN what a lean project may legitimately skip; exit nonzero only on
  FAIL* — so a code-only throwaway passes zero-FAIL (proven on a fixture matrix: floor-only → exit 0;
  each floor break → exit 1; each optional degrade → WARN/exit 0). It treats `audit.sh` as one roster
  item (present + syntax-valid, **never executed** — that is the audit's cadence) and **reuses the
  audit's own predicates** where they overlap (the `action-risk` marker-join, the `*.eval.md` count,
  the `## Review` / `## Knowledge & memory` anchors) — one vocabulary, two questions. The managed
  floor is a **loud SKIP** (a root-owned OS file, not repo-readable — `SKIPPED ≠ PASS`, per **G**).
  Part 2 is a **documented fan-out playbook** (kickoff **§1.6c**, cross-referencing Part 3.13 + the
  "don't trust a self-report" rule), not machinery — you cannot spawn sub-agents from bash; an
  optional `--area` seam was left unbuilt on the merits. Teaching in **§1.6c** + a Quick-Checklist
  line + a **Definition-of-Done upgrade** in `claude-project-adoption.md` (its DoD roster is now
  machine-checked by the script). Scope held to this section's enumeration (B/X artifacts were
  *not* added as checks). The deny-floor check is kept **concordant with the audit** (which WARNs,
  not FAILs, on the same input): a *missing* `.claude/settings.json` is FAIL, but *present-but-no-
  read-deny* is WARN — the managed floor's `Read(**/.env)` can cover a repo's secrets, so a floored
  machine may correctly omit the repo-level read-deny (FAILing it would break O's own "FAIL only what
  no correct adoption could omit" rule).
- **Known defect (found 2026-07-06, §9):** `scripts/kit-conformance.sh` never validates that
  `.claude/settings.json` is syntactically loadable JSON (a truncated file still gets a clean PASS on
  the deny-floor row, while the script *does* `bash -n` its sibling `audit.sh` three sections up —
  an inconsistency, not a scope decision), and it hardcodes `CLAUDE.md` with no `AGENTS.md` fallback
  (a legitimately-adopted AGENTS.md-only repo gets a hard FAIL). Both reproduced on fixtures — see **§9**.

---

### Cross-check additions (from the GPT comparison, generalized off business specifics)

A competing AI, answering the same prompt for a specific company, surfaced six ideas worth adopting
— generalized here per the project-agnostic constraint. It was weaker on rigor, prioritization, and
verification (it cited "Anthropic notes…" with no URLs, and — fittingly — reproduced the same
Fowler-not-Böckeler misattribution this kit just fixed), but stronger on the human/operational side
the ROADMAP had under-weighted.

### R. Action-risk tiers *(new; generalizes "customer-facing action matrix")*
Classify the actions an agent can take along two axes — **reversibility** (can it be undone?) and
**reach / blast-radius** (does it stay inside the project, or reach the outside world, other
people, money, or production state?). Gate accordingly: local + reversible → auto-run; external /
irreversible / hard-to-undo → approval gate, dry-run, or batch cap. The kit has the seed (deny/ask,
push-is-a-gate, the security pecking order); the addition is an explicit, project-neutral *taxonomy
of action classes beyond code edits* — send a message, publish content, delete/overwrite state,
spend via an API, change a record other systems depend on.
- **Agnostic examples:** an agent that can publish to a personal blog; a script that can delete
  files or spend on a paid API; a tool that writes to a shared datastore.
- **Build:** a short table in CLAUDE.md or the spec mapping action class → gate type; wire the
  highest-risk classes to deny/ask (deterministic), never prose.
- **Built 2026-07-04:** teaching in kickoff **§1.3c**; template table in the §1.5 `CLAUDE.md` skeleton +
  commented example in `templates/project.settings.json`; a Quick-Checklist line; and an `audit.sh` section —
  all joined by one greppable marker, the **`action-risk`** tag, so **O**'s "action-risk tiers defined (R)?"
  check greps that tag in `CLAUDE.md` **and** on a paired (active, non-comment) `.claude/settings.json` rule
  (tagged table but no tagged gate → WARN — prose is not a boundary).
- **Known defect (found 2026-07-06, §9):** the action-risk mechanism's prescribed inline `//`
  comment on a live `.claude/settings.json` array element (`templates/project.settings.json`'s worked
  example) is not valid JSON — confirmed via `python3 json.load` — yet `scripts/kit-conformance.sh`
  gives it a clean PASS. The kit's own dogfooded `.claude/settings.json` quietly avoids this exact
  form, so the riskier construct it prescribes to every other project has never been battle-tested
  against real usage. See **§9**.

### S. Rollback / recovery for non-git state *(new; generalizes "no-code rollback")*
Git covers code; it does not cover state your project depends on that lives elsewhere — a database,
a hosted config, an external/SaaS/no-code backend, infrastructure, a deployed release, a published
artifact. Before agent-assisted changes to any such state, require a snapshot + a documented way
back + a recovery owner (solo: you — just ensure the snapshot exists). Principle 10 already says "a
data migration is not git-reversible"; this generalizes to *all* out-of-git state and makes the
snapshot ritual explicit. Absorbs the kickoff-reader's "rollback weak for non-git things" gap.
Scale honestly: a pure library with no external state needs none of this.

### T. Tool inventory *(new; generalizes "connector/MCP inventory")*
Any project where the agent has tools — MCP servers, connectors, plugins, browser extensions, API
integrations — should keep a small inventory: per integration, its owner, scopes/permissions, what
data it can read, whether it can write, where its credential lives, last review date, and how to
disable it. The security docs cover credential *layering* and rotation but no artifact inventories
the *fleet of tools* a given project runs. As the tool surface grows, this is where you look when
something has too much access or needs killing. Scale honestly: one MCP server → one line.

### U. Incident runbook for agent mistakes *(new)*
Distinct from the wiki's *retrospective* incident pages (symptom → cause → fix, written after).
This is the *forward* procedure you run the moment an agent does something wrong in a live system:
contain it → revoke/rotate any credential involved → identify what was touched (files, records,
messages, external state) → undo or notify → then safeguard (add a regression check + a wiki incident
page). The kit is strong on *prevention*; this is the "when prevention fails" playbook. Agnostic:
the live system could be a personal server, an open-source project's CI, or a business's backend.
- **Build:** a short RUNBOOK section (or wiki page) with the ordered steps, kept where a stressed
  human can find it fast.

### V. Name the reviewer — the human dimension *(new; the ROADMAP's own blind spot)*
The whole kit assumes a human steers and reviews, but never says *who* or *what they must be able
to do*. Make it explicit: every project using the kit names who reviews the agent's work (you
alone, a maintainer, a wider team), and the harness assumes that reviewer can do a few specific
things — **write a clear spec, define "done," verify output against a source of truth, and work in
small batches.** This makes the review-capacity bottleneck concrete (review cost, not generation
cost, is the constraint).
- **Agnostic and scale-aware:** solo → a one-liner ("reviewer = me; I verify against the audit +
  the spec"); team → role-specific enablement lives in the *project's* docs, not the kit. Do **not**
  bake job titles, customers, or a business org into the kit — the reviewer might be a hobbyist, a
  student, a maintainer, or a team.

### W. Harness manifest *(new; upgrades J + M into an artifact)*
Turns "harness rot" from a thing you're supposed to remember into a thing you can read: a list of
harness components, each with what it is, owner (solo: you), the tool/model version it assumes,
last-verified date, risk tier, known failure modes, and sunset criteria. Ties directly to the
shelf-life doctrine (permanent / depreciating / appreciating). Scale honestly: a small project's
manifest is a short table; skip it if the harness is tiny.

### X. Harness change log (`HARNESS_LOG.md`) + cross-repo learning *(new)*
A journal of harness changes and *why* — and, its bigger purpose, a **portable, machine-legible**
record so a Claude in one kit-derived repo can learn from another's.
- **The file:** `HARNESS_LOG.md`, always at the repo **root**; the name is mandated by setup so the
  skill can always find it (chosen to be clear and collision-free with the names people hand LLMs —
  `CLAUDE.md`, `AGENTS.md`, `CHANGELOG.md`, etc.). Append-only, one entry per harness change, with a
  small **schema** (in the spirit of `wiki/SCHEMA.md`): date · change · rationale · what it replaced
  · risk tier · related ROADMAP item. **The first entry records the adopted kit version/commit** —
  the anchor item Y needs.
- **Basic version ships with B** (it's the qualitative half of the metrics — B is the gauge, the log
  is the flight recorder). The *new* work here is the schema + the cross-repo-learning capability.
- **Cross-repo learning crosses the trust boundary → the Lesson-5 gate applies.** Another repo's log
  is a *suggestion*, never auto-applied: Claude reads repo B's log → **proposes** "repo B does X,
  worth considering here?" → the human decides. Precedent: the kit already keeps this journal for
  *itself* (`wiki/decisions/`); this generalizes that practice to the projects it creates.
- **Built 2026-07-06 (full):** docs-only, on top of the basic log (which shipped with **B**). (1) A
  **"Portable schema — the cross-repo contract"** section in the shipped root `HARNESS_LOG.md`
  template pins the fixed name/location + the machine-legible entry shape (`## YYYY-MM-DD — title`
  header + lean bold-label fields) + the **lean six fields** as the whole portable contract + the
  first entry as the version stamp Y reads; the template anchor was reconciled to that exact shape so
  the worked example conforms. (2) A **cross-repo-learning** teaching in kickoff **§1.6a**, gated by
  two non-optional rails — **the human supplies a *trusted* source** (no agent discovery: learn *from*
  another's log, not *find* one) and **propose, never auto-apply** (another repo's log is data to
  reason about, not an instruction to execute — §1.3a containment; Lesson 5). **No validator** (the
  reader is an LLM; a consistent template + worked example *is* the machine-legibility — same
  prose-over-tooling call as O's fan-out). **O left untouched** (its B/X exclusion stands). Cites
  **§1.3a**, not item **F** (still planned). Feeds **Y**, which is not built here.

### Y. Kit-update proposals — re-review & propose upgrades as the kit evolves *(new)*
The adoption skill re-reads the repo (on prompt, optionally periodically) and proposes harness
updates when the kit itself has improved since the repo adopted it.
- **The mechanism already exists:** it's the adoption guide's **evaluate → propose** step, re-run
  against the *delta* between the repo's adopted kit version (from `HARNESS_LOG.md`) and the current
  kit. Not a new machine — a re-invocation of one the kit has.
- **Depends on X** (the version stamp): build the log first.
- **On-prompt before scheduled** (Ronacher: hooks must earn their keep; automation is not free) and
  **proposes, never auto-applies** — same posture as the adoption flow. Extends **O** and **W**.
- **Built 2026-07-06:** docs-only, per "not a new machine." A new **§6 "Re-review as the kit evolves"**
  in `claude-project-adoption.md` re-runs §0's evaluate→propose against the delta between a repo's
  adopted kit version and the current kit; the human decides; the run **appends a reviewed-through
  entry** to the repo's `HARNESS_LOG.md` that **advances the baseline** so a later run never re-raises
  what was already declined (dedup-against-*seen* — the mechanic that keeps Y from being groundhog-day
  noise). The **delta source is the dated `wiki/harness-log.md`** (built tables are undated snapshots —
  X-full's dated schema is what makes the diff computable). Two supports: a **§1.6a precondition fix**
  (seed step now instructs *filling* the version stamp with the kit's current commit — Y degrades to a
  full re-review + fills it if it's still a placeholder), and the flipped "not built yet" gesture.
  **Propose-never-apply, fit-first** (a solo repo correctly declines a team item; churn-control
  second); on-prompt. The **sibling of X-full's cross-repo learning** (source = the newer kit, trusted
  by construction) and the **forward complement of O** (missing vs. newly-available). **W** referenced
  as *planned*. No differ script; no schema change.

---

## 4. Where harness engineering is going (+ hardest challenge)

Frontier themes: evals-as-the-core-artifact; verification/reviewability as the permanent
bottleneck; single-agent → orchestrated fleets governed by economics (cost-per-merged-change,
model routing); context → memory engineering; spec/intent-driven development; MCP standardization
+ its security; harness literacy itself (the shelf-life doctrine).

- **Hardest engineering challenge: reliably evaluating non-deterministic agents** (LLM-as-judge +
  long-horizon eval). It's the meta-problem — every question ("did my edit help? did the upgrade
  regress me?") bottoms out in "can you measure agent quality reliably," and you can't cleanly: no
  single right answer; the judge is another LLM with the same failure modes; ~6pp infra noise;
  adversarial (models optimize to the eval).
- **Most interesting active work: long-horizon coherence + agent memory.** Watch **METR's
  time-horizon metric** (doubling ~every 7 months). Benchmarks mapping the edge: SWE-Bench Pro,
  SWE-EVO, LongCodeBench. The two are linked: you can't improve coherence you can't measure —
  which is why evaluation is the deeper problem.
- **Agentic work spreads beyond code (keep the kit agnostic here).** The same harness ideas —
  directives/verifiers, verification, provenance, action-risk gating — apply to any AI-assisted
  *knowledge or process work* (research, writing, analysis, ops), not only coding. The kit stays
  code-first, but the principles generalize; frame them so they don't assume a codebase *or* a
  business.
- **Cross-tool instruction standards.** `AGENTS.md` is now a real cross-tool convention (stewarded
  under the Linux Foundation's Agentic AI Foundation; 20+ tools; nearest-file precedence). The kit
  already treats it as a filename alias — worth tracking as it matures, but **don't build
  multi-runtime portability machinery prematurely** for a single-tool project.

---

## 5. Skeptic evidence — right vs. wrong (2–3 yr)

- **Durably right:** verification/review is the bottleneck (METR 2025 RCT: experienced devs ~19%
  slower while feeling ~20% faster; the Feb 2026 follow-up didn't revise it — the re-test got
  contaminated because devs refused to work without AI, itself the finding). System-design
  coherence, invariants, and taste stay human (antirez, Böckeler; benchmark backbone: SWE-Bench
  Pro ~15–24% vs ~70% on SWE-bench Verified; LongCodeBench 29%→3% as context grows). Security: AI
  writes vulns at a flat ~45% rate across model generations (Veracode).
- **Being proven wrong:** "can't do real work / just autocomplete / can't be trusted." DHH's
  reversal (Jul 2025 → "Promoting AI agents", Jan 2026) and antirez's Axis-1 shift are the clearest
  evidence.
- **The frame that resolves it:** *AI is an amplifier, not an equalizer* (DORA 2025; Anthropic
  expertise study — verified success ~15% novice → ~33% expert). The real unit is "model +
  harness." antirez's one-liner: **"Programming is now automatic, vision is not (yet)."** The
  bridge that turned even him from skeptic to daily agent user was building a harness — exactly
  what this kit systematizes.
- **Strongest justification for the verification thesis:** "Confident and Wrong" (arXiv 2603.25764)
  — a model submits a patch on 100% of runs, resolves 44%; silent semantic failure is 68–80% of
  failures and invisible to completion-/consistency-based monitoring. Independent verification on
  disk (Part 3.8) is not optional.
- **Weaker than it looks:** the "AI degrades code quality / churn / slop" narrative (GitClear) is
  contested and vendor-conflicted — founder concedes it's correlational; a peer-reviewed study
  found no churn increase. Lean on the *security* data, not the churn data.

---

## 6. Sources — README additions ✅ done (2026-07-03)

The eval-driven line, the antirez Axis 1/2 quotes (with the corrected *"vision is not (yet)"*), and
a "Field evidence the kit leans on" citation block are now in the README; every URL was verified
live 2026-07-03 (METR RCT + Feb-2026 follow-up + time-horizon paper 2503.14499; Anthropic expertise
+ Demystifying-evals; DORA 2025; Veracode 2025 report + Spring-2026 update — note original report is
**July 2025**, not October; Willison "Vibe engineering" → term shifted to "agentic engineering";
DHH "Promoting AI agents"; SWE-Bench Pro 2509.16941; LongCodeBench 2505.07897; Confident-and-Wrong
2603.25764; Amp ep. 9). Kept for reference; re-verify before reusing elsewhere.

---

## 7. Fowler → Böckeler citation fix — ✅ done in README; ✅ propagated across the kit (2026-07-06)

Verified directly: martinfowler.com/articles/harness-engineering.html (2 Apr 2026) is authored by
**Birgitta Böckeler**, and *Agent = Model + Harness*, guides-and-sensors, feedforward/feedback, and
"keeping quality left" are all **her** framing, published in Fowler's *Exploring Generative AI*
collection (he curates/edits; contributors keep their byline — which is why it's widely miscredited
to him). Fixed across the README this session (opening, "how the pieces fit," "the thinking behind
it," bibliography). **Propagated 2026-07-06:** swept the rest of the kit and corrected the same
misattribution in `LESSONS.md`, `claude-project-kickoff.md`, `wiki/sources/operator-field-reports.md`,
and one file §7 had not listed — `wiki/sources/anthropic-engineering.md` (guides-and-sensors,
harnessability, "keep quality left," and the "hardest control to automate" sensor claim — all hers).
Each Fowler ref was checked against the concept, not blanket-replaced; the only `Fowler` mentions left
kit-wide are the README's *deliberate* explanation of the miscredit. Poetic footnote: the competing AI
in the cross-check made the identical error, and one of this session's own verifier agents nearly
rubber-stamped it — the Lesson-7 failure in the wild.

---

## 8. Suggested build order

**Before adding new surface, close the 2026-07-06 defect sweep (§9)** — the bugs found are in
**A**/**B**/**O**/**R**'s own shipped scripts, and they undermine the exact "don't trust a
self-report, prove it bites" promise those items make to every project that adopts them.
**Settings-validity cluster (§9.1 O#3 + #5) — ✅ closed 2026-07-06:** strict-JSON loadability gates in
**both** verifiers, comment-free settings templates, and a comment-free command-pattern action-risk join
(details in §9.1 and `wiki/harness-log.md`). **Eval-runner defects (§9.1 A, both) — ✅ closed 2026-07-06:**
the golden-fail crash (braced interpolation) and the rubric verdict-flip (trailing-`VERDICT:` extraction),
each reproduced then fixed, guarded by a committed `evals-template/eval-runner.selftest.sh` — now run in the
kit's first CI (`.github/workflows/selftest.yml`, ubuntu + macOS) — (details in §9.1 and `wiki/harness-log.md`). **Still open:** the metrics inflation (**B**), the `AGENTS.md` fallback
(**O #4**), the §9.2 security-template gaps, and the §9.3 process gaps.

1. ✅ **Fowler fix + README citations** (Q, P) — done in README (2026-07-03); Q propagated across
   the rest of the kit (2026-07-06).
2. **Evals scaffold + harness-metrics script** (A, B) — the two to build first; A now includes the
   fixture schema + provenance rule, and B seeds the basic `HARNESS_LOG.md` companion.
3. **Action-risk tiers + name-the-reviewer** (R, V) — the highest-value cross-check newcomers;
   cheap, high-leverage, and both feed the conformance script.
4. **Dependency-vulnerability scan + safeguard-rot check** (G, H) — security + false-security hygiene.
5. ✅ **Adoption check + fan-out driver** (O) — done 2026-07-06; the biggest; makes the rest
   stick. Checks for R and V (and A + the floor); `scripts/kit-conformance.sh` + kickoff §1.6c.
6. Fold in the rest as the safety net pulls them in — non-git rollback (S), tool inventory (T),
   incident runbook (U), harness manifest (W), plus C, D, E, I, J, K–N, F. Then the cross-repo
   layer: ✅ **X** (harness-log schema + vetted cross-repo learning) — done 2026-07-06; ✅ **Y**
   (kit-update proposals) — done 2026-07-06 on X's version stamp. Remaining: the hygiene/frontier
   tail (S, T, U, W, C, D, E, I, J, K–N, F).

---

## 9. Known defects in shipped items — 2026-07-06 Fable multi-lens review

**Provenance.** A maintainer-requested review of the whole kit against its own three intentions
(kickoff / adoption / teaching), run as one Fable-orchestrated fan-out of **seven independent
Sonnet 5 (max-effort) agents**, one per area, plus a firsthand Fable read of the core docs. Every
bug below was **reproduced** — in a scratch repo, against a hand-built fixture, or against live
vendor documentation fetched during the review — not inferred from reading alone. Full per-area
write-ups, including the untruncated evidence and additional lower-severity findings, live in
[`fable-analysis-7-6-26/`](fable-analysis-7-6-26/00-synthesis.md). Unlike the rest of this ROADMAP,
this section catalogs **defects in already-"Built" work**, not proposed additions — no letter is
assigned; each bug is filed against the item it belongs to. **Status: open** as of 2026-07-06 unless
noted.

### 9.1 Reproduced script bugs

**A — `claude-eval-base.sh` crashes on the exact failure it exists to catch.**
Line 101's error message — `` efail "$name  [golden]  expected «$expected»  got «$candidate»" `` —
places an unbraced `$candidate` directly before the closing guillemet `»` (UTF-8 lead byte `0xC2`);
bash's identifier scanner consumes that byte into the variable name, and under `set -u` (line 46)
this raises `unbound variable` and **aborts the whole script** instead of reporting `FAIL`.
Reproduced identically on macOS system bash 3.2.57 and Homebrew bash 5.3.15 (`LANG=en_US.UTF-8`);
not verified on Linux/glibc, so treat as a scoped-but-serious finding, not a universal one. It
cascades: a golden failure on fixture #1 silently prevents fixtures #2+ from ever running — a
12-case suite reports nothing about the other 11. Telling omission: this ROADMAP's own entries for
**H**, **O**, and **X** carry explicit "proven on fixtures" annotations; **A**'s entry never did,
and the untested path is exactly where the bug lives. **Fix:** quote/brace the interpolation
(`"${expected}"`) or drop the guillemets; add a fixture that deliberately fails and assert the
runner reports `FAIL` + continues, before trusting this script again.
**✅ Fixed 2026-07-06 — reproduced, fixed, proven on fixtures (the annotation this entry said was
missing).** Braced **both** interpolations to `${expected}` / `${candidate}` (keeping the guillemets),
making the variable boundary explicit so bash stops folding the `»` lead byte into the name; a scan
confirmed line 101 was the *only* unbraced-var-before-multibyte site, so this closes the class, not just
the instance. **Repro→fix:** with `LANG=en_US.UTF-8` and a stub `EVAL_CMD`
returning a value ≠ `expected`, the pre-fix runner aborted with `expected�: unbound variable` and printed
no `FAIL`; post-fix the same run prints `✗ FAIL … expected «config/timeout.conf» got «MATCH»` **and
continues to the next fixture** (a two-fixture suite whose #1 fails now still runs #2 → `✓ PASS`). The
committed regression guard `evals-template/eval-runner.selftest.sh` encodes exactly that assertion
(deliberate golden failure → `FAIL` + continuation) and was itself proven to fail if the braces are reverted.

**A — the rubric judge's verdict extraction can flip a correct verdict either direction.**
Line 113 — `` grep -m1 -oE 'PASS|FAIL' | head -1 `` — scans the **judge's entire output** for the
first line containing either keyword, even though the judge prompt (line 112) asks for "ONE word
on the first line." Proven both failure directions with stubbed judges that reason before
concluding: a genuinely bad answer graded `PASS` because its reasoning said "...tempting to
PASS..." before the real `Final verdict: FAIL`; a genuinely good answer graded `FAIL` because its
reasoning mentioned "FAIL" while explaining why it did *not* fail, before the real `Overall
verdict: PASS`. This is additive noise on top of the disclosed ~6pp LLM-judge infra-swing (already
taught honestly elsewhere in the kit) — but this specific failure mode is a harness bug, not
model noise, and is currently undisclosed. **Fix:** anchor extraction to line 1 of the judge's
output, or require a fixed delimiter (e.g. `VERDICT: PASS`) the judge must emit last.
**✅ Fixed 2026-07-06 — reproduced both directions, fixed, proven on fixtures.** Took the delimiter form
(more robust than a line-1 anchor, which still mis-reads a judge that reasons *before* concluding — the
exact failure mode). The judge **prompt and the extraction changed as one contract**: the prompt now
requires a trailing line `VERDICT: PASS`/`VERDICT: FAIL` and nothing after it, and extraction reads the
**last** such line — `grep -oE 'VERDICT:[[:space:]]*(PASS|FAIL)' | tail -1 | grep -oE 'PASS|FAIL'`. A
missing delimiter → empty verdict → **conservative FAIL** (`judge verdict: <none>`) — fails safe, never a
silent pass; a "fall back to scanning the whole output" branch was deliberately *not* added (it would
reintroduce the bug). **Repro→fix:** stub judges that reason with the opposite keyword before concluding
graded a bad answer `PASS` and a good answer `FAIL` under the old first-match `grep`; under the new
extraction (new-protocol stubs emitting `VERDICT:` last) both return the correct verdict. Guarded by
`evals-template/eval-runner.selftest.sh` (both directions + the safe default), proven to fail if the
extraction reverts to first-match.

**O — `scripts/kit-conformance.sh` gives a false PASS on a malformed settings floor.**
The script never validates that `.claude/settings.json` is syntactically loadable JSON — it only
checks file presence plus a text grep for deny patterns (lines 137–147), while it *does* run
`bash -n` on its sibling `audit.sh` three sections earlier (lines 164–173) — an inconsistency, not
a considered scope decision. Reproduced: a hand-truncated `settings.json` with unbalanced braces
(confirmed invalid via `python3 -c json.load`) still printed "per-repo deny floor present — active
secret-READ deny." This directly contradicts `claude-project-adoption.md`'s own Definition-of-Done,
which promises the floor is "proven to bite... a denied secret read actually blocks" and names this
exact script as the machine check of that promise. **Fix:** add a JSON-validity check ahead of the
grep (prefer `jq` if present, else `python3 -c json.load`, else a loud `SKIPPED` naming that
validity couldn't be confirmed — no hard dependency needed, and this preserves item **O**'s own
`SKIPPED ≠ PASS` principle).
**✅ Fixed 2026-07-06.** `kit-conformance.sh` now runs a **strict** `python3 -c json.load` (the audit
does the same) before the grep — settings that Claude Code would silently drop → **FAIL**, not a false
PASS; absent python3 → loud SKIP. (Note: `jq` is *not* usable here — like `json.load` it's strict, which
is correct, since CC is strict too; see #5.) Proven on the fixture matrix (a comment-bearing or
brace-unbalanced settings → FAIL/exit 1; a valid one → PASS).

**O — `scripts/kit-conformance.sh` hardcodes `CLAUDE.md`, with no `AGENTS.md` fallback.**
Line 64 (`CLAUDE_MD="$TARGET/CLAUDE.md"`) contradicts the kit's own stated policy that "Claude
reads either" (`claude-project-kickoff.md:727`) and that a project may keep `AGENTS.md` as the
sole physical file with `CLAUDE.md` merely symlinked to it (`claude-project-adoption.md:117-119`).
Reproduced: an `AGENTS.md`-only, no-symlink fixture gets a hard FAIL, exit 1 — which also silently
skips the routing/budget/reviewer checks gated on `CLAUDE.md`'s presence. ROADMAP §4 names
`AGENTS.md` as a real, actively-governed cross-tool convention, so this is likely to bite *more*
over time, not less. **Fix:** resolve either filename (checking for a symlink or direct file)
before gating the downstream checks on its presence.

**R (certified by O) — the action-risk tag's prescribed JSON syntax is invalid JSON.**
The mechanism requires an inline trailing `//` comment on a live `.claude/settings.json` array
element (`templates/project.settings.json:20-25, 38-40`; the fenced example at
`claude-project-kickoff.md:239-274`) — confirmed invalid via `python3 -c json.load`. Built a
fixture using exactly the prescribed form: `scripts/kit-conformance.sh` gives it a clean
"action-risk gates wired" PASS while Python's parser rejects the identical file. Whether Claude
Code's own settings loader accepts trailing-comment JSONC (and whether a load failure would be
silent or loud) was **not directly testable** in this review; open Claude Code feature requests
found mid-2026 (`anthropics/claude-code` #29370, #12688, #17968) suggest it is not reliably parsed
today. Notably, the kit's own live, committed `.claude/settings.json` sidesteps the risk — it uses
only a leading comment banner before the opening brace, never an inline comment on an array
element — so the one settings file known to be in real use has never exercised the riskier form
prescribed to every other project. **Fix:** verify against the currently-installed Claude Code's
actual settings parser before shipping the inline-comment form further; if unsupported, move the
tag to a sibling non-JSON manifest or a comment-only banner line, and update the template + the
kickoff §1.3c fenced example together.

**✅ Verified + fixed 2026-07-06 — and it was bigger than this entry knew.** Tested directly against the
installed **Claude Code 2.1.201** via its own `--debug` settings-load log (a controlled, file-based
`projectSettings 0 vs 1 rule(s)` comparison): settings are **strict JSON, no JSONC**, and **ANY `//`
comment silently drops the ENTIRE file** — not just the inline-array form this entry flagged, but the
**leading banner too** (the form this entry called a "sidestep"). The kit's own `.claude/settings.json`,
`templates/project.settings.json`, and `templates/managed-settings.template.json` were therefore **all
silently non-functional** (masked only where the managed floor independently covered the same denies).
The drop is **silent** in `-p`/SDK/CI mode (CLI help: "settings files that fail validation are silently
ignored"). **Fix (A–D):** all three shipped settings files stripped to comment-free strict JSON (their
teaching relocated to `templates/README.md`); the action-risk marker redesigned to a **command-pattern
join** (the CLAUDE.md table's `<!-- action-risk -->` marker stays — markdown — and names each gate's
*exact settings rule*; the audit/conformance join by that rule string, no settings-side comment); and a
**strict-JSON gate added to BOTH `scripts/audit.sh` and `scripts/kit-conformance.sh`** so a `//` re-added
out of habit **FAILs loudly** instead of silently voiding the floor. All proven via CC's own loader
(comment-free files now load their rules) + the fixture matrix. Version-scoped: JSONC is #17968 (open) —
if it ships, revisit (item **Y**).

**B — `scripts/harness-metrics.sh`'s audit-check count is measurably inflated.**
Line 91's grep pattern `` (pass|warn|fail)[[:space:]]+" `` matches the shape of a call anywhere in
a line's text regardless of a leading `#`. Measured directly against `claude-audit-base.sh`: 18 of
75 matches (24%) sit inside comment-only lines (the INVARIANTS section's worked examples, lines
132–194), which never execute. The contamination doesn't shrink over time — it scales with how
much illustrative commentary a project's real audit script accumulates, which is the opposite of
what a trend metric needs. Separately, the script never counts eval fixtures despite
`claude-audit-base.sh` (lines 667–674) already computing `n_evals` for its own purposes — an
equally "free" number left off the scorecard. **Fix:** strip full-line and trailing `#`-comments
before counting; add the eval-fixture count alongside the existing two free metrics.

### 9.2 Security template gaps

These weren't reproduced as code bugs (there's no script to break) but were verified against live
Claude Code documentation fetched during the review, and represent the same class of risk as 9.1 —
a gap between what the kit teaches and what it ships.

- **The managed floor is the kit's only source of hard guarantees, and is a permanent, silent
  `SKIP` with zero installer automation and zero durable verification** — true even with every
  other ROADMAP item built, because item **O**'s own conformance script treats it as an
  unconditional SKIP by design (`ROADMAP.md` §1, "the managed floor is a loud SKIP...
  SKIPPED ≠ PASS"). Confirmed against Anthropic's current sandboxing docs that the stock,
  zero-config default still allows reading `~/.aws/credentials` and `~/.ssh/`, and the permissions
  docs that file reads require no approval by default — so the gap between "protected per this
  guide" and "stock default" is exactly one un-nagged, manual, root-privileged step. No mechanism
  anywhere in the kit — kickoff, adoption, or ongoing — will ever tell a user this step didn't
  happen. **Fix:** a small `verify-floor` check that reads the (typically world-readable) managed
  file's *content* and confirms its critical keys are present — checking content is different from
  inferring from absence, so this doesn't violate `SKIPPED ≠ PASS`.
- **`templates/project.settings.json` ships weaker credential protection than the kit's own
  dogfooded settings.** The template's deny list covers only in-project paths with the comment
  "machine creds are already denied in the managed floor" (lines 28-31) — but the kit's own
  `.claude/settings.json` (lines 14-17) adds the same machine-credential denies
  (`~/.ssh/**`, `~/.aws/**`, `~/.npmrc`, `*.pem`, `*.token`) redundantly anyway, exactly the
  belt-and-suspenders duplication the guide argues for elsewhere. **Fix:** backport those lines
  into the template — two lines, materially shrinks the blast radius of the point above for anyone
  who never installs the managed floor.
- **No template gates MCP servers or `WebFetch` domains by default**, despite three separate kit
  docs correctly naming MCP and the native web tools as unsandboxed, un-audited surfaces
  equivalent in risk to Bash (`claude-project-kickoff.md:502-506`). **Fix:** a repo-neutral
  "deny `mcp__*` by default, allowlist per trusted server" line in `templates/project.settings.json`.
- **No CI workflow template**, despite `claude-audit-base.sh`'s own comment (lines 304-307) arguing
  CI enforcement of the audit is strictly superior to the client-side pre-commit hook the kit *does*
  ship wiring for. **Fix:** a minimal `.github/workflows/audit.yml`-equivalent starter, least-
  privilege token + SHA-pinned actions per the kit's own §1.3b guidance.
- **`managed-settings.template.json`'s `docker *` sandbox exclusion has no companion guard against
  privilege-escalating flags** — a `docker run --privileged` or a docker-socket bind-mount is a
  well-known one-command host-root escape, and Anthropic's own sandboxing docs flag this exact risk.
  **Fix:** an `ask` rule on `docker run --privileged*` / `-v /var/run/docker.sock*` alongside the
  existing exclusion.

### 9.3 Process / hygiene gaps

- **`HARNESS_LOG.md`'s placeholder anchor (`<YYYY-MM-DD>`, `<kit-version>`, `<commit-sha>`) has no
  enforcement or reminder to ever get filled in** — and both `scripts/kit-conformance.sh` and
  `claude-audit-base.sh` explicitly, by documented design, exclude `HARNESS_LOG.md` from their
  rosters (audit lines 336, 351: "in NEITHER clause BY DESIGN"). Item **Y** (built 2026-07-06)
  depends entirely on that stamp being real; left as a placeholder — a plausible outcome for an
  unenforced TODO — **Y** silently has nothing to diff against and nothing in the kit would ever
  flag it. **Fix:** a one-line check (in the audit or conformance script) that WARNs if the anchor
  entry's header still contains literal `<` characters.
- **The `prompts/` directory (the build specs behind items O/R/V/X) is untracked, unreferenced,
  and already stale.** `git status` shows it untracked; README/ROADMAP/glossary/wiki have zero
  references to `prompts/` anywhere; two of its files (`build-R`, `build-V`, both dated
  2026-07-04) open with the pre-rename path `claude-harness-kit`, while the later files
  (`build-O`, `build-X`, both 2026-07-06) correctly say `claude-kickoff-kit` — the repo was renamed
  between the two dates and the earlier prompts were never updated. The directory has no rot-check
  analogous to item **H**, applied to itself. **Fix:** either track it with a short index +
  the same anchor-check discipline as **H**, or fold each prompt's durable content into this
  ROADMAP's item write-ups and delete the directory — undecided; the maintainer's call.

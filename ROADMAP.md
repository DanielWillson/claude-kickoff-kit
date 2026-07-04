# Kit Roadmap — Fable Review (2026-07-03)

**What this is.** A durable capture of a Fable-driven review of the Claude Kickoff Kit —
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
| **O** | Self-verifying **adoption check + fan-out verifier** | **Highest** | Frontier/Unique |
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
| **Y** | **Kit-update proposals** — skill re-reviews repo & proposes upgrades as the kit evolves | Medium | Frontier · *new* |
| **H** | **Safeguard-rot check** — safeguards assert their own anchor | Medium | Hygiene |
| **J** | **Re-verify the harness after a Claude Code upgrade** | Medium | Hygiene |
| **I** | **Baseline for fuzzy output** (tolerance/rubric) | Lower | Frontier (cousin of A) |
| **K–N** | **4 internal-consistency fixes** | Lower | Hygiene |
| **F** | **Untrusted-content rule** (name the untrusted-content surface) | Lower | Hygiene |
| **P** | **README additions** — eval-driven line, Axis 1/2 quotes, citation block | ✅ **Done (2026-07-03)** | Documentation |
| **Q** | **Fowler → Böckeler citation fix** | ✅ **Done in README; propagate to rest of kit** | Hygiene |

**If you do only three: O, A, B.** Add **G** if security is near-term. The two highest-value
*newcomers* from the cross-check are **R** (action-risk tiers) and **V** (name the reviewer) —
both fill genuine holes. **O** remains the item that makes all the others actually stick.

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

### Y. Kit-update proposals — re-review & propose upgrades as the kit evolves *(new)*
The adoption skill re-reads the repo (on prompt, optionally periodically) and proposes harness
updates when the kit itself has improved since the repo adopted it.
- **The mechanism already exists:** it's the adoption guide's **evaluate → propose** step, re-run
  against the *delta* between the repo's adopted kit version (from `HARNESS_LOG.md`) and the current
  kit. Not a new machine — a re-invocation of one the kit has.
- **Depends on X** (the version stamp): build the log first.
- **On-prompt before scheduled** (Ronacher: hooks must earn their keep; automation is not free) and
  **proposes, never auto-applies** — same posture as the adoption flow. Extends **O** and **W**.

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

## 7. Fowler → Böckeler citation fix — ✅ done in README; propagate to the rest of the kit

Verified directly: martinfowler.com/articles/harness-engineering.html (2 Apr 2026) is authored by
**Birgitta Böckeler**, and *Agent = Model + Harness*, guides-and-sensors, feedforward/feedback, and
"keeping quality left" are all **her** framing, published in Fowler's *Exploring Generative AI*
collection (he curates/edits; contributors keep their byline — which is why it's widely miscredited
to him). Fixed across the README this session (opening, "how the pieces fit," "the thinking behind
it," bibliography). **Still to do:** sweep the rest of the kit for the same misattribution —
`LESSONS.md`, `claude-project-kickoff.md`, and `wiki/sources/operator-field-reports.md` all
reference Fowler and should be checked. Poetic footnote: the competing AI in the cross-check made
the identical error, and one of this session's own verifier agents nearly rubber-stamped it — the
Lesson-7 failure in the wild.

---

## 8. Suggested build order

1. ✅ **Fowler fix + README citations** (Q, P) — done in README this session (uncommitted);
   propagate Q to the rest of the kit.
2. **Evals scaffold + harness-metrics script** (A, B) — the two to build first; A now includes the
   fixture schema + provenance rule, and B seeds the basic `HARNESS_LOG.md` companion.
3. **Action-risk tiers + name-the-reviewer** (R, V) — the highest-value cross-check newcomers;
   cheap, high-leverage, and both feed the conformance script.
4. **Dependency-vulnerability scan + safeguard-rot check** (G, H) — security + false-security hygiene.
5. **Adoption check + fan-out driver** (O) — the biggest; makes the rest stick; have
   it check for R and V.
6. Fold in the rest as the safety net pulls them in — non-git rollback (S), tool inventory (T),
   incident runbook (U), harness manifest (W), plus C, D, E, I, J, K–N, F. Then the cross-repo
   layer: **X** (harness-log schema + vetted cross-repo learning), then **Y** (kit-update proposals;
   needs X's version stamp).

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
| **A** | **Behavioral evals** as a first-class `evals/` artifact (incl. non-code workflows) | **Highest** | Frontier/Unique · ✅ **Built (2026-07-04)** |
| **B** | **Harness scorecard** (generalize the wiki `metrics` shape) | **High** | Frontier/Unique · ✅ **Built (2026-07-04)** |
| **R** | **Action-risk tiers** — gate agent actions by reversibility × reach | **High** | Frontier/Unique · *new* · ✅ **Built (2026-07-04)** |
| **V** | **Name the reviewer** — make the human review/steer dimension explicit | **High** | Frontier/Unique · *new* · ✅ **Built (2026-07-06)** |
| **G** | **Dependency-vulnerability scan** + stronger secret scan in `audit.sh` | **High** | Hygiene · ✅ **Built (2026-07-06)** |
| **C** | **Flight recorder** → feed the safety net from bad transcripts | Med–High | Frontier-ish · ✅ **Built (2026-07-06)** |
| **S** | **Rollback/recovery for non-git state** (DB, hosted config, deploy, external backend) | Med–High | Hygiene · *new* · ✅ **Built (2026-07-06)** |
| **E** | **Spec-as-source** (living spec) | Medium | Frontier · ✅ **Built (2026-07-06)** |
| **D** | **Cross-project memory** (→ queryable knowledge service) | Medium | Frontier/Unique · ✅ **Built (2026-07-07)** |
| **T** | **Tool inventory** | Medium | Hygiene · *new* · ✅ **Built (2026-07-06)** |
| **U** | **Incident runbook** for agent mistakes (forward, not retrospective) | Medium | Hygiene/Frontier · *new* · ✅ **Built (2026-07-06)** |
| **W** | **Harness manifest** (owner/version/last-verified/risk/sunset) | Medium | Hygiene · *new* · ✅ **Built (2026-07-06)** |
| **X** | **Harness change log** (`HARNESS_LOG.md`) + vetted **cross-repo learning** | Med–High | Frontier/Unique · *new* · ✅ **Built (2026-07-06)** |
| **Y** | **Kit-update proposals** — skill re-reviews repo & proposes upgrades as the kit evolves | Medium | Frontier · ✅ **Built (2026-07-06)** |
| **H** | **Safeguard-rot check** — safeguards assert their own anchor | Medium | Hygiene · ✅ **Built (2026-07-04)** |
| **J** | **Re-verify the harness after a Claude Code upgrade** | Medium | Hygiene · ✅ **Built (2026-07-06)** |
| **I** | **Baseline for fuzzy output** (tolerance/rubric) | Lower | Frontier (cousin of A) · ✅ **Built (2026-07-07)** |
| **K–N** | **4 internal-consistency fixes** | Lower | Hygiene · ✅ **Built (2026-07-06)** |
| **F** | **Untrusted-content rule** (name the untrusted-content surface) | Lower | Hygiene · ✅ **Built (2026-07-07)** |
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
- **Built 2026-07-06 (teaching-only, like S — no new file).** C *reframes the safety-net doctrine that
  already lives in §1.6* rather than adding a verifier: those bullets grow the net from **fixed code bugs
  (feed one)**; C adds **feed two — bad or *expensive* runs** (looped, wandered, produced slop, cost 5×,
  with no bug at all). Two moves: keep the run legible (retain the **run record** — the session transcript
  — + app logs the agent can read) and post-mortem the bad/expensive ones into an artifact, feeding the
  *whole* net: a regression grep, a `CLAUDE.md` line, a wiki incident page, or — sharpest, for a *judgment*
  failure — a **behavioral eval case** (item A). **Terminology collision resolved:** "flight recorder" was
  already entrenched for `HARNESS_LOG.md` (the *harness-change* journal); C's teaching leads with **run
  record** (raw observation of what the agent *did*) and disambiguates at both entries — the item keeps the
  "Flight recorder" label, the prose does not reuse the term for two things. **C vs U:** U (`RUNBOOK.md`) is
  the *acute* live-incident drill; C is the *routine* learn-from-any-bad-run habit — C reuses the wiki
  incident-page shape, ships no post-mortem template. The *expensive* half ties to §1.6a's scorecard
  (tokens/$) + Part 3.10. **Graduation** is a pointer, not a build (Langfuse/LangSmith/OTel GenAI traces —
  same humility as D). A **doctrine-twin sweep** updated the safety-net-growth statements (glossary
  *safeguard* def, README, Principle 2's bug-trail) so none reads as "bugs are the *only* feed"; a
  self-contained two-source note added to the audit's `REGRESSION GUARDS` comment (the repo-side anchor).

### D. Cross-project memory
Markdown works for one project; across many, or for cross-project knowledge, plain files stop
scaling (can't query them — Yegge's "605 rotting plan files").
- **In the kit:** a maturity trigger ("when project-local markdown stops scaling → graduate to a
  *queryable knowledge service* that keeps the reconcile-against-truth property"), plus the
  pattern: a small database or an MCP server over the knowledge base (with trust banners /
  last-verified). Least-solved gap in the field — stay humble: name the trigger, point at the
  pattern, don't over-promise. (Keep the example project-neutral; don't name a specific product.)
- **Built 2026-07-07 (teaching-only — a graduation pointer, not a build, like C's Langfuse note).**
  Landed as a new paragraph closing **§1.5b** (the wiki section), the natural home: D graduates the
  *wiki* pattern, so it belongs beside it. **The reconciliation that makes it non-contradictory** (the
  thing this item most risked getting wrong): the CLAUDE.md skeleton in **§1.5** emphatically forbids
  putting project facts in cross-project/global memory — *"a fact about this project loads into every
  other and pollutes it… not versioned, shared, or reconciled — it silently rots."* D is literally
  "cross-project memory," so the prose names the distinguishing property head-on: the *forbidden* store
  is **unreconciled** memory; D's queryable service is legitimate **only because it keeps the
  reconcile-against-truth property** (trust banners / last-verified / reconcile pass). So the graduation
  is explicitly *"scale the **reconciled** store (the wiki), not the **unreconciled** one (memory)"* —
  the exact self-contradiction class the K–N sweep and the flight-recorder collision existed to kill,
  headed off rather than shipped. The axis is ***many projects*** (not "one wiki gets deep"); the shape
  is a small DB or an MCP over the knowledge base; the kit's own `wiki/` + reconcile pass is named as the
  small end of that shape. Stays humble per the item: names trigger + shape, builds nothing, names no
  product. Glossary row already carried the framing (no status field to change).

### E. Spec-as-source
Make the spec a *living* file like the wiki, not a fill-in-once doc.
- **Build (few lines):** add a "reconcile against code" freshness anchor to the spec template;
  add a safety-net line ("when behavior changes on purpose, update the spec in the same commit");
  point CLAUDE.md's knowledge-routing at the spec as the home of *intent*.
- **Built 2026-07-06.** All three, plus the piece that makes them *bite*. (1) `prd-template.md` gains the
  `<!-- reconcile-code: … -->` anchor (mirroring `readme-template.md`) + a living-doc banner: it's the source
  of truth for *intended behavior*, kept current in the **same commit** as any deliberate behavior change, at
  the repo **root** so the check finds it. (2) **The freshness check was generalized, not duplicated:** the
  audit's README-only block now loops over **any root-level doc carrying the anchor** — the anchor is the
  *opt-in*, so the spec (whatever it's named) is checked exactly like the README. **Root-only glob on purpose**
  (a recursive scan would drag in `node_modules/**/README.md`); a placeholder-only anchor stays **silent** (no
  false PASS/WARN). Proven on fixtures: current→PASS, code-moved-ahead→WARN (forced commit dates, since `%ct`
  is second-granular), per-doc independence (reconciling the spec clears only its WARN), no-`.md`→safe. (3)
  Routing updated at all four sites (CLAUDE.md skeleton, the three-doc separation, the one-line rule, the
  checklist) — **the collision resolved, not deepened:** spec = *what the system should do + product intent*;
  wiki = *why the code ended up this way + history*. Both hold "why," but different whys, stated apart so it
  doesn't reintroduce the conflicting-docs tax. **No kit-self spec instance** — the kit is a meta-repo with no
  product spec to fill (unlike W's manifest); `prd-template.md` is the template and that's the whole artifact.

### F. Untrusted-content rule
Architecture already handles it (contain, not detect). Add one line to §1.3a naming the untrusted-
content surface generically: **fetched web pages, PDFs, CSVs, emails, screenshots, transcripts,
and any tool/MCP output are data, not instruction** — the sandbox limits *damage*, not the
*hijack*. No build.
- **Built 2026-07-07.** The §1.3a untrusted-content bullet *already* named issue bodies / PR titles /
  web pages / tool output; F **sharpened the existing bullet** rather than adding a second one (which
  would have re-said what was there — the thing the consistency sweep checks for). Two additions, both
  the item's own words: (1) the surface list now enumerates **PDFs, CSVs, emails, screenshots,
  transcripts, and any tool/MCP output** alongside the ones already listed, with the one-line rule stated
  outright — *fetched or tool-returned content is data, not instruction*; (2) the **division of labor**
  the glossary F-row already promised — *the sandbox limits the **damage** a hijacked agent can do; it
  does not prevent the **hijack***. A redirected agent acting *within* its sandbox is still redirected —
  containment caps the blast radius, treating content as data stops the redirection. The bullet is now
  tagged `(item F)` so it's greppable. No new file, no settings change.

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
- **Built 2026-07-07 (teaching-only — no runner change, deliberately).** The eval runner (§1.6b)
  *already* grades fuzzy output (the `rubric` arm), so I is a **pointer, not machinery** — the ROADMAP
  scopes it "Lower, cousin of A, reuses the same split," and touching `claude-eval-base.sh` would have
  over-built it. Landed as a **sub-bullet under Principle 10's "pin a baseline" bullet**: exact-reproduce
  is the **golden** case (a number, a path, a normalized string); when the pinned output has no single
  right value (an LLM/agent step, prose, a ranking, a summary), pinning `==` is a flaky test that fails on
  paraphrase, so drop to the **fuzzy baseline** — a **tolerance band** (±ε, or set/ordering preserved),
  **multi-run sampling** (check the distribution, not one draw), or a **rubric/LLM-judge** — *the same
  golden-vs-rubric split as §1.6b, applied to the baseline instead of a fresh eval*, carrying the same
  honest LLM-judge caveat (prefer a tolerance band over a judge where the output admits one). **Reciprocal
  cross-link** wired both ways: Principle 10 → §1.6b, and §1.6b's closing caveat → Principle 10 (the prior
  bare "item I is the cousin" parenthetical was sharpened into the actual link). Glossary row already
  matched (no change).

### J. Re-verify the harness after a Claude Code upgrade
You prove safeguards "bite" at setup, but nothing re-checks after the *tool* updates (which can
silently drop a setting). **Build:** add "re-run §1.4 checks after any Claude Code major upgrade"
to the checklist + doctrine. Treat a tool upgrade like a model upgrade. (See **W** — this becomes
a row in the harness manifest.)
- **Built 2026-07-06 (docs-only, alongside W).** Realized in three coupled places, not one line: (1) a
  **§1.4 doctrine bullet** — a Claude Code upgrade is a scheduled maintenance event, re-run the "prove it
  bites" list, because an upgrade can silently drop a setting; (2) the **README shelf-life doctrine** now
  names a *tool* upgrade as the same kind of event as a *model* upgrade (it previously named only the
  latter); (3) the **manifest's re-verify-trigger column** (item W) is where J becomes machine-legible —
  each depreciating row names "Claude Code upgrade → re-run §1.4". Its own justification came from *this
  session*: the **CC 2.1.201 silent-comment-drop** (verified via CC's `--debug` load log during the §9.1
  fix) is a live instance of a boundary going quietly inert across a version bump — the exact failure J
  exists to catch, now cited as the worked example in all three places. Plus a Quick-Checklist line.
  Absorbs the re-verification half of **M** (the shelf-life/date-stamp habit); M's doc-wide sweep of
  scattered version facts stays open.

### K–N. Internal-consistency fixes (tensions)
- **K:** "keep CLAUDE.md short" vs. the starter skeleton that's already fairly long — trim or
  acknowledge it's near budget.
  **✅ Built 2026-07-06 (acknowledge, not trim).** Trimming the skeleton is subjective and risks losing
  value, so the fix names the tension instead: a line in the §1.5 line-budget teaching says the starter
  skeleton is **deliberately near the ~200-line ceiling — a menu, not a mandate** — and to *delete the
  sections a given project doesn't need* (no UI → the design-token block; no outward actions → the
  action-risk table; single module → the module map) rather than shipping a `CLAUDE.md` that starts over
  budget. Landed as guide prose, **not** as more lines inside the seeded skeleton.
- **L:** "never paste the kit in" vs. the "how we build here" block that *is* a kit digest — add
  one clarifying line (the digest is the intended exception; the kit *prose* is what you don't
  paste).
  **✅ Built 2026-07-06.** The scaffolding rule (§"the kit is scaffolding") already carried the carve-out
  ("the principles internalized as a *lean* digest in `CLAUDE.md`, not the full guide pasted in"); rather
  than add a third statement, that line was **strengthened with an explicit pointer** — the §1.5 "How we
  build here" block *is* that digest, the **one intended exception** to "never paste the kit," as opposed to
  the kit's *prose* (the guides), which is what you never paste or `@`-import. Placed as guide prose, not as
  a bullet inside the seeded digest (where "the exception to never-paste-the-kit" would read as nonsense to a
  project that has no kit).
- **M:** version-specific facts ("2.1.x", red-team stats) in a durable doc — date-stamp them +
  the re-verification habit (ties to J/W).
  **✅ Built 2026-07-06 (docs-only, on W's mechanism).** W already gave version-assumptions a *dated home*
  (the manifest's last-verified column); M closes the *doc-wide* gap. The audit found README (Field-evidence
  block, URLs verified 2026-07-03) and LESSONS (`v1, claims verified 2026-07-01`) **already dated** — the one
  durable doc pinned to a Claude Code version with **no** as-of date and **no** re-verify pointer was
  `CHEATSHEET.md`. Fixed: its header now stamps **"2.1.x docs, live checks vs 2.1.201, last verified
  2026-07-06"** and states the **re-verification habit** in the kit's own voice — *these are version-pinned
  facts, not permanent; re-verify after any major Claude Code upgrade (items J/W)* — the tie J/W asked for. The
  standalone red-team figure (sandbox-OFF, 5/44 blocked) is now dated **(one machine, 2026-07)** and flagged
  version-pinned; the README shelf-life 2.1.201 mention carries **"verified 2026-07-06"**. The scattered
  kickoff `2.1.201` mentions were left as-is: each already anchors to **§9.1** (dated 2026-07-06), so they
  inherit the stamp rather than repeat it — dating every inline mention would be noise, not signal.
- **N:** Principle 4 "solo-on-main is fine" vs. Part 3.11 "unattended runs always get a worktree"
  — add a cross-reference.
  **✅ Built 2026-07-06 — and found a sharper twin.** The stated fix: a **reciprocal cross-reference** — at
  Principle 4, "the one carve-out: an *unattended* run is not solo-on-`main` — it gets its own worktree (Part
  3.11)"; at Part 3.11, "this is the carve-out to Principle 4's solo-on-`main`, which is about *attended*
  work." (Both live in the guide, so guide-internal §/Part refs are correct here.) **The twin:** the shipped
  `CLAUDE.md` digest bullet flatly said *"branch first, never commit straight to `main`"* — a direct
  contradiction of Principle 4's "solo-on-`main` is fine," and worse because that bullet is **project-retained**
  (it lives in the seeded `CLAUDE.md`). Softened to *"branch first once anyone else shares the repo —
  committing to `main` solo (with the auto-commit net) is fine"* — reconciled **and self-contained** (no
  `Principle 4`/`§` ref that would dangle once the kit steps away — the same self-containment discipline as the
  `HARNESS_MANIFEST.md` fix). A kit-wide sweep for other flat "never to `main`" statements came back clean.

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
- **Built 2026-07-06 (teaching-only — no new file, deliberately).** S is a *ritual at a moment*, not a
  registry, so it needed no artifact (unlike T/U). Realized as a new **Principle 10 bullet** that generalizes
  the existing "a data migration is not git-reversible" case to *all* out-of-git state, and adds the concept
  that was genuinely missing kit-wide (grep-confirmed): a **recovery owner**. The triad is **snapshot (via the
  system's real backup/export) + a documented way back + a recovery owner**, gated to when the project has
  out-of-git state (fires on the same Intake Q5/Q7 + §1.3a Hardened-tier signals that already exist — no new
  intake question). The self-contained §1.5 digest echo was broadened to match; a Quick-Checklist line added.
  Cross-linked to **U**: S is the *before* half (take the snapshot), `RUNBOOK.md`'s undo step is where it gets
  *used* after.

### T. Tool inventory *(new; generalizes "connector/MCP inventory")*
Any project where the agent has tools — MCP servers, connectors, plugins, browser extensions, API
integrations — should keep a small inventory: per integration, its owner, scopes/permissions, what
data it can read, whether it can write, where its credential lives, last review date, and how to
disable it. The security docs cover credential *layering* and rotation but no artifact inventories
the *fleet of tools* a given project runs. As the tool surface grows, this is where you look when
something has too much access or needs killing. Scale honestly: one MCP server → one line.
- **Built 2026-07-06.** Ships a tier-optional **root `TOOL_INVENTORY.md`** template (self-contained;
  worked-example rows) — deliberately its **own file, not a section of `HARNESS_MANIFEST.md`**: the axes
  differ (T = access-scope × credential-location × blast-radius; the manifest = assumption × freshness), and
  merging would break the manifest's own "no disagreeing rosters" rule. Columns: *tool · owner · scope · reads
  · writes · **credential location** · last reviewed · **how to disable***, with the last two called out as the
  load-bearing pair a stressed human reaches for. Teaching extends the **§1.3a** MCP-allowlist material (the
  allowlist decides *whether* a tool loads; the inventory records *what the loaded ones can do*) + a
  Quick-Checklist line. **No kit-self dogfood** — this repo runs no project-owned MCP tools (no `.mcp.json`);
  a worked-example row in the template serves instead. Feeds **U**'s revoke step (where the credential lives)
  and **R**'s action-risk gating (a `writes = Y` tool is a gate candidate).

### U. Incident runbook for agent mistakes *(new)*
Distinct from the wiki's *retrospective* incident pages (symptom → cause → fix, written after).
This is the *forward* procedure you run the moment an agent does something wrong in a live system:
contain it → revoke/rotate any credential involved → identify what was touched (files, records,
messages, external state) → undo or notify → then safeguard (add a regression check + a wiki incident
page). The kit is strong on *prevention*; this is the "when prevention fails" playbook. Agnostic:
the live system could be a personal server, an open-source project's CI, or a business's backend.
- **Build:** a short RUNBOOK section (or wiki page) with the ordered steps, kept where a stressed
  human can find it fast.
- **Built 2026-07-06.** Ships a tier-optional **root `RUNBOOK.md`** (a standalone file, not a wiki page — the
  wiki is itself tier-optional and buried; "a stressed human finds it fast" demands root visibility). The
  5-step forward spine: **contain → revoke/rotate → identify what was touched → undo or notify → safeguard**,
  with two handoffs — step 2 sends you to `TOOL_INVENTORY.md` (item T) for *where the credential lives*, and
  step 4 restores from the snapshot (item S) for non-git state; the final step hands off to the wiki's existing
  *retrospective* incident-page shape (which U stays distinct from — U is the live procedure, the wiki page is
  the after-the-fact analysis). **Self-contained** (grep-clean of `§`/`Principle`/`item-letter`/`the-kit`
  refs — the same discipline as `HARNESS_MANIFEST.md`): every cross-reference is to another *project-retained*
  file by filename, with graceful "if you keep one" degradation. Teaching placed with the **§1.3a** security
  material as the "when prevention fails" complement — **not** the §1.6 verifier family (a runbook isn't a
  verifier). Quick-Checklist line added. Together S + T + U are the kit's **recovery layer**.

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
- **Built 2026-07-06 (docs + template, "not a new machine" — the X-full/Y pattern).** Ships a **tier-optional
  root `HARNESS_MANIFEST.md`** template + teaching in kickoff **§1.6a** (the third sibling of the harness-self
  verifiers: metrics = ROI, log = history, manifest = *assumptions + freshness*) + a Quick-Checklist line +
  glossary move. **The spine, corrected in review:** the manifest was at risk of duplicating what already
  exists — so it deliberately tracks the **one axis nothing else does: what each part assumes × when last
  verified × the re-verify trigger**, grouped by shelf-life class — and *not* presence (that's
  `kit-conformance.sh`) or change-history (that's `HARNESS_LOG.md`). The template states that split in-line so
  the three verifiers can't drift into rosters that disagree (the same "two verifiers must not disagree" rule
  enforced in the §9.1 AGENTS.md fix). J is folded in as the trigger column. **Dogfooded:** the kit keeps its
  own filled instance at `wiki/harness-manifest.md` (parallel to `wiki/harness-log.md`), and the audit's
  committed-scaffolding comment now lists `HARNESS_MANIFEST.md` among the ships-at-output-name files that must
  stay out of the alternation. **No conformance/audit check this pass** (the artifact is tier-optional, so
  "absent" is legitimate → no mandated-presence check; staleness is per-project judgment, not cleanly
  greppable — a §9.3.1-style placeholder-token WARN is the only clean check and is left as a follow-up). **M:**
  W gives M its *mechanism* (a dated home for version-assumptions) but does **not** sweep the version facts
  already scattered across the docs — M stays open.

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
kit's first CI (`.github/workflows/selftest.yml`, ubuntu + macOS) — (details in §9.1 and `wiki/harness-log.md`). **Metrics inflation (§9.1 B) — ✅ closed 2026-07-06:** the audit-check count dropped 77 → 59 on
`claude-audit-base.sh` by stripping full-line comments before the grep, plus a new free eval-fixture metric
(details in §9.1 and `wiki/harness-log.md`). **`AGENTS.md` fallback (§9.1 O #4) — ✅ closed 2026-07-06:**
the kit verifiers resolve `CLAUDE.md` OR `AGENTS.md` before gating (merged as #13). **§9.2 security-template
gaps (all five) + §9.3 process gaps (both) — ✅ closed 2026-07-06:** verify-floor content check, machine-cred
denies + `mcp__*` in the project template, `templates/ci-audit.yml`, the docker-escalation `ask` guard, the
`HARNESS_LOG.md` version-stamp check, and `prompts/` gitignored (details in §9.2/§9.3 and `wiki/harness-log.md`).
**The full 2026-07-06 defect sweep (§9.1 + §9.2 + §9.3) is now closed.**

1. ✅ **Fowler fix + README citations** (Q, P) — done in README (2026-07-03); Q propagated across
   the rest of the kit (2026-07-06).
2. **Evals scaffold + harness-metrics script** (A, B) — the two to build first; A now includes the
   fixture schema + provenance rule, and B seeds the basic `HARNESS_LOG.md` companion.
3. **Action-risk tiers + name-the-reviewer** (R, V) — the highest-value cross-check newcomers;
   cheap, high-leverage, and both feed the conformance script.
4. **Dependency-vulnerability scan + safeguard-rot check** (G, H) — security + false-security hygiene.
5. ✅ **Adoption check + fan-out driver** (O) — done 2026-07-06; the biggest; makes the rest
   stick. Checks for R and V (and A + the floor); `scripts/kit-conformance.sh` + kickoff §1.6c.
6. Fold in the rest as the safety net pulls them in. Then the cross-repo layer: ✅ **X** (harness-log
   schema + vetted cross-repo learning) — done 2026-07-06; ✅ **Y** (kit-update proposals) — done
   2026-07-06 on X's version stamp. ✅ **W** (harness manifest — `HARNESS_MANIFEST.md` template +
   §1.6a teaching + kit-self instance) **and ✅ J** (post-upgrade re-verify, realized as the manifest's
   trigger + §1.4/README doctrine) — done 2026-07-06, motivated by this session's CC-2.1.201 finding.
   ✅ **M** (date-stamp version-specific facts + the re-verification habit) — done 2026-07-06 on W's
   dated-home mechanism: `CHEATSHEET.md` header + red-team stat + the README shelf-life mention
   (README/LESSONS were already dated). ✅ **E** (spec-as-source) — done 2026-07-06: `prd-template.md`
   `reconcile-code` anchor + living-doc note, the audit's freshness check generalized to any anchored root
   doc, and intent routed to the spec (kept distinct from the wiki's code-history). ✅ **K/L/N** (the last
   three internal-consistency fixes) — done 2026-07-06: CLAUDE.md-skeleton budget acknowledged (menu, not
   mandate); the "How we build here" digest named as the intended paste-exception; and the solo-on-`main`
   rule reconciled across Principle 4, Part 3.11, and the seeded digest (self-contained). **With M + K/L/N
   done, the entire K–N consistency cluster is closed.** ✅ **S/T/U** (the recovery layer) — done
   2026-07-06: **S** generalizes Principle 10 to all out-of-git state + a recovery owner (teaching-only);
   **T** ships `TOOL_INVENTORY.md` (what has access + how to disable it); **U** ships `RUNBOOK.md` (the
   forward when-prevention-fails procedure). The kit was prevention-heavy; this is its recovery complement.
   ✅ **C** (flight recorder) — done 2026-07-06 (teaching-only): the safety net's *second feed* — post-mortem
   bad/expensive *runs* (via the run record/transcript), not just fixed bugs, into a grep / `CLAUDE.md` line /
   wiki page / eval case; "flight recorder" term disambiguated from `HARNESS_LOG.md`.
   ✅ **The tail — D / I / F — done 2026-07-07 (all teaching-only, one combined change):** **D**
   (cross-project memory) is a graduation pointer closing §1.5b — *scale the **reconciled** wiki
   across projects, never the **unreconciled** memory store the skeleton forbids*; **I** (fuzzy-output
   baseline) is a sub-bullet under Principle 10 routing non-exact baselines to §1.6b's tolerance-band /
   rubric split (no runner change); **F** (untrusted-content rule) sharpened the existing §1.3a bullet —
   broadened the surface list (PDFs / CSVs / emails / screenshots / transcripts / any tool-MCP output)
   and added *the sandbox limits **damage**, not the **hijack***. **With the tail closed, every lettered
   ROADMAP item (A–Y) is now Built.**

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

**✅ Fixed 2026-07-06.** `kit-conformance.sh` now resolves the contract file *before* gating —
prefer `CLAUDE.md` (a real file **or** a symlink; `[ -f ]` follows symlinks, so the adoption
guide's symlink pattern keeps working), else fall back to `AGENTS.md`, else FAIL naming *both*.
`$CLAUDE_MD` inherits the resolution, so every downstream row (routing / budget / reviewer /
action-risk) runs against the resolved file for free. Proven on fixtures: AGENTS.md-only (the
repro) → exit 0 with routing+reviewer detected; both present → CLAUDE.md wins; symlink → resolves;
neither → FAIL/exit 1. **The sibling verifier was fixed the same way:** `claude-audit-base.sh` had
the identical hardcoding at `:284` (action-risk join) and `:651` (DOCUMENTATION presence) — both now
read a `CONTRACT_MD` resolved once at the top (CLAUDE.md-or-AGENTS.md), so the two kit verifiers stay
concordant. Proven on an AGENTS.md-only fixture: the audit's action-risk join and docs row both
resolve AGENTS.md (`action-risk gates wired`, `AGENTS.md present`).

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
**✅ Fixed 2026-07-06 — measured first, then proven to shrink.** Stripped full-line comments
(`grep -vE '^[[:space:]]*#'`) *before* the existing audit-check grep: measured against
`claude-audit-base.sh` the count drops **77 → 59** (−18, the entire comment-line contamination —
the "18 of 75" this entry cited, now 18 of 77 as the base audit has since grown), and the
remaining 59 spot-check to real `pass`/`warn`/`fail` call sites. Trailing-`#` comments on a code
line are deliberately **left in** (a naive strip corrupts a legitimate `grep '#foo'` arg — a rare
edge, documented in a one-line comment: honest growth gauge, not exact census). **Added** the
eval-fixture count as the third free metric (`find "$ROOT/evals" -name '*.eval.md' | wc -l`,
mirroring the base audit's own `n_evals`) — wired into the snapshot, trend-log line + header, and a
`delta`; degrades to a clean **skip** when `evals/` is absent (proven in the kit repo itself, which
ships `evals-template/`, not `evals/`). The trend read-back stays back-compatible: a prior log line
predating the field reads `eval_fixtures=n/a` and the `delta` guard rejects it — no crash, no
fabricated zero. Whole script runs exit 0 in place. Details in `wiki/harness-log.md`.

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
  **✅ Fixed 2026-07-06 — proven on fixtures.** `scripts/kit-conformance.sh`'s managed-floor row now reads the
  file when it's readable (macOS **and** `/etc/claude-code` paths): strict-JSON-loads it (a `//` comment → WARN
  "silently dropped", not a false pass), then confirms three critical keys present — `disableBypassPermissionsMode`,
  a machine-credential `Read(...)` deny, and `sandbox`. **PASS comes from reading keys, never from a file's
  absence**, so `SKIPPED ≠ PASS` holds: complete→PASS, missing-keys→WARN (names the gaps), unloadable→WARN,
  absent/unreadable→loud SKIP — all four proven via a new `CONFORMANCE_MANAGED_FILE` test seam (mirrors
  `AUDIT_SKIP_*`, so it's testable without root).
- **`templates/project.settings.json` ships weaker credential protection than the kit's own
  dogfooded settings.** The template's deny list covers only in-project paths with the comment
  "machine creds are already denied in the managed floor" (lines 28-31) — but the kit's own
  `.claude/settings.json` (lines 14-17) adds the same machine-credential denies
  (`~/.ssh/**`, `~/.aws/**`, `~/.npmrc`, `*.pem`, `*.token`) redundantly anyway, exactly the
  belt-and-suspenders duplication the guide argues for elsewhere. **Fix:** backport those lines
  into the template — two lines, materially shrinks the blast radius of the point above for anyone
  who never installs the managed floor.
  **✅ Fixed 2026-07-06.** `templates/project.settings.json`'s `deny` now carries `Read(~/.ssh/**)`,
  `Read(~/.aws/**)`, `Read(~/.npmrc)`, `Read(**/*.pem)`, `Read(**/*.token)` — the same machine-credential reads
  the kit's own dogfooded settings deny. Strict-JSON validity re-proven (`json.load`) after the edit.
- **No template gates MCP servers or `WebFetch` domains by default**, despite three separate kit
  docs correctly naming MCP and the native web tools as unsandboxed, un-audited surfaces
  equivalent in risk to Bash (`claude-project-kickoff.md:502-506`). **Fix:** a repo-neutral
  "deny `mcp__*` by default, allowlist per trusted server" line in `templates/project.settings.json`.
  **✅ Fixed 2026-07-06 — syntax verified against the live permissions doc.** `templates/project.settings.json`
  `deny` now includes `mcp__*` (confirmed the *exact* documented "denies every MCP tool" form at
  code.claude.com/docs/en/permissions — not guessed). The re-enable + web mechanics are taught in
  `templates/README.md`, and the teaching is **mechanically correct**: a `deny` is absolute (outranks `allow` at
  every scope, no exceptions), so a server is re-enabled by *removing* the deny, **not** by adding an allow;
  `WebFetch` is gated by domain-**allowlist** (`WebFetch(domain:…)`), since a bare `WebFetch` deny removes the
  tool and can't carry per-domain exceptions — with managed `sandbox.network.allowManagedDomainsOnly` named as
  the hard web lock.
- **No CI workflow template**, despite `claude-audit-base.sh`'s own comment (lines 304-307) arguing
  CI enforcement of the audit is strictly superior to the client-side pre-commit hook the kit *does*
  ship wiring for. **Fix:** a minimal `.github/workflows/audit.yml`-equivalent starter, least-
  privilege token + SHA-pinned actions per the kit's own §1.3b guidance.
  **✅ Fixed 2026-07-06 — YAML-validated.** New `templates/ci-audit.yml` (copy → `.github/workflows/audit.yml`)
  runs `scripts/audit.sh` on push/PR. `permissions: contents: read`; `actions/checkout` pinned to full SHA
  `34e114876b0b11c390a56381ad16ebd13914f8d5` (v4.3.1, dereferenced via `gh api` — not trusted from a prose
  summary, per Lesson 7). Gates on `RESULT: FAIL` only (WARNs surfaced, not fatal — a lean adopter isn't red on
  day one; documented one-line flip to strict), and treats a crashed audit (no RESULT line) as failure.
  Shipped as a *template*, not placed in the kit's own `.github/workflows/` (which has no `scripts/audit.sh`).
- **`managed-settings.template.json`'s `docker *` sandbox exclusion has no companion guard against
  privilege-escalating flags** — a `docker run --privileged` or a docker-socket bind-mount is a
  well-known one-command host-root escape, and Anthropic's own sandboxing docs flag this exact risk.
  **Fix:** an `ask` rule on `docker run --privileged*` / `-v /var/run/docker.sock*` alongside the
  existing exclusion.
  **✅ Fixed 2026-07-06.** `templates/managed-settings.template.json` `ask` now covers `docker run --privileged`
  (leading and mid-position forms) and docker-socket mounts (`-v` / `--volume` / `--mount` of
  `/var/run/docker.sock`). Framed honestly in `templates/README.md` as a **best-effort backstop, not a boundary**
  — `docker *` is in `excludedCommands` (runs unsandboxed), so the `ask` is the only gate and Bash arg-matching
  is evadable; the real boundary is not running untrusted `docker`. Strict-JSON re-validated after the edit.

### 9.3 Process / hygiene gaps

- **`HARNESS_LOG.md`'s placeholder anchor (`<YYYY-MM-DD>`, `<kit-version>`, `<commit-sha>`) has no
  enforcement or reminder to ever get filled in** — and both `scripts/kit-conformance.sh` and
  `claude-audit-base.sh` explicitly, by documented design, exclude `HARNESS_LOG.md` from their
  rosters (audit lines 336, 351: "in NEITHER clause BY DESIGN"). Item **Y** (built 2026-07-06)
  depends entirely on that stamp being real; left as a placeholder — a plausible outcome for an
  unenforced TODO — **Y** silently has nothing to diff against and nothing in the kit would ever
  flag it. **Fix:** a one-line check (in the audit or conformance script) that WARNs if the anchor
  entry's header still contains literal `<` characters.
  **✅ Fixed 2026-07-06 — proven on a *representative* fixture.** `claude-audit-base.sh`'s DOCUMENTATION section
  WARNs when a project's `HARNESS_LOG.md` still carries an unfilled stamp. It keys on **`<kit-version>` /
  `<commit-sha>` only** — deliberately *not* `<YYYY-MM-DD>`, which also appears in the shipped "copy me for your
  next entry" comment block the template tells projects to keep; matching the date token would false-WARN on
  every compliant project (a first-pass version did — caught in review, fixture B had been an unrepresentative
  hand-written file). Filled → PASS; absent → optional `·`. A *new roster row*, orthogonal to the GIT-HYGIENE
  "don't commit sources" clause the file is excluded from. Proven against the **actual shipped template**: verbatim
  (unfilled stamp + copy-block) → WARN; stamp filled with the copy-block *retained* → PASS; absent → `·`.
- **The `prompts/` directory (the build specs behind items O/R/V/X) is untracked, unreferenced,
  and already stale.** `git status` shows it untracked; README/ROADMAP/glossary/wiki have zero
  references to `prompts/` anywhere; two of its files (`build-R`, `build-V`, both dated
  2026-07-04) open with the pre-rename path `claude-harness-kit`, while the later files
  (`build-O`, `build-X`, both 2026-07-06) correctly say `claude-kickoff-kit` — the repo was renamed
  between the two dates and the earlier prompts were never updated. The directory has no rot-check
  analogous to item **H**, applied to itself. **Fix:** either track it with a short index +
  the same anchor-check discipline as **H**, or fold each prompt's durable content into this
  ROADMAP's item write-ups and delete the directory — undecided; the maintainer's call.
  **✅ Resolved 2026-07-06 — gitignored (a third, non-destructive option).** `prompts/` is now in `.gitignore`
  as **local maintainer build scaffolding**: one-time *sources*, not shipped artifacts, kept on disk but out of
  the repo — consistent with the kit's own "outputs persist, sources don't" rule (the `claude-audit-base.sh`
  GIT-HYGIENE clause that WARNs when kit sources are committed). This removes the untracked-noise + no-rot-check
  problem without deleting files the kit didn't author (each item's durable content already lives in this
  ROADMAP's write-ups). **Reversible maintainer call:** delete outright, or track-with-index + item-H anchor
  discipline, remain available if preferred.

---

## 10. Next-horizon backlog — candidates beyond A–Y (2026-07-07)

**What this is.** With the A–Y tail closed (§8) and the §9 defect sweep closed, the original
Fable review is fully built. This section opens the *next* backlog — candidate items derived
**only from the frontier themes already stated in §4**, so no new external claim is introduced
here that would need live-URL verification before it could ship (Lesson 7); each candidate points
back at §4's already-sourced framing. These are **proposals, not built** — the same status the
A–Y items had at the top of this doc — recorded so the forward direction isn't lost. Same
project-agnostic constraint as everything above (§2's steer): never assume a business, a team, or
even a codebase where the theme generalizes past one. Lettering continues the sequence (Z, AA, AB);
"if you do only one, **Z**" — it has the clearest near-term leverage and builds on shipped items.

| # | Candidate | Impact | Type | Status |
|---|---|---|---|---|
| **Z** | **Agent-fleet economics** — model routing + cost-governed orchestration | High | Frontier/Unique | *proposed* |
| **AA** | **Non-code companion track** — generalize the harness past code (humble pointer) | Medium | Frontier | *proposed* |
| **AB** | **Cross-tool portability watch** (`AGENTS.md` / AAF) — a *don't-build-yet* watch-item | Lower | Hygiene | *proposed* |

### Z. Agent-fleet economics — model routing + cost-governed orchestration *(new)*
§4 names the shift from single agent → **orchestrated fleets governed by economics**
(cost-per-merged-change, model routing). The kit already *measures* the cost (**B**'s scorecard —
tokens/$ per merged change) and *captures* the pathological runs (**C** — the expensive-run feed),
but it has no **directive** layer for the two economic decisions a fleet forces: **(1) route by
model tier** — a cheap/fast model for mechanical stages (mass edits, greps, format passes), a
strong model reserved for judgment and verification — and **(2) cap the fan-out by budget**, tied
to the scorecard, so an orchestration can't quietly cost 20× (the verified >20× long-running-app
figure in **B** is the cautionary number). Part 3's fan-out playbook has the *mechanics* of
spawning subagents but not the *when / which model / how much* governance. **Build (humble):** a
short routing heuristic + a budget-cap pattern in the guide (and, if it earns it, a scorecard
column for cost-per-stage), **not** a scheduler or an auto-router — name the decision, wire the cap
deterministically where money is at stake (the **R** action-risk posture applied to spend). Builds
directly on **B** + **C**; the frontier beat is turning "we measure cost" into "we *govern* it."

### AA. Non-code companion track — generalize the harness past code *(new)*
§4 states it plainly: the load-bearing ideas — **directives/verifiers, verification, provenance,
action-risk gating** — apply to *any* AI-assisted knowledge or process work (research, writing,
analysis, ops), and the kit should **stay code-first while framing the principles so they don't
assume a codebase**. This is the biggest *new-territory* candidate and the one the standing steer
(grow the kit into new ground, not just polish) points at — but it must land as a **pointer, like
D**, not a second kit. **Build (humble):** a short companion note mapping each principle to its
non-code form — the **audit** → a checkable rubric over the deliverable; the **wiki** → the same
reconciled knowledge store (already agnostic); **evals** → the fixture schema (**A** already says
"incl. non-code workflows"); the **provenance rule** → the citation standard for any factual claim
(already the evals' rule). A working instance already lives *in this repo* to point at — the
`deep-research` skill (fan-out → fetch → adversarially verify → cite) is the harness pattern applied
to research, not code. **Risk to manage:** scope creep. The deliverable is a *mapping note* that
proves the principles travel, not a parallel guide — the moment it starts assuming a non-code
domain's specifics, it's over-built.

### AB. Cross-tool portability watch (`AGENTS.md` / AAF) — a watch-item, not a build *(new)*
§4 flags `AGENTS.md` as a now-real cross-tool convention (Linux Foundation **Agentic AI
Foundation**; 20+ tools; nearest-file precedence) **and** cautions: *don't build multi-runtime
portability machinery prematurely for a single-tool project.* The kit already treats `AGENTS.md`
as a filename alias and both verifiers resolve `CLAUDE.md`-or-`AGENTS.md` (§9.1 O#4). So this is
deliberately recorded as a **standing watch-item, not a build** — the roadmap documenting the
*decision to wait*, which is itself a durable output (it stops a future session from
speculatively building portability scaffolding). **Trigger to promote from watch → build:** a
project that *actually* runs two agent runtimes over the same repo, not before. Until then: track
the standard's maturation, keep the alias handling correct, ship nothing. (This is the **J/W**
shelf-life discipline — a *depreciating*-class assumption with a named re-check trigger — applied
to an external standard instead of a Claude Code version.)

**Not promoted to candidates (folded into §4 as field observations, not buildable items):** the
*hardest challenge* — reliably evaluating non-deterministic agents — and *long-horizon coherence +
agent memory* are the meta-problems **A**/**I** already engage as far as a project-agnostic kit
honestly can; they're benchmarks to *watch* (METR's time-horizon metric, SWE-Bench Pro, SWE-EVO,
LongCodeBench), not artifacts to seed. Naming them as non-items is deliberate — it records that the
kit isn't going to pretend to solve the field's open problem, only to track it.

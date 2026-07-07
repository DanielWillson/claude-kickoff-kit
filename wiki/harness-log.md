# Harness log — the kit's own harness change journal

> **Where this lives, and why here.** This is the Claude Harness Kit's *own* instance of the
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
Harness Kit. One entry per harness change.

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

## 2026-07-07 — Non-code companion track (item AA): a README mapping of principles that already travel

- **Change.** Built item **AA** (second §10 backlog item) — and, like **Z** the turn before, building it
  reframed it. AA is **not** "the biggest new territory"; it is *collect + map + scope-guard principles the
  kit had already generalized*. Realized as a new README section, **`The principles travel past code`**,
  placed by the durability section (*"What scales with the model"*) — philosophy altitude, front-door
  discoverability. It: (1) opens by naming the kit **code-first on purpose**, then points at the four
  generalizations already shipped — evals *"incl. non-code workflows"* (**A**), the domain-agnostic wiki,
  **§1.3c**'s *"generalized beyond code edits"* action-risk (**R**), and the provenance rule that already
  *is* the citation standard; (2) a **mapping table** (code idea → non-code form), several rows honestly
  marked *Unchanged* because they already travel — the honest signal that most of this pre-existed; (3) the
  research-harness **pattern** (fan out → fetch → adversarially verify → cite) as the worked shape; (4) a
  hard **"know where to stop"** guard — a mapping that proves the principles travel, *not* a guide to doing
  research/writing/ops; agnostic per §2.
- **Rationale (the bet).** §4 says the harness ideas apply past code but the kit should stay code-first;
  the risk was building a *parallel guide*. The bet: a **one-section mapping that cross-references the
  existing generalizations** (not a `beyond-code.md` file) proves the point without inviting the domain
  specifics a near-empty companion file would beg to be filled with. Same anti-bloat call as Z's §1.6a
  paragraph — the discipline *is* the deliverable.
- **What it replaced.** Nothing removed. **Corrected** the §10 AA stub on two counts, both surfaced by
  actually checking: (a) the `deep-research` skill does **not** live in this repo (no such file — it's a
  session-available skill, not a kit artifact), so the README names the *pattern* generically, no
  specific-skill dependency; (b) "biggest new-territory candidate" was overstated — it's a Z-species map of
  what already travels. The §10 entry/row and the Z-correction intro line were reconciled: with AA built,
  §10's **buildable** candidates are closed (AB is a deliberate don't-build-yet watch-item).
- **Shelf-life/risk class.** **Permanent** — it draws its force from a property of the world (the unit is
  *model + harness*, which is independent of whether the deliverable is code), and it's a mapping, not a
  model-dependent how-to. Low blast-radius: one README section, no guide/script/template/settings touched.
- **Related ROADMAP item.** **AA** (§10). Cross-references **A** (evals/non-code), **R**/§1.3c
  (action-risk beyond code), the wiki, and the provenance rule — the generalizations it *collects* rather
  than invents. Sibling of **D** (both new-territory ideas that landed as a pointer, no file).
- **Commit.** `feat/AA-noncode-track` (this change) + this log entry. *(Stacked on `feat/Z-fleet-economics`,
  which was still open at build time — both touch §10.)*
- **Code worth pointing at.**
  - `README.md` **§ The principles travel past code** — note it leads by *disclaiming* novelty
    ("several parts already say so out loud") and that several table rows read *Unchanged* — the honest
    frame for a collect-what-exists item, same as Z's "the levers already ship, scattered."
  - The four existing generalizations it cites — `evals-template/` + §1.6b (non-code workflows), §1.3c
    (action-risk beyond code), the wiki guide, and the §1.6b provenance rule — were **left untouched**;
    AA points at them, it does not re-teach them.
- **Signal to watch.** Does anyone actually run the kit's principles on a non-code deliverable and report
  back that the mapping held — or does the section stay an unexercised claim? And watch the boundary: if a
  future edit starts adding "how to do research/writing/ops" under this heading, that's the scope-creep AA
  named — cut it back to the mapping. If the non-code use never materializes across real adopters, the
  honest read is "the kit's audience is code, keep the section short," not "expand it."
- **Retrospect.** *(open — revisit when a project first runs the harness on a non-code deliverable, or if
  the section starts drifting toward a parallel guide.)*

---

## 2026-07-07 — Agent-fleet economics (item Z): the cost-governance gauge — and a corrected premise

- **Change.** Built item **Z** (first of the §10 next-horizon backlog) — but building it *disproved its
  own §10 stub*. The stub claimed Part 3 lacked the "which-model / how-much" governance; in fact **Part 3
  #13** already carries the model-tiering *judgment* (*capability is per-task, not per-reputation*), **Part
  3 #10** already carries the budget levers (and states the baseline harness has **no per-run token
  primitive**), **B** the cost measure, **R** the spend gate, **C** the expensive-run post-mortem. Z was
  **~80% already shipped.** So the faithful build was the *small genuine delta*, not a manufactured Part 3
  #15:
  - **`claude-project-kickoff.md` §1.6a** — a new paragraph naming **tokens/$ per merged change** as the
    *economics gauge* that closes a **governance loop** over the four existing levers (#13 route · #10 cap
    · R gate · C post-mortem): watch it on the scorecard's slow cadence and let it *drive* the next
    routing / fan-out-width choice. It **references** #13/#10/B/R/C rather than re-teaching them.
  - **`scripts/harness-metrics.sh`** — added a `manual "cost per merged change (tokens/$)"` human-note stub
    (the script stubbed *effort per merged change* = human labor, but never the compute *spend*). Human
    note (not repo-derivable → never a fabricated zero); **not** in the trend tab-line.
- **Rationale (the bet).** A fanned-out run's cost is the field's stated governor (§4: "orchestrated
  fleets governed by economics"), but the kit *measured* cost without *naming the number that governs by
  it*. The bet: one gauge, tying four scattered habits into a loop, is worth more than the four alone —
  and worth **more than a fat new item** that would have re-stated them. The anti-bloat call *is* the bet.
- **What it replaced.** Nothing removed. It **corrected** a wrong claim — the §10 Z stub's "Part 3 has the
  mechanics but not the governance" — which had been written without checking Part 3 #13/#10. The §10
  entry, its table row, and the "if you do only one, Z" line were all reconciled to the honest scope (Z
  ~80% pre-existing; **AA** is now the genuine next-territory build).
- **Shelf-life/risk class.** **Appreciating** — worth more as orchestration deepens (a solo one-agent
  project has no fleet to govern; the gauge earns its keep only as fan-out grows). Low blast-radius: one
  paragraph + one human-note stub, no computed metric, no settings touched.
- **Related ROADMAP item.** **Z** (§10). Consolidates **B** (scorecard), **C** (expensive-run feed), **R**
  (spend gate), and Part 3 **#13** (model tiering) + **#10** (budget window) — references all five, adds
  the gauge that unifies them.
- **Commit.** `feat/Z-fleet-economics` (this change) + this log entry.
- **Code worth pointing at.**
  - `claude-project-kickoff.md` **§1.6a** — the economics-gauge paragraph; note it leads by *disclaiming*
    novelty ("the levers already ship, scattered") and contributes only the closing gauge — the honest
    frame for a mostly-pre-existing item.
  - `scripts/harness-metrics.sh` (human-note block) — the new stub sits beside `effort per merged change`
    with a comment drawing the labor-vs-spend line, so the two aren't later merged by mistake.
  - Part 3 **#13** / **#10** were **left untouched** — editing their content would break no numbering, but
    they already say the right thing; the loop lives in §1.6a next to the metric, not in the playbook.
- **Signal to watch.** Does any project ever record a real tokens/$ figure and actually *re-route* off it,
  or does the stub stay an unfilled human note (like most of the §1.6a manual block so far)? If it's never
  filled across several projects, the honest read is "the gauge is premature for current adopters" — demote
  it to a one-line mention, don't add machinery. Also watch whether a future harness exposes a real per-run
  budget primitive (Part 3 #10's gap) — if so, the cap lever graduates from design-discipline to a wired
  control and this entry's "no per-run primitive" note dates.
- **Retrospect.** *(open — revisit when a project first governs a real fan-out by cost, or when a per-run
  budget primitive ships in the harness.)*

---

## 2026-07-07 — The tail closes: cross-project memory (D) + fuzzy baseline (I) + untrusted-content rule (F)

- **Change.** Built the three remaining ROADMAP tail items, all **teaching-only**, in one change (the
  S/T/U precedent — one combined entry reads cleaner than three thin ones).
  - **D (cross-project memory)** — a **graduation pointer** closing `claude-project-kickoff.md` **§1.5b**
    (the wiki section), mirroring C's Langfuse graduation note. Trigger: when per-project Markdown stops
    scaling *across many projects* (Yegge's "605 rotting plan files"), graduate to a **queryable knowledge
    service** — a small DB or an MCP over the knowledge base — that **keeps the wiki's reconcile-against-
    truth property** (trust banners / last-verified). No build, names no product.
  - **I (baseline for fuzzy output)** — a **sub-bullet under Principle 10's "pin a baseline" bullet**:
    exact-reproduce is the *golden* case; when the pinned output is fuzzy (an LLM/agent step, prose, a
    ranking), route to §1.6b's **tolerance-band / multi-run / rubric** approach instead of `==`. Reciprocal
    cross-link wired Principle 10 ↔ §1.6b. **No runner change** — `claude-eval-base.sh`'s `rubric` arm
    already grades fuzzy output.
  - **F (untrusted-content rule)** — **sharpened the existing §1.3a bullet** (not a new one): broadened
    the surface list to **PDFs / CSVs / emails / screenshots / transcripts / any tool-MCP output**, stated
    the one-line rule (*fetched or tool-returned content is data, not instruction*), and added the division
    of labor the glossary F-row promised — ***the sandbox limits damage, not the hijack***. Tagged
    `(item F)` for grepability.
- **Rationale (the bet).** These three were the last open items; each is a *pointer or a one-line
  sharpening*, not machinery, exactly as the ROADMAP scoped them (D/I "least-solved / lower, cousin of A";
  F "no build"). The bet is that **naming a trigger and a shape** — without building speculative machinery
  — is the honest move for frontier-but-unsolved territory (D) and for a rule the architecture already
  enforces (F). Building a cross-project knowledge service or a fuzzy-baseline runner now would be the
  "guard you don't need is complexity you do" mistake Principle 10 warns against.
- **What it replaced.** Nothing removed. D **reconciled** an apparent contradiction rather than adding one:
  the CLAUDE.md skeleton (§1.5) forbids project facts in cross-project/global memory *because it's
  unreconciled and rots*; D names that distinguishing property head-on and graduates the **reconciled**
  store (the wiki), never the unreconciled one (memory) — heading off the self-contradiction class the K–N
  sweep and the flight-recorder collision existed to kill, rather than shipping it. F folded a second
  untrusted-content bullet into the first instead of duplicating it.
- **Shelf-life/risk class.** **Permanent** — all three draw their force from properties of the world:
  unreconciled memory rots (D), fuzzy output has no single right value (I), and content is data not
  instruction / a sandbox contains damage but not redirection (F). None is model-version-dependent, so
  none re-audits at a model upgrade. Low blast-radius: pure teaching, no script or settings touched.
- **Related ROADMAP item.** **D**, **I**, **F** — the §8 tail. **With these, every lettered ROADMAP item
  (A–Y) is Built** (the §1 table's remaining un-marked-but-built rows were completed to match). I is the
  cousin of **A** (§1.6b evals) and ties to **Principle 10**; D graduates the **§1.5b** wiki pattern; F
  sharpens the **§1.3a** containment doctrine.
- **Commit.** `feat/DIF-tail-items` (this change) + this log entry.
- **Code worth pointing at.**
  - `claude-project-kickoff.md` **§1.5b** — the D graduation paragraph; note it leads with the
    *reconcile-vs-unreconciled* distinction, not the location, because that distinction is the whole
    non-contradiction.
  - `claude-project-kickoff.md` **Principle 10** (first bullet) — the I sub-bullet; and **§1.6b**'s closing
    caveat carries the reciprocal link back.
  - `claude-project-kickoff.md` **§1.3a** — the F bullet, now tagged `(item F)`.
- **Signal to watch.** Does any adopted project ever *reach* D's trigger (many-project scale) — and if so,
  does the reconcile-property framing actually stop it from reaching for global memory? Does I's fuzzy-
  baseline pointer get used, or do projects keep pinning `==` on fuzzy output and writing flaky tests? Does
  the broadened F surface list catch a real injection attempt a narrower list would have missed? If D's
  trigger is never reached by any real project, it was cheap insurance, not wasted — but note it as "field
  didn't need it yet," not "wrong."
- **Retrospect.** *(open — revisit when a project first hits many-project scale, or at the next maintenance
  moment.)*

---

## 2026-07-06 — Flight recorder (C): the safety net's second feed

- **Change.** Built item **C** (teaching-only, like S — no new file). C **reframes the safety-net doctrine
  that already lives in §1.6** rather than adding a verifier: its existing bullets grow the net from **fixed
  code bugs (feed one)**; C adds **feed two — bad or *expensive* runs** (looped an hour, wandered, produced
  slop, cost 5×, with no code bug at all). Two moves: keep the run legible (retain the **run record** — the
  session transcript — + app logs the agent can read) and post-mortem the bad/expensive ones into an
  artifact that feeds the *whole* net: a regression grep, a `CLAUDE.md` line, a wiki incident page, or —
  sharpest, for a *judgment* failure — a **behavioral eval case** (item A). A repo-side two-source note went
  into the audit's `REGRESSION GUARDS` comment; a Quick-Checklist line; a graduation pointer
  (Langfuse/LangSmith/OTel GenAI traces — a maturity trigger, not a build, same humility as D).
- **Rationale (the bet).** The safety net had one input — fixed code bugs. But the most expensive agent
  failures often aren't bugs (a run that looped, took a bad path, or ran up a bill), and that signal
  evaporated when the session closed. C makes those runs legible and turns them into checks — the same
  learning loop, aimed at *runs* instead of *code*. The frontier beat: a bad *judgment* run becomes a
  behavioral eval, landing C's output in the evals artifact, not just a grep.
- **Terminology collision (resolved, not deepened).** "Flight recorder" was already entrenched for
  `HARNESS_LOG.md` (the *harness-change* journal — see this file's own header). Shipping a second "flight
  recorder" for agent runs would have re-created the exact self-contradiction class this session kept closing.
  Fix: the **item keeps the "Flight recorder" label** (ROADMAP/glossary), but the **kickoff prose leads with
  "run record"** (raw observation of what the agent *did*) and disambiguates at *both* entries — the
  HARNESS_LOG line now says "flight recorder **of harness changes**… distinct from a run record (item C)."
- **C vs U — kept distinct.** They share an input (the transcript) and outputs (a wiki incident page, a
  guard), so precision mattered: **U (`RUNBOOK.md`) is the *acute* live-incident drill; C is the *routine*
  learn-from-any-bad-run habit** (most bad runs aren't emergencies). C reuses the wiki incident-page shape —
  ships no post-mortem template.
- **Doctrine-twin sweep (the recurring blind spot, guarded).** C reframes "the safety net grows from fixed
  bugs" into two feeds — the same class as E's routing sweep. Swept `safety net`/`every bug`/`fixed bug
  leaves` across the kit and added a one-clause "…or a post-mortemed bad run" where a statement implied
  bugs-only: the glossary *safeguard* definition, the README's "strand per fix," and Principle 2's bug-trail.
- **What it replaced.** Net-additive doctrine. The §1.6 safety-net bullets are now explicitly *feed one*, with
  C as *feed two* (not replaced — reframed).
- **Shelf-life/risk class.** **Appreciating** — as agents run longer-horizon and more autonomously, the value
  of turning bad/expensive runs into checks grows. Docs-only; zero blast radius.
- **Related ROADMAP item.** **C**. Frontier partner of **U** (the transcript is what U reads mid-incident);
  feeds **A** (a bad judgment run → an eval); the *expensive* half ties to **B**'s scorecard (tokens/$).
- **Commit.** *(uncommitted at time of writing — on branch `feat/C-flight-recorder`; stamp on merge.)*
- **Signal to watch.** A project keeping transcripts but never post-morteming them → the second feed is
  "available but unused" (item D's rotting-artifact failure mode); the habit, not the record, is the value.
- **Retrospect.** *(pending — revisit once a project has turned a real bad run into a check.)*

---

## 2026-07-06 — The recovery layer: non-git rollback (S) + tool inventory (T) + incident runbook (U)

- **Change.** Built S, T, U together as one **recovery layer** — the kit's answer to "what happens when
  prevention fails," which it was almost silent on. **S** (teaching-only): a new Principle 10 bullet generalizing
  its migration case to *all* out-of-git state (DB, hosted config, deploy, external backend), adding the
  kit-missing concept of a **recovery owner** — the triad is *snapshot + documented way back + recovery owner*,
  gated to the existing Intake Q5/Q7 + §1.3a Hardened signals. **T**: a tier-optional root **`TOOL_INVENTORY.md`**
  (scope · reads · writes · credential-location · how-to-disable per tool). **U**: a tier-optional root
  **`RUNBOOK.md`** (contain → revoke/rotate → identify → undo/notify → safeguard). Both artifacts teach from
  **§1.3a** (the security/recovery material), not the §1.6 verifier family.
- **Rationale (the bet).** The kit is overwhelmingly *prevention* (deny floors, audit, evals, conformance,
  freshness). Recovery was its thinnest seam. The three interlock — U's revoke step reads T's credential-location
  column; U's undo step restores from S's snapshot — so building them together yields a runbook that points at
  real artifacts rather than three docs each referencing two that don't exist. Bet: a small, tier-optional
  recovery layer closes the kit's biggest *categorical* gap at low marginal cost.
- **Research method.** Mapped the three slot-in points with **three parallel Sonnet subagents** (one per item,
  read-only), then integrated as a single writer — the kit's own fan-out pattern (item O) turned on itself. All
  three independently converged on the artifact shapes below.
- **Three design calls.** (1) **S needs no file** — it's a ritual-at-a-moment, not a registry; a Principle 10
  bullet + a checklist line, no proliferation. (2) **T and U are separate files, not one `RECOVERY.md`** — they
  fire on *orthogonal* triggers (a library using an MCP server wants T, not U; a deployed app with no tools wants
  U, not T), so the marginal cost per project is 0-or-1, not 2; and their read-modes differ (T = a maintained
  table read at audit; U = a terse procedure read under stress). (3) **T is its own file, not a manifest section**
  — different axis (access-scope vs assumption×freshness); merging would break the manifest's "no disagreeing
  rosters" rule.
- **Self-containment (the recurring trap, guarded).** Both `TOOL_INVENTORY.md` and `RUNBOOK.md` are
  project-retained, so both are **grep-clean of `§`/`Principle`/`item-letter`/actionable-`the-kit` refs** (only
  the provenance banner names the kit); every cross-reference is to another *project-retained* file by filename,
  with "if you keep one" graceful degradation. Same lesson as the `HARNESS_MANIFEST.md` scrub.
- **Enumeration sweep — caught a latent W miss.** Adding root files re-triggered the "enumerate the outputs"
  consistency class (cf. E's routing sweep). Found that **`HARNESS_MANIFEST.md` (item W) had never been added to
  the canonical output lists** — the kickoff "what persists" list (`:1211`), the audit's scaffolding comment
  (`:370`), and the README roster. Fixed all three lists to include the manifest *and* the two new files, and
  added `TOOL_INVENTORY.md`/`RUNBOOK.md` to the audit's "ships-at-output-name, NEITHER clause BY DESIGN" note.
- **What it replaced.** Net-new recovery layer. Principle 10's migration bullet is now framed as one instance of
  the general out-of-git-state rule (not replaced — subsumed).
- **Shelf-life/risk class.** **Permanent** — recovery discipline (snapshot before change, know what has access,
  have a procedure) is not model-dependent. Low blast radius: two tier-optional templates + docs; no executable
  path added.
- **Related ROADMAP item.** **S**, **T**, **U** (the recovery layer). **No conformance/audit presence-check**
  for T or U — consciously, matching W's tier-optional precedent (absent is legitimate). Feeds **R** (T's
  writes-column is action-risk raw material) and the wiki's retrospective incident pages (U's step-5 handoff).
- **Commit.** *(uncommitted at time of writing — on branch `feat/STU-recovery-layer`; stamp on merge.)*
- **Signal to watch.** (1) A project keeping `RUNBOOK.md` but no `TOOL_INVENTORY.md`, hitting step 2 with no
  credential map → the "if you keep one" degradation is doing its job, or the pairing needs a stronger nudge. (2)
  A tool inventory going stale (rows for tools long disconnected) → same freshness risk as any registry; a
  future placeholder/last-reviewed check (deferred, like the manifest's) may be worth it.
- **Retrospect.** *(pending — revisit after a project actually runs the runbook in a real incident.)*

---

## 2026-07-06 — Internal-consistency fixes K / L / N (the K–N cluster closes)

- **Change.** Closed the last three **internal-consistency fixes** (docs-only), completing the K–N cluster
  (M shipped earlier today). **K:** the §1.5 line-budget teaching now acknowledges the starter `CLAUDE.md`
  skeleton is *deliberately near the ~200-line ceiling — a menu, not a mandate* — and to delete the sections
  a project doesn't need, rather than trimming the skeleton itself (subjective, value-losing). **L:** the
  scaffolding rule's existing carve-out ("principles internalized as a lean digest… not the full guide
  pasted in") was *strengthened with a pointer* — the §1.5 "How we build here" block **is** that digest, the
  one intended exception to "never paste the kit"; the kit's *prose* is what you never paste. **N:** a
  reciprocal Principle 4 ↔ Part 3.11 cross-reference (solo-on-`main` is *attended*-only; an unattended
  committer gets its own worktree), **plus** the sharper twin it surfaced — the seeded `CLAUDE.md` digest
  bullet flatly said "never commit straight to `main`," contradicting Principle 4; softened to "branch first
  once anyone else shares the repo — committing to `main` solo is fine."
- **Rationale (the bet).** These are the conflicting-docs tax (Principle 2) turned on the kit itself: two
  places stating the same rule differently is exactly what makes an agent burn time adjudicating, or follow
  the wrong one. Cheap to fix, and load-bearing precisely because the kit's whole pitch is "don't contradict
  yourself."
- **The self-containment trap (caught in review, pre-commit).** Two of the N edits touch the **"How we build
  here" digest — a *project-retained* artifact** (it ships into the project's `CLAUDE.md`). So they had to be
  self-contained: the softened main-branch bullet carries **no `Principle 4`/`§` reference** that would dangle
  once the kit steps away — the same lesson as the `HARNESS_MANIFEST.md` template scrub. The guide-side
  cross-references (Principle 4 ↔ Part 3.11) keep their refs, correctly, because both live in the guide.
- **What it replaced.** A flat "never commit straight to `main`" digest bullet (→ nuanced, solo-aware); an
  unqualified "solo-on-`main` is fine" (→ carved out for unattended runs, both directions).
- **Shelf-life/risk class.** **Permanent** — internal consistency is not a model-dependent property. Zero
  blast radius (docs only).
- **Related ROADMAP item.** **K**, **L**, **N** (M closed earlier). Verification here was **not** bash-n/
  eval-runner (those can't see prose): the checks that mattered were a grep proving the edited digest bullet is
  self-contained (no `§`/`Principle`/kit refs), and a kit-wide sweep for other flat "never to `main`"
  statements (came back clean — only the nuanced Principle 4 statement remains).
- **Commit.** *(uncommitted at time of writing — on branch `feat/KLN-consistency-fixes`; stamp on merge.)*
- **Signal to watch.** A future edit re-introducing a flat "never to `main`" in one place but not the other →
  the twin-statement problem recurring; the sweep grep is the guard to re-run.
- **Retrospect.** *(pending.)*

---

## 2026-07-06 — Spec-as-source: the spec becomes a living, reconciled doc (item E)

- **Change.** Built ROADMAP item **E** — the spec/PRD is now a *living* doc, not fill-once. Three moves plus
  the piece that makes them bite: (1) `prd-template.md` gains the `<!-- reconcile-code: … -->` freshness anchor
  (mirroring `readme-template.md`) + a living-doc banner (source of truth for *intended behavior*; update in the
  **same commit** as any deliberate behavior change; keep at repo **root**). (2) The audit's README-only
  freshness block was **generalized** to loop over **any root-level doc carrying the anchor** — the anchor is
  the opt-in, so the spec (any filename) is checked exactly like the README. (3) Routing updated at all four
  sites to add *intended behavior → the spec/PRD*.
- **Rationale (the bet).** A spec written once and abandoned silently diverges from what the system actually
  does — the exact rot the kit fights everywhere else. Giving the spec the README's reconcile-against-code
  mechanism turns "is the spec still true?" into a check the audit runs, not a thing you hope someone
  remembers. The bet: the *anchor as opt-in* generalizes cleanly — one mechanism now serves README, spec, and
  any future doc, with zero new machinery.
- **Two design calls that carried the item.** (a) **Root-only glob, not recursive** — a `find -maxdepth` scan
  would drag in `node_modules/**/README.md` and vendored docs (thousands of files); the cost is that a spec in
  `docs/` isn't auto-found, paid by a "keep it at root" line in the template. (b) **The why-collision, resolved
  not deepened** — the spec and the wiki both hold "why," so routing now states *different* whys: spec = *why
  the product does this* (intended behavior + product intent, forward-looking); wiki = *why the code ended up
  this way* (decisions, dead-ends, history, backward-looking). Shipping "what & why → spec" verbatim next to
  "why → wiki" would have reintroduced the conflicting-docs tax (Principle 2) the whole routing rule exists to
  kill.
- **What it replaced.** The README-only freshness `if`-block → a generic per-doc loop (README behavior
  identical; a placeholder-only anchor now stays **silent** — no false PASS, tightened during fixture testing).
  The 3-doc routing (`README`/`CLAUDE.md`/wiki) → 4-doc (adds the spec as the intent home).
- **Shelf-life/risk class.** **Permanent** — reconcile-against-code is a permanent-class practice (docs rot no
  matter who reads them); this just extends it to the spec. Low blast radius: the audit change strictly *adds*
  coverage and fails safe (silent when nothing to check).
- **Related ROADMAP item.** **E**. No kit-self spec instance — the kit is a meta-repo with no product spec to
  fill (unlike W's manifest dogfood); `prd-template.md` is the template and is the whole artifact.
- **Commit.** *(uncommitted at time of writing — on branch `feat/E-spec-as-source`; stamp on merge.)*
- **Signal to watch.** (1) A project's spec freshness WARN read as "the spec is wrong" and blindly "fixed" by
  editing the spec, when the *code* was the drift → the "reconcile in whichever direction" framing isn't
  landing. (2) A spec kept in `docs/` and silently never checked → the root-only limitation biting; consider a
  configurable doc-root if it recurs.
- **Retrospect.** *(pending — revisit once a project has actually caught a spec/code drift via this check.)*

---

## 2026-07-06 — Date-stamp version-pinned facts + the re-verification habit (item M)

- **Change.** Closed ROADMAP item **M** (docs-only). Version-specific facts in durable docs (`2.1.x`,
  red-team stats) now carry an as-of date + a re-verify pointer. A survey found README (Field-evidence
  block, URLs verified 2026-07-03) and LESSONS (`v1, claims verified 2026-07-01`) **already dated** — the
  one durable doc pinned to a Claude Code version with **no** date and **no** re-verify pointer was
  `CHEATSHEET.md`. Fixes: (1) CHEATSHEET header stamps *2.1.x docs / live checks vs 2.1.201 / last verified
  2026-07-06* and states the habit — *these are version-pinned facts, not permanent; re-verify after any
  major Claude Code upgrade (items J/W)*; (2) the standalone red-team figure (sandbox-OFF, 5/44 blocked) is
  dated *(one machine, 2026-07)* + flagged version-pinned; (3) the README shelf-life `2.1.201` mention gets
  *verified 2026-07-06*.
- **Rationale (the bet).** A version-pinned mechanic stated as timeless is a trap: a reader leans on it after
  the tool has moved. This is the doc-wide companion to W/J — W gave version-assumptions a *dated home* (the
  manifest), J made a tool upgrade a maintenance event; M ensures the *prose* facts carry the same date +
  trigger so they can't quietly rot. The bet: one dated banner on the version-pinned reference beats peppering
  dates on every line (signal, not noise).
- **What it replaced.** An undated "Verified against Claude Code 2.1.x docs" header and an undated red-team
  stat. The scattered kickoff `2.1.201` mentions were **left as-is by design** — each already anchors to §9.1
  (dated 2026-07-06), so it inherits the stamp; re-dating each would be noise.
- **Shelf-life/risk class.** **Permanent** as a *habit* (dating version-pinned facts never stops being right);
  the *dates themselves* are depreciating and are exactly what the habit exists to keep honest. Zero blast
  radius (docs only).
- **Related ROADMAP item.** **M** (one of the K–N consistency fixes) — completes the doc-wide half W/J left
  unspent. K, L, N remain.
- **Commit.** *(uncommitted at time of writing — on branch `feat/M-datestamp-version-facts`; stamp on merge.)*
- **Signal to watch.** A Claude Code upgrade landing without anyone re-checking the CHEATSHEET → the header's
  re-verify pointer isn't landing where people look; consider a manifest row for the CHEATSHEET itself.
- **Retrospect.** *(pending — revisit at the next Claude Code major upgrade: did the dated banner actually
  prompt a re-verify?)*

---

## 2026-07-06 — Harness manifest (item W) + post-upgrade re-verify (item J)

- **Change.** Built ROADMAP items **W** and **J** together (docs + template, "not a new machine"). **W:** a
  tier-optional root `HARNESS_MANIFEST.md` template + teaching in kickoff §1.6a (the third sibling of the
  harness-self verifiers — metrics = ROI, `HARNESS_LOG.md` = history, manifest = *assumptions + freshness*),
  a Quick-Checklist line, glossary move (planned → built), and a **dogfooded kit-self instance** at
  `wiki/harness-manifest.md` (parallel to this log). **J:** treat a Claude Code *tool* upgrade like a model
  upgrade — realized as (1) a §1.4 doctrine bullet, (2) an extension of the README shelf-life doctrine to name
  tool upgrades, and (3) the manifest's **re-verify-trigger column**, where it becomes machine-legible.
- **Rationale (the bet).** Three existing artifacts answer *is it present?* (conformance), *what changed?*
  (log), and *does it pay off?* (metrics) — none answers *what does each part assume, and is that bet still
  fresh?* A harness part silently rots when the world it bet on moves (a tool upgrade dropping a setting; a
  coaching line the model outgrew). The bet: a small readable registry of assumptions + freshness turns "which
  bets are due for re-check" from a memory task into a glance — and gives J a concrete home (the trigger
  column) instead of a floating "remember to re-verify."
- **The spine, corrected in review (the whole risk of W).** First-pass instinct was a present/absent + risk
  roster — which duplicates `kit-conformance.sh` (presence) and `HARNESS_LOG.md` (per-change risk) and would
  rot as dead weight (item D's "605 rotting plan files"). Reframed to the one non-duplicating axis — **assumes
  × last-verified × re-verify trigger, grouped by shelf-life class** — with the split stated *in the artifact*
  so the three verifiers can't drift into rosters that disagree (the same rule enforced in the §9.1 AGENTS.md
  fix). J's own worked example is this session's **CC 2.1.201 silent-comment-drop** (verified via CC's
  `--debug` load log): a live boundary going quietly inert across a version bump.
- **What it replaced.** Net-new artifact + doctrine. The README shelf-life section previously framed *only*
  model upgrades as maintenance events; now names tool upgrades too. The audit's committed-scaffolding comment
  now lists `HARNESS_MANIFEST.md` among the ships-at-output-name files kept out of the alternation.
- **Self-contained template (caught in review).** The *shipped* root template is a project-retained artifact, so
  it must not cite kit-only docs (`§1.4`, `§1.6b`, `README §…`, `item J`) that vanish once the scaffolding
  steps away — the same rule the `HARNESS_LOG.md` template states for itself ("a reference nobody here can
  resolve is worse than none"). First draft leaked those refs; scrubbed to inline the substance ("re-run your
  security prove-it-bites checks: attempt a denied read → confirm blocked…"). Only the root template needs this;
  this kit-internal `wiki/` copy *may* cite maintainer docs and does. A verification-gap note: the selftest ran
  in the kit repo where `§1.4` resolves, so the break was invisible to it — it only surfaces in a project that
  kept the template without the kickoff.
- **Shelf-life/risk class.** **Appreciating** — as the harness accretes parts and the model/tool churn
  continues, a readable freshness registry earns more, not less. Zero blast radius (docs + a template; no
  executable path added).
- **Related ROADMAP item.** **W** + **J** (+ absorbs the re-verification half of **M**; M's doc-wide
  version-fact sweep stays open). Deliberately **no conformance/audit check this pass** — the artifact is
  tier-optional (absent is legitimate), and staleness is per-project judgment, not cleanly greppable; a
  §9.3.1-style placeholder WARN is the only clean check and is noted as a follow-up.
- **Commit.** *(uncommitted at time of writing — on branch `feat/W-harness-manifest-plus-J`; stamp on merge.)*
- **Signal to watch.** (1) A project's manifest drifting into a presence checklist or a change log → the
  in-artifact "how it differs from its siblings" framing wasn't read; tighten it. (2) Manifests going stale and
  ignored (item D's failure mode) → the tier-optional framing may need a lighter default, or the follow-up
  placeholder check. (3) Anyone hitting a silently-dropped setting after a CC upgrade *without* having re-run
  §1.4 → J's trigger isn't landing where people look.
- **Retrospect.** *(pending — revisit after a project actually keeps a manifest across a real CC/model upgrade.)*

---

## 2026-07-06 — Close the §9.2 security-template gaps + §9.3 process gaps (Fable review tail)

- **Change.** Closed all seven remaining items from the 2026-07-06 Fable multi-lens review — the five §9.2
  security-template gaps and the two §9.3 process gaps — plus corrected the stale ROADMAP §1 table (marked
  **R/V/G** built, which they already were in the glossary). Seven fixes, one batch:
  - **§9.2.1 verify-floor.** `scripts/kit-conformance.sh` now *reads the managed floor's content* when the file
    is readable (it is typically world-readable) instead of an unconditional SKIP: strict-JSON-loads it, then
    confirms three critical keys present (`disableBypassPermissionsMode` + a machine-credential `Read(...)` deny
    + `sandbox`). Content-present is evidence; **absence still SKIPs** (SKIPPED ≠ PASS holds — the PASS comes
    from reading keys, not inferring from a missing file). Added a `CONFORMANCE_MANAGED_FILE` test seam (mirrors
    the audit's `AUDIT_SKIP_*`) so the four outcomes are provable without root.
  - **§9.2.2 machine-cred denies.** Backported `Read(~/.ssh/**)`, `Read(~/.aws/**)`, `Read(~/.npmrc)`,
    `Read(**/*.pem)`, `Read(**/*.token)` into `templates/project.settings.json` — belt-and-suspenders with the
    managed floor, so a machine that never installed the floor still can't read them (the kit's own
    `.claude/settings.json` already carried these; the shipped template didn't).
  - **§9.2.3 MCP + web gating.** Added `mcp__*` to the template `deny` (the documented "deny every MCP tool"
    form — verified against the live permissions doc). Web gating + the MCP *re-enable* mechanism are taught in
    `templates/README.md` — critically, that a `deny` is **absolute** (can't be re-enabled with an `allow`; you
    remove the deny), and that `WebFetch` is **allowlisted by domain**, not bare-denied.
  - **§9.2.4 CI audit workflow.** New `templates/ci-audit.yml` starter → copy to `.github/workflows/audit.yml`.
    Runs `scripts/audit.sh`; gates on `RESULT: FAIL` only (WARNs surfaced, not fatal — a lean repo isn't red on
    day one; flip to strict = bare `bash scripts/audit.sh`); least-privilege `contents: read`; `actions/checkout`
    **SHA-pinned** to `34e114876b0b11c390a56381ad16ebd13914f8d5` (v4.3.1, dereferenced via `gh api`, not trusted
    from prose). Also catches a crashed audit (no RESULT line → fail).
  - **§9.2.5 docker escalation guard.** `templates/managed-settings.template.json` `ask`-gates
    `docker run --privileged` and docker-socket bind-mounts (`-v`/`--volume`/`--mount` of `/var/run/docker.sock`),
    including the mid-position `docker run * --privileged*` form. Documented honestly as a **best-effort backstop,
    not a boundary** (docker is in `excludedCommands` → runs unsandboxed; Bash arg-matching is evadable).
  - **§9.3.1 HARNESS_LOG placeholder check.** `claude-audit-base.sh` DOCUMENTATION section WARNs if a project's
    `HARNESS_LOG.md` still carries the unfilled version stamp. Keys on **`<kit-version>`/`<commit-sha>` only** —
    NOT `<YYYY-MM-DD>`, which also lives in the shipped "copy me" comment block projects are told to keep (a
    first-pass whole-file match on the date token false-WARNed on every compliant repo; caught in review, refixtured
    against the real shipped template). Item **Y** has nothing to diff against until it's real. Filled → PASS;
    absent → optional `·`.
  - **§9.3.2 prompts/ hygiene.** Gitignored `prompts/` as local build scaffolding (untracked, one-time sources
    — the kit's own "outputs persist, sources don't" rule). Non-destructive; delete/track remain maintainer
    options. Durable per-item content already lives in the ROADMAP write-ups.
- **Rationale (the bet).** Every one of these was the same defect class the review kept finding: *the kit
  teaching X while shipping not-X* (a managed floor with no verification, a settings template weaker than the
  kit's own, MCP/web named as Bash-risk but ungated, CI argued-for but never shipped). Closing the gap between
  the teaching and the artifact is what makes the kit's "prove it bites" promise true of the kit itself.
- **What it replaced.** An unconditional managed-floor SKIP; a template deny-list missing machine creds + MCP;
  no CI template; no docker escalation gate; no version-stamp enforcement. All net-additive except the verify-
  floor block (SKIP → content check) and the ROADMAP table markers.
- **Shelf-life/risk class.** **Permanent** for the credential/verification hardening (their force is a property
  of the trust model, not the model's ability); **depreciating** only the MCP-deny + docker rules, which track
  Claude Code's evolving surface (JSONC #17968, docker sandbox semantics) — re-audit at CC upgrades (item J/Y).
- **Related ROADMAP item.** §9.2 (all five) + §9.3 (both) + the §1 table fix for R/V/G. Verifiers touched:
  `kit-conformance.sh`, `claude-audit-base.sh`. Templates touched: `project.settings.json`,
  `managed-settings.template.json`, new `ci-audit.yml`, `README.md`.
- **Commit.** *(uncommitted at time of writing — on branch `fix/9.2-9.3-security-and-hygiene`; stamp on merge.)*
- **Signal to watch.** (1) A floored machine reporting the managed-floor row as SKIP when `/status` shows the
  source resolves to managed → the OS path list or readability guard missed it. (2) Any adopter surprised that
  MCP is off by default → the README re-enable teaching wasn't found. (3) `ci-audit.yml` going red on a healthy
  repo → the FAIL-only gate regressed to gating on WARN.
- **Verification.** verify-floor: four fixtures (complete→PASS, missing-keys→WARN, `//`-comment→WARN,
  absent→SKIP) via the test seam. HARNESS_LOG check: three fixtures (placeholder→WARN, filled→PASS, absent→`·`)
  through a seeded `scripts/audit.sh`. Both settings templates + `ci-audit.yml` parse (strict `json.load` /
  `yaml.safe_load`). Kit selftest green (bash -n sweep clean; eval-runner 9/9 PASS).
- **Retrospect.** *(pending — revisit after the first project adopts the hardened templates + runs the CI gate.)*

---

## 2026-07-06 — kit-conformance: resolve CLAUDE.md **or** AGENTS.md before gating (defect §9.1 item O)

- **Change.** Fixed the §9.1-item-O defect in `scripts/kit-conformance.sh` (the adoption verifier). **Bug:**
  it hardcoded `CLAUDE_MD="$TARGET/CLAUDE.md"` and set `have_claude` from `[ -f ]` on it, then gated the
  routing / budget / reviewer / action-risk rows on that flag. This contradicts the kit's own "Claude reads
  either" policy (kickoff §1.5 "On names", :733-734) and the adoption guide's symlink-one-name pattern
  (:116-118). **Reproduced:** an `AGENTS.md`-only, no-symlink fixture got a hard **FAIL, exit 1**, and the
  CLAUDE.md-gated rows were **silently skipped** — a correctly-adopted AGENTS.md project reported unadopted.
  **Fix:** a small resolution block *before* any gating — prefer `CLAUDE.md` (a real file **or** a symlink,
  since `[ -f ]` follows symlinks), else fall back to `AGENTS.md`, else neither → the existing FAIL, now
  naming *both* filenames. `$CLAUDE_MD` is repointed at the resolved file, so every downstream check inherits
  the resolution unchanged — only the source file moves.
- **Rationale (the bet).** The kit *actively governs* AGENTS.md as a cross-tool convention (ROADMAP §4:
  Linux Foundation, 20+ tools), so a verifier that only knows one of the two names will misreport a growing
  share of adoptions over time. The bet: fix the resolution at one point (the assignment), not by editing
  every downstream string — cheapest change, no altitude/exit-model disturbance, and the symlink pattern the
  adoption guide prescribes keeps working for free (`[ -f ]` already follows the link).
- **What it replaced.** The single hardcoded `CLAUDE_MD="$TARGET/CLAUDE.md"` line (now a 3-branch resolve),
  and the contract section's present/absent messages (name the resolved filename on PASS; name *both* on
  FAIL). Downstream check *predicates* are untouched — the prompt's "only the source file moves" contract.
- **Shelf-life/risk class.** **Appreciating.** As AGENTS.md adoption spreads across the tool ecosystem, the
  fraction of projects this fix correctly resolves only grows. Zero blast radius — a read-only verifier; the
  change strictly *widens* what it accepts, never loosens a FAIL floor.
- **Related ROADMAP item.** §9.1 item **O**. A fix to shipped "Built" work (the O verifier itself), same
  defect class as A and B — a gap between what the kit teaches (reads either name) and what it shipped.
- **Commit.** *(uncommitted at time of writing — left for review per the fix-O prompt; stamp the hash when it
  lands.)*
- **Signal to watch.** Any AGENTS.md-only project that still reports a contract FAIL → resolution regressed.
- **Sibling verifier fixed the same way (same commit).** `claude-audit-base.sh` had the identical
  hardcoding at `:284` (the action-risk join) and `:651` (the DOCUMENTATION presence line). Left alone, an
  AGENTS.md-only project would pass O's contract row but be misread by its own audit — a "two verifiers must
  not disagree" break (the same rule that already governs the settings-floor row). Fixed by resolving a
  `CONTRACT_MD` once near the top (mirroring kit-conformance's block) and pointing both sites at it. Proven
  on an AGENTS.md-only fixture: the action-risk join reads AGENTS.md's table and matches the settings rule
  (`action-risk gates wired`), and DOCUMENTATION reports `AGENTS.md present`.
- **Retrospect.** *(pending — revisit once an AGENTS.md-primary project is actually seeded and run.)*

---

## 2026-07-06 — Harness-metrics: de-inflate the audit-check count + add the free eval-fixture count (defect §9.1 item B)

- **Change.** Fixed the §9.1-item-B defect in `scripts/harness-metrics.sh` (the run-it-monthly harness scorecard).
  **Bug:** the audit-check count `grep -oE '(pass|warn|fail)[[:space:]]+"'` matched the *shape* of a check call
  anywhere on a line regardless of a leading `#`, so **comment-only lines counted as checks**. Measured against
  `claude-audit-base.sh`: **18 of 77 matches (23%) sat inside comment lines** (the INVARIANTS section's worked
  `# pass "…"` examples), which never execute — and that contamination *grows* as a real audit accretes
  illustrative commentary, the exact opposite of what a trend gauge should do. Fixed by stripping full-line
  comments (`grep -vE '^[[:space:]]*#'`) **before** the existing grep: **77 → 59** on the base audit (−18, the
  whole contamination), and the remaining 59 spot-check to real call sites. Trailing-`#` comments on a code line
  are deliberately **left in** (a naive strip would corrupt a legitimate `grep '#foo'` arg; it's a rare edge —
  documented in a one-line comment, keeping this an honest growth gauge, not an exact census).
  **Also added** a third free metric — an **eval-fixture count** (`find "$ROOT/evals" -name '*.eval.md' | wc -l`),
  mirroring the number `claude-audit-base.sh` already computes for itself — wired into the snapshot, the trend-log
  line + header, and a `delta`. It degrades to a clean **skip** when `evals/` is absent (the kit ships
  `evals-template/`, not `evals/`, so the kit's own run exercises that path).
- **Rationale (the bet).** A trend metric that drifts with documentation volume misreports direction — it can
  show a "growing safety net" when all that grew was the comments. The bet: strip the dominant, mechanical
  contamination (full-line comments) cheaply and honestly, name the rarer edge rather than over-engineer a
  string-safe trailing-comment stripper, and spend the same "free number" budget on eval fixtures — a second
  verifier whose growth actually matters. The defect was **measured first** (18/77), then the fix **proven to
  drop the count by exactly that** (77→59), then the new metric proven on a 3-fixture dir and on the absent-`evals/`
  skip path.
- **What it replaced.** The single-stage audit grep (now a comment-strip → grep pipe); the "two free numbers"
  framing in three comment sites (header caveat, snapshot banner, reminder) is now "three"; the trend-log schema
  gained an `eval_fixtures=` field. The `delta` guard, the malformed-line tolerance, and the never-fabricate-a-zero
  rule are untouched — a prior log line that predates the new field reads back as `eval_fixtures=n/a` and the delta
  stays honest (`n/a — needs two numeric readings`), proven directly.
- **Shelf-life/risk class.** **Permanent.** Leading-`#`-comment lines never execute in bash — a language property,
  not a model fact. The un-stripped trailing-comment edge is a bounded, disclosed approximation, consistent with
  the script's stated "growth gauge, not exact census" ethos.
- **Related ROADMAP item.** §9.1 item **B**. A fix to shipped "Built" work, not a new lettered item — same defect
  class as items A and O (a gap between what the kit teaches and what it ships).
- **Commit.** *(uncommitted at time of writing — the fix and this entry are left for review per the fix-B prompt;
  stamp the hash here when it lands.)*
- **Design choices worth pointing at.**
  - **Strip full-line comments, name the trailing edge.** The 18/77 contamination is entirely full-line `#`
    comments (the INVARIANTS worked examples); a `grep -v '^[[:space:]]*#'` removes all of it in one cheap stage.
    A trailing-`#` stripper would have to avoid corrupting a `#` *inside a string* (`grep '#foo'`) — real work for
    a rare case — so it's a documented non-goal, not a silent gap.
  - **Reused the audit's own eval count.** Not a new invention — the exact `find … -name '*.eval.md'` the base
    audit already runs, so the scorecard and the audit agree on the number by construction.
  - **New field is append-only and back-compatible.** Old trend-log lines lack `eval_fixtures=`; the sed read-back
    yields empty → `n/a`, and the `delta` guard rejects it — no crash, no fabricated zero.

---

## 2026-07-06 — The kit's first CI: run its own self-tests (eats its own "wire your verifier into CI" cooking)

- **Change.** Added `.github/workflows/selftest.yml` — the kit's **first** CI (there was no `.github/` at
  all). Matrix `[ubuntu-latest, macos-latest]`, two gates: **(1)** a `bash -n` sweep over every kit shell
  script; **(2)** the eval-runner regression self-test (`evals-template/eval-runner.selftest.sh`, the §9.1-A
  guard). This **wires in the document-only guard** the A-fix entry (below) shipped with and flagged for a
  reviewer to host. No live model — the self-test drives the runner through its stub seam, so CI is
  deterministic and free.
- **Rationale (the bet).** Two reasons, both on-doctrine. First, the kit *tells every adopting project* to
  "wire `scripts/audit.sh` into CI" (`claude-project-kickoff.md` checklist) yet ran **zero** CI on itself — a
  preach/practice gap; this closes it (the kit "eating its own cooking," same phrase this log uses for the
  wiki). Second, a regression guard that depends on a human remembering to run it is exactly the *self-report*
  the kit's §1.4 distrusts; CI makes it *bite* automatically, at PR time, where a re-introduced defect would land.
- **What it replaced.** Nothing removed — net-new. It supersedes the "run it by hand after editing the runner"
  status the A guard shipped with (that README nudge stays as the local-edit path; CI is the PR path).
- **Shelf-life/risk class.** **Appreciating** — a standing self-test grows more valuable as the kit's scripts
  multiply and as more concurrent sessions touch them — over a **permanent** core (a verifier the maintainer
  must run belongs in CI, precisely as the kit prescribes to projects). One **depreciating** rationale to flag:
  the `macos-latest` leg is *load-bearing today* because Bug 1 is unverified on Linux/glibc — if it's ever
  confirmed to reproduce on Linux too, that leg becomes belt-and-suspenders (keep it regardless).
- **Related ROADMAP item.** §9.1 item **A** (the guard it runs). Also closes the kit's own "preaches CI, runs
  none" gap — a §9.3-flavored process fix.
- **Commit.** *(uncommitted — same review batch as the A fix; stamp the hash when it lands.)*
- **Design choices worth pointing at.**
  - **The `macos-latest` leg is not redundant — it's the point.** Bug 1's crash reproduced on macOS bash but is
    *unverified on Linux/glibc*; on a Linux-only runner the crash may not fire even on reverted code, so the
    Bug-1 half of the guard would silently no-op. macOS is where a revert bites. (Bug 2 is locale-independent —
    it guards on any runner.) `fail-fast: false` so both OS signals always show.
  - **Minimal on purpose.** Two gates only. `bash scripts/kit-conformance.sh` (the kit against itself) is the
    obvious next gate — left as a documented TODO in the workflow header, not added blind.
  - **Simple triggers, no path filters (yet).** `push: [main]` + `pull_request`. The auto-commit Stop hook
    commits WIP *locally* (doesn't push), so GitHub main-push CI fires only on PR merges — not per snapshot —
    so no filter is needed to keep it quiet. Add `paths:` filters if macOS minutes (10×-metered) ever bite.
  - **Validated before shipping.** YAML parsed; both CI steps run locally on macOS (sweep → all 5 scripts ok;
    self-test → 9/9). The ubuntu leg is validated by construction — the *fixed* runner is locale-independent.
- **Signal to watch.** The first real PR run: does the ubuntu leg pass green (expected) and — the actual test —
  would the macOS leg *fail* on a Bug-1 revert? Is `kit-conformance.sh`-on-itself worth adding as gate 3? Do
  macOS Actions minutes become a cost worth a `paths:` filter?
- **Retrospect.** *(open — revisit after the first few PR runs, or if CI cost/scope needs tuning.)*

---

## 2026-07-06 — Eval-runner fail-paths: braced guillemet diff + trailing-VERDICT judge extraction (defect §9.1 item A)

- **Change.** Fixed the two §9.1-item-A defects in `claude-eval-base.sh` (the behavioral-eval runner) — both
  living in the runner's *failure* paths, which a happy-path smoke never exercises. **Bug 1:** on line 101 the
  golden-fail diff message interpolated `«$expected»` / `«$candidate»` unbraced, directly against the `»`
  guillemet (UTF-8 lead byte `0xC2`); bash's identifier scanner swallowed that byte into the variable name, so
  under `set -u` a golden that **FAILED** aborted the whole run with `unbound variable` instead of printing
  `FAIL` — and it cascaded (a failure on fixture #1 silently prevented #2..N from ever running). Fixed by
  **bracing** `${expected}` / `${candidate}` (keeps the guillemets; a scan confirmed line 101 was the *only*
  unbraced-var-before-multibyte site, so this closes the class). **Bug 2:** the rubric verdict extraction
  `grep -m1 -oE 'PASS|FAIL' | head -1` scanned the judge's **entire** output for the first keyword, so a judge
  that reasons before concluding flipped the verdict **either direction** ("...tempting to PASS..." → wrong
  PASS on a bad answer; "...why it did NOT FAIL..." → wrong FAIL on a good one). Fixed by changing the judge
  **prompt and the extraction together**: the prompt now requires a trailing `VERDICT: PASS|FAIL` line, and
  extraction takes the **last** `VERDICT:` line (no line → empty → conservative FAIL). Left behind a committed
  **regression self-test** (`evals-template/eval-runner.selftest.sh`) that drives the runner through its own
  `EVAL_CMD`/`EVAL_JUDGE_CMD` stub seam — **no live model** — and asserts both fail-paths behave.
- **Rationale (the bet).** This is the kit's own §1.4 discipline turned on a shipped verifier: *prove it bites*.
  The runner failed at the exact job it exists to do — report a regression — and the ROADMAP's own tell was that
  A never carried a "proven on fixtures" annotation (H/O/X did), because the golden **FAIL** path was, by all
  evidence, never run before shipping. The bet: fix both, and leave a self-test that *deliberately fails a golden
  and drives a reasoning-first judge*, so the untested path is now the tested path and neither bug can silently
  return. Both bugs were **reproduced first** (crash + both flip directions), then the fixes proven, then the
  self-test proven to **fail on a revert** of either fix — not merely pass on green.
- **What it replaced.** The unbraced interpolation; the first-match `grep -m1 … | head -1` extraction; and the
  judge's old "reply with ONE word on the first line" contract (a free-form judge silently violated it). Nothing
  else in the runner changed — the `epass`/`efail` helpers, builder/judge split, and per-stream `2>` logging are
  untouched.
- **Shelf-life/risk class.** **Permanent** on Bug 1 (bash's identifier scan × `set -u` × UTF-8 is a language
  property, not a model fact) and largely permanent on Bug 2 (a fixed delimiter emitted last is robust to *any*
  judge model; the failure mode it removes is a harness bug, distinct from the honestly-disclosed ~6pp LLM-judge
  noise). Mild **depreciating** edge: as judge models get better at following "emit VERDICT: last," the
  conservative-FAIL-on-missing-delimiter path fires less — but the delimiter is strictly safer, so keep it.
- **Related ROADMAP item.** §9.1 item **A** (both "A —" entries). A fix to shipped "Built" work, not a new
  lettered item. Same defect class as the settings fix below (a gap between what the kit teaches and what it ships).
- **Commit.** *(uncommitted at time of writing — the fix, the self-test, and this entry are left for review per
  the fix-A prompt; stamp the hash here when it lands.)*
- **Design choices worth pointing at.**
  - **Braced, didn't drop the guillemets.** Smallest change that makes the variable boundary explicit on *both*
    vars while preserving the file's `«…»` aesthetic (the advisor's steer).
  - **Delimiter form over a line-1 anchor.** Anchoring to line 1 still mis-reads a judge that reasons *before*
    concluding — the exact failure mode. A trailing `VERDICT:` + last-match is robust to reasoning on either
    side. Prompt and extraction are **one contract**; a "fall back to scanning the whole output" branch was
    deliberately *not* added — it would reintroduce the bug.
  - **Fails safe, never silent-pass.** A judge that ignores the protocol yields an empty verdict → `FAIL` with
    `judge verdict: <none>`, proven in the self-test.
  - **The guard is document-only for now.** It exits 0/1 (trivially CI-wireable) and the README says to run it
    after touching the runner — but nothing runs it automatically: `kit-conformance.sh` is roster-only *by
    contract* ("NEVER executed here") and `claude-audit-base.sh` is a per-project template, so neither is the
    right host. Flagged for the reviewer to optionally wire into a future kit CI.
- **Signal to watch.** (1) Does the self-test actually get *run* on runner edits, given it's document-only?
  (2) Do real judge models reliably emit the trailing `VERDICT:` line, or do some ignore it and hit the
  conservative FAIL (a false-FAIL risk to watch when the judge model changes — extends item J's "re-verify after
  a judge change")? (3) Bug 1 is verified on macOS bash 3.2.57 + Homebrew 5.3.15 under `LANG=en_US.UTF-8`, *not*
  on Linux/glibc — the fix is correct everywhere, but the crash's reach is unconfirmed there.
- **Retrospect.** *(open — revisit when the runner is next edited, or at a judge-model change.)*

---

## 2026-07-06 — Settings are strict JSON: comment-free templates + command-pattern action-risk join (defect §9.1)

- **Change.** Fixed a kit-wide, *silent* security defect (ROADMAP §9.1 #5, expanded far beyond how the
  review scoped it). Verified against **Claude Code 2.1.201** via its own `--debug` settings-load log:
  settings.json is **strict JSON**, and ANY `//` comment — leading banner OR inline — makes CC **silently
  drop the whole file** (0 rules load, no error). All three shipped settings files carried comments → were
  silently non-functional. Fix (A–D): **(A)** `kit-conformance.sh`'s loadability check → **strict** JSON
  (it had been JSONC-tolerant, built hours earlier on a false premise); **(B)** stripped comments from
  `templates/project.settings.json`, `templates/managed-settings.template.json`, and the kit's own
  `.claude/settings.json`, relocating their teaching to `templates/README.md`; **(C)** kit-wide "strict
  JSON, no comments" teaching (kickoff §1.3c/§1.4/§1.5/checklist, templates/README, glossary R, ROADMAP §9),
  version-scoped to CC 2.1.201; **(D)** redesigned R's action-risk marker from an inline `// action-risk`
  settings comment (which voided the file) to a **command-pattern join** — the CLAUDE.md table names each
  gate's *exact rule*; audit + conformance join by that rule string. Plus a **strict-JSON gate in the AUDIT**
  (recurrence prevention).
- **Rationale (the bet).** The kit's cardinal promise is "prove it bites, don't trust a self-report" — yet
  every shipped settings file was silently doing nothing, and O *certified* the broken form as PASS. The
  bet: match the real consumer (CC = strict JSON), ship comment-free files, and make BOTH verifiers **FAIL**
  a comment-bearing file so a floor-voiding mistake is *loud*, not silent. The command-pattern join is
  comment-free **and** stronger — it proves the *specific* dangerous command is gated, not just that "some
  tagged rule exists."
- **What it replaced.** The inline `// action-risk` marker mechanism (item R) and the JSONC-tolerant O#3
  check (built earlier the same day). Nothing else removed; the action-risk table + `<!-- action-risk -->`
  marker stay in CLAUDE.md (markdown — comments are fine there).
- **Shelf-life/risk class.** **Depreciating** on the CC-parser fact (re-audit at a CC upgrade; if JSONC
  ships — #17968, open — this reverses, and re-checking it is item **Y**'s job) but **permanent** on the
  principle (match the real consumer's parser; a silent security void must be made loud). Highest
  blast-radius change in this session — it rewrites the security-critical settings files — so every one was
  re-verified **through CC's own loader** (comment-free files now load 13 / 7 deny rules where they loaded 0
  before) plus the fixture matrix.
- **Related ROADMAP item.** §9.1 defect sweep (O#3 + #5), touching **R**, **O**, and the settings templates.
  A fix to shipped work, not a new lettered item.
- **Commit.** `df608ba` (the fix: comment-free templates + strict-JSON gates + command-pattern join) + this log entry.
- **Design choices worth pointing at.**
  - **Verified the CONSUMER, not a proxy.** The bug existed because "python says invalid JSON" had been
    treated as truth while CC behaved differently. Both the finding AND the fix were confirmed through CC's
    own `--debug` load log (banner file → `projectSettings 0 rule(s)`; comment-free → the real count) — not
    just python. python `json.load` is used in the check only as a strict *proxy* that matches CC's rejections.
  - **JSONC-strip would have been a *second* bug.** The first O#3 fix stripped comments then parsed, on the
    belief CC accepts comments. It doesn't — so that check would PASS a comment-bearing file CC silently
    drops. Reverted to strict. (The review's original `python json.load` suggestion was right; my earlier
    "JSONC correction" was wrong — a proxy-vs-consumer trap, caught by testing the consumer.)
  - **Command-pattern join, not a table parser.** Extract the backticked `Tool(...)` rules from the marked
    table block, grep settings for each (whitespace-normalized), WARN if any named rule isn't wired. The
    floor's own `ask(git push)` does not satisfy a table naming `Bash(blog-publish *)` — proven.
  - **Recurrence prevention in the AUDIT, not just O.** O catches it at adoption; the audit (every edit)
    FAILs a `//` re-added out of habit. The durable half.
  - **Scope held.** The docker `--privileged` guard and the managed-floor-verify script (both §9.2) are
    adjacent but separate — flagged, not folded in.
- **Signal to watch.** Do adopting projects' comment-free settings actually load their rules in the field
  (the debug-log check confirms it here)? Does a re-added `//` hit the loud FAIL rather than a silent void?
  If CC ships JSONC (#17968), this whole entry reverses — the version-scoped teaching is the tripwire.
- **Retrospect.** *(open — revisit at the next CC upgrade, or when #17968 changes state.)*

---

## 2026-07-06 — Kit-update proposals (item Y — re-review against a newer kit)

- **Change.** Built item **Y** — the living-adoption loop, docs-only (no new machinery, per §Y). A
  new **§6 "Re-review as the kit evolves"** in `claude-project-adoption.md`: re-run §0's
  evaluate→propose against the delta between a repo's adopted kit version and the current kit, propose
  retrofits *for this repo*, human decides, then append a **reviewed-through** entry that advances the
  baseline. One **precondition fix** in kickoff §1.6a — it now instructs *filling* the version stamp
  with the kit's current commit at seeding (Y's diff needs a real commit, not a placeholder). Flipped
  §1.6a's "item Y, not built yet" gesture. ROADMAP §Y + build-order marked built; glossary moved Y
  planned→built.
- **Rationale (the bet).** A repo adopts the kit at a point in time; the kit keeps improving, and
  without a catch-up path the gap silently widens. The bet: Y needs **no new machine** — it is the
  adoption guide's evaluate→propose re-invoked against a *delta*, and X-full just made that delta
  computable (a dated, machine-legible `wiki/harness-log.md`). Two mechanics carry the weight (below);
  get them wrong and Y is either groundhog-day noise or has nothing to diff.
- **What it replaced.** Net-new capability; nothing removed. It is the **sibling of X-full's
  cross-repo learning** (same read→propose habit, source = the newer *kit* instead of a sibling repo)
  and the **forward complement of O** (O: what's *missing* vs. what I adopted; Y: what's *newly
  available* since). Reuses §0 (evaluate→propose), the version stamp (X), and the lean six log fields
  (no schema change) — three existing pieces wired into a loop, not a fourth artifact.
- **Shelf-life/risk class.** **Appreciating** — Y is worth more as the kit accretes items to propose
  (every future ROADMAP item becomes a candidate a Y run can surface). Zero blast-radius:
  documentation only; the one thing Y *writes* is a human-approved `HARNESS_LOG.md` entry recording
  the owner's own accept/decline decisions — no auto-edit of the harness, on-prompt not scheduled.
- **Related ROADMAP item.** **Y** (kit-update proposals), build-order **step 6** (the last named
  item). Depends on **X** (the version stamp — now built), extends **O** (built), and references **W**
  (harness manifest — *planned*, cited as such).
- **Commit.** `05cc863` (§6 procedure + §1.6a precondition) + this log entry.
- **Design choices worth pointing at.**
  - **Baseline-advance — the mechanic that separates useful from noise.** The naive design diffs from
    the *original adoption stamp* every run and so re-proposes everything already **declined** — the
    "tuned out until ignored" failure the kit fights everywhere. Fix: each Y run ends by appending a
    **reviewed-through** entry (`origin: kit-update proposal (Y)`, naming the kit commit reviewed
    through); the next run diffs from **that**, and declined-with-reason isn't re-raised unless the
    reason lapses. Dedup-against-*seen*, not against-*adopted* — the trap-avoidance O's exit model
    encodes. Rides the append-only log X-full made legible; **no schema change**.
  - **The delta source is the DATED log, not the built tables.** `ROADMAP.md` / `glossary.md` built
    tables are undated snapshots (what/where); the dated `wiki/harness-log.md` is what makes
    "new-since-my-adoption" computable (entries after the baseline; current version = the top entry).
    A clean loop-close: X-full's dated schema is precisely Y's diff source. Built tables supply the
    per-candidate detail.
  - **Precondition caught and fixed.** X-full formalized the stamp's *shape*; §1.6a mandated the
    *file* but never told the project to *fill* the stamp — so it could ship as a `<commit-sha>`
    placeholder and leave Y nothing to diff. Added the one-line seed instruction, and made Y **degrade
    gracefully** on a placeholder (full re-review + fill the stamp now).
  - **Fit-to-project leads; churn-control follows.** Propose-never-apply has two reasons, and the
    deeper one is fit: only the owner knows a newer practice suits *this* repo's tier (a solo repo
    correctly declines a team item). That is *why* the declined-with-reason record matters. Churn
    (Ronacher: automation isn't free; on-prompt not scheduled) is the second. And the trust posture is
    **lighter than X-full's**: the kit is a source the repo already chose (Lesson 5), so the gate is
    fit + churn, not untrusted-content.
  - **Docs-only — no differ script.** The delta that matters is *does this fit this repo, in what
    order* — agent judgment, not a mechanical date-filter. Same prose-over-tooling call as O's fan-out
    and X's reader. Resisted a "list-items-since" helper on the merits.
  - **W cited as planned, not built** — the citation hygiene X-full applied to item F.
- **Signal to watch.** On the *second* run in a real repo, does the reviewed-through marker actually
  suppress the already-declined items, or does Y still feel repetitive (marker missed, or
  decline-reasons too coarse to match)? Do owners *fill* the version stamp at seeding now that §1.6a
  says to, or does it still ship as a placeholder (sending every Y run down the full-re-review
  fallback)? And does "fit-to-project" hold as the lead — do solo repos comfortably decline
  team-scale items, or does Y nudge toward over-adopting? If the marker proves too coarse, the durable
  fix is a sharper reviewed-through record (per-item, not per-run), not automation.
- **Retrospect.** *(open — revisit after the first real second-run of Y in an adopted project, or when
  W lands and accepted upgrades get a manifest home.)*

---

## 2026-07-06 — Cross-repo learning + portable HARNESS_LOG.md schema (item X, full)

- **Change.** Completed item **X**'s cross-repo layer (the basic log shipped 2026-07-04 with B).
  Two docs touches, no new machinery: (1) a **"Portable schema — the cross-repo contract"** section
  in the shipped root `HARNESS_LOG.md` template — it pins the fixed name/location, the machine-legible
  entry shape (`## YYYY-MM-DD — title` header + the lean five bold-label fields, date in the header),
  the lean six-field set as the whole portable contract, and the first entry as the version stamp; the
  template's anchor was reconciled to that exact shape (date moved into the header, dropped the
  redundant `- **date:**` line) so the one worked example conforms. (2) a **cross-repo-learning**
  teaching in kickoff **§1.6a**: a human hands you a *trusted* sibling repo's log → you **propose**
  borrowings → the human decides. ROADMAP §X marked built; glossary X row updated.
- **Rationale (the bet).** A harness bet learned the hard way in one repo (a regression guard, a
  directive, a check) is worth *more* if it can travel to a sibling repo instead of being relearned.
  The bet: a **fixed name + location + entry shape** makes every kit-derived log readable by an agent
  in another repo — *without* any parser, because the reader is an LLM and a consistently-shaped
  markdown entry is already machine-legible to it. The whole value is gated on one trust rule (below);
  get that wrong and a convenience becomes an attack surface.
- **What it replaced.** Net-new capability on top of X-basic; nothing removed. It **firms** the
  existing lean template schema into a stated *contract* (rather than an incidental format) and adds
  the teaching; it did not touch the schema's *fields*. The kit's own `wiki/harness-log.md` keeps its
  richer internal schema (per [[SCHEMA]]) — the portable contract is deliberately the leaner project
  template, not this file.
- **Shelf-life/risk class.** **Appreciating** — cross-repo learning is worth more as the fleet of
  kit-derived repos grows (more sibling logs to borrow from), and it is the practice **item Y** builds
  on. Zero blast-radius: documentation + a template edit; no script, no execution, no network — the
  reading is a human-initiated, human-decided act by construction.
- **Related ROADMAP item.** **X** (harness change log + cross-repo learning), build-order **step 6**
  (the cross-repo layer). Feeds **Y** (kit-update proposals — the same read→propose habit pointed at
  the current kit via the version-stamp delta), which is *not* built here.
- **Commit.** `c5b5ede` (the portable schema + §1.6a teaching) + this log entry.
- **Design choices worth pointing at.**
  - **Docs-only — no schema validator, on the merits.** The consumer of a cross-repo log is an LLM,
    which reads `## date — title` + bold-label markdown reliably without a grammar. A lint would
    enforce a rigidity the actual reader doesn't need — the "unverified complexity must earn its keep"
    rule (Lesson 5), the same call that kept O's Part 2 fan-out as prose. "Machine-legible" here is a
    *consistent template + worked example*, not tooling.
  - **The trust model is the whole feature.** Two non-optional rails: (1) **the human supplies a
    trusted source** — the agent never crawls/searches/fetches other repos' logs (learn *from
    another's*, not *find* one); (2) **propose, never auto-apply** — another repo's log is content from
    *outside the trust boundary*, so it is **data to reason about, not an instruction to execute**
    (§1.3a containment). Cited §1.3a deliberately, **not** item F (untrusted-content rule) — F is still
    *planned*, and a doc must not cite an unbuilt item as if it shipped (the citation-hygiene the kit
    applies to any cross-reference).
  - **Portable = the LEAN six, not the rich internal schema.** Cross-repo learning happens *between
    projects*, and a plain project has no basis for maintainer-only fields (a ROADMAP-item pointer, a
    shelf-life class — the very fields *this* entry carries). Exporting the rich schema as "portable"
    would have been the conflation to avoid; the template stays the lean six.
  - **O left untouched — a settled scope respected.** A one-line "HARNESS_LOG.md present + version
    stamp" check *could* live on O's roster, but O deliberately excluded the B/X artifacts; reopening
    that for marginal gain would self-contradict O's own entry. The stamp's presence is mandated by
    the template and taught in §1.6a, not O-checked.
  - **Dogfood — reconciled the anchor to the shape it now declares.** The shipped template's anchor had
    used a `- **date:**` field and a non-date header; it was rewritten to the canonical
    `## <date> — title` shape so the one worked example the template ships *is* conformant. (This very
    entry — and every entry in this file — holds that same header+bold-label shape: the portable shape
    proven on the kit's own filled log.)
- **Signal to watch.** Does anyone actually hand Claude a sibling repo's log and get a *useful*
  borrow-proposal, or does cross-repo learning stay theoretical (a capability nobody invokes)? If it
  gets used, do the two rails hold — does an agent ever drift toward *finding* logs, or toward
  *applying* a borrowed change without the human? If either slips, the durable fix is sharper teaching
  (or, if fetching ever gets wired, a hard settings gate), not loosening the posture. And when **Y** is
  built, does the version-stamp anchor prove sufficient to compute the kit delta, or does it need a
  firmer machine-readable version field than a line of prose in the first entry?
- **Retrospect.** *(open — revisit when the first cross-repo borrow-proposal happens in a real
  project, or when item Y is built on this.)*

---

## 2026-07-06 — Adoption check + fan-out verifier (verify the whole kit's adoption, not a self-report)

- **Change.** Built item **O** — the adoption verifier. New `scripts/kit-conformance.sh`: a
  deterministic roster check over the artifacts kickoff/adoption should have produced (`CLAUDE.md`
  + its routing/reviewer blocks, the per-repo secret-read floor, a `bash -n`-valid
  `scripts/audit.sh`, behavioral evals, ≥3 wiki incident pages, the action-risk gates), rolled into
  an adoption scorecard. Plus teaching in `claude-project-kickoff.md` **§1.6c** (which also carries
  the Part 2 **fan-out playbook**), a **Definition-of-Done upgrade** in `claude-project-adoption.md`
  (the DoD list is now machine-checked by the script), one Quick-Checklist line, and the
  outputs-list / glossary / ROADMAP bookkeeping. In the same session, propagated the **Q** citation
  fix (Fowler→Böckeler) across the rest of the kit.
- **Rationale (the bet).** The kit is now big enough that one session reading all of it blows its
  context and marks things "done" it never did — a self-report you cannot trust. O is §1.4's "prove
  it bites, don't trust a self-report," turned on the *whole kit's adoption*, decomposed by fan-out
  so no single context has to hold the kit. The load-bearing bet is the **exit model**: *FAIL only
  what no correct adoption could omit; WARN what a lean-but-correct project may legitimately skip;
  exit nonzero only on FAIL.* Copying the audit's `warn(){ …; overall=1; }` idiom would have made a
  correct **code-only throwaway** *fail* on artifacts it is right to omit — the exact way a check
  gets tuned out. Proven: a floor-only fixture (CLAUDE.md + deny floor + valid audit, nothing else)
  exits **0**.
- **What it replaced.** Net-new; nothing removed. It sits beside the §1.6 verifier family (audit
  §1.6, scorecard §1.6a, evals §1.6b) at a **different altitude**: the audit checks *code health*
  after every edit; O checks *the harness is installed* once/periodically, and treats `audit.sh` as
  one roster item (present + `bash -n`, never executed). Where they overlap it **reuses the audit's
  exact predicates** (the `action-risk` marker-join, the `*.eval.md` count, the `## Review` /
  `## Knowledge & memory` anchors) rather than inventing new ones — one vocabulary, two questions.
- **Shelf-life/risk class.** **Appreciating** — an adoption verifier is worth *more* as the kit and
  the fleet of kit-derived repos grow: it is what makes item **Y**'s living-adoption re-review
  possible, and the thing that scales the kit past what one context can hold. Zero blast-radius: a
  read-only report + docs + placeholders; it executes nothing but `bash -n` on an existing file,
  writes nothing, and exits nonzero only on a missing floor artifact.
- **Related ROADMAP item.** **O** (the big one), build-order **step 5** — "makes the rest stick."
  It checks for **R** (the action-risk marker), **V** (`## Review`), **A** (evals), and the floor;
  and it is the anchor **Y** (kit-update proposals) re-runs against the delta to a newer kit.
- **Commit.** `ba61ed6` (the feature + Q propagation) + this log entry.
- **Design choices worth pointing at.**
  - **The exit model is the whole game** (see the bet) — a *third* model, unlike either cousin (the
    audit gates on WARN|FAIL; harness-metrics always exits 0): nonzero only on FAIL. Proven across a
    fixture matrix — floor-only → 0 FAIL / exit 0; each floor break (no `CLAUDE.md`; **no**
    `.claude/settings.json`; an absent or `bash -n`-broken audit) → FAIL / exit 1; each optional
    degrade (no reviewer; a settings floor with no active read-deny; <3 wiki pages; over budget;
    tagged-table-no-gate) → WARN / exit 0; and the **no-arg production seam** (script placed in a
    seeded project's `scripts/`, run with no argument so `TARGET` takes the `$ROOT` default) →
    CONFORMANT. Every case pasted, not asserted.
  - **Deny-floor severity is concordant with the audit — a caught inconsistency.** First draft FAILed
    "settings present but no secret-read deny"; the **audit's** SECURITY section only **WARNs** on the
    same input (its "#1 gap" nudge). Two kit verifiers disagreeing on one input reads as a bug, and the
    managed floor's `Read(**/.env)` glob **can** cover a repo's secrets — so a floored machine may
    *correctly* omit the repo-level read-deny, which O's own "FAIL only what no correct adoption could
    omit" test says must be WARN. Split on the merits: a **missing** `.claude/settings.json` (the home
    of the push-gate + Stop hook too) → FAIL; **present-but-no-read-deny** → WARN, matching the audit.
  - **`audit.sh` is a roster entry, not a dependency.** Present + `bash -n`-valid → PASS; never run.
    Running it would check code *health* at the wrong cadence, couple the two scripts, and defeat the
    fan-out. This altitude line is what keeps O from collapsing into a second audit.
  - **Reused predicates, not reinvented anchors.** The action-risk check is the audit's **verbatim**
    marker-join (keys on the `action-risk` tag on an *active*, non-`//` settings line, so the floor's
    own untagged `ask(git push)` cannot false-green it — proven in the matrix). Likewise the evals
    count and the `## Review` / `## Knowledge & memory` greps.
  - **Managed floor: loud SKIP, never green.** A root-owned OS file outside the repo isn't portably
    readable, so O SKIPs it with "confirm via `/status` + `claude doctor`" — `SKIPPED ≠ PASS` (item
    G). A trivial best-effort macOS-path peek, but it SKIPs either way.
  - **Part 2 is prose, not machinery.** You cannot spawn sub-agents from bash, so the fan-out is a
    documented playbook (§1.6c, cross-referencing Part 3.1/3.13 + the "don't trust a self-report" rule),
    not a driver binary. An optional `--area` seam was left **unbuilt** (builder's-judgment, like R's
    settings example) — the roster is small enough that a whole-run is cheap.
  - **Scope held to §O's roster.** The B/X artifacts (harness-metrics / `HARNESS_LOG.md`) were *not*
    added as checks — they aren't in §O's enumeration, and "lean tier gets just the conformance
    script" argues against creep.
  - **Structural only — named, not faked.** A header comment states plainly it proves *presence*, not
    *correctness* (a routing block that actually routes; evals that test something real) — that read
    is the fan-out's / a human's job, mirroring the audit's grep-limits candor and item H's line.
- **Signal to watch.** Do adopting projects actually **run** it (and read the WARNs), or does it join
  the tuned-out pile? Does the exit model hold — do real lean projects come out zero-FAIL? (The
  likeliest false-positive — a floored machine with only `denyWrite` set locally — was **pre-empted**
  by splitting the deny-floor check to WARN, concordant with the audit; see the design note. Watch
  whether any *other* FAIL-class row proves over-strict in the field.) Does the fan-out playbook get
  used on big adoptions, or does everyone just run the script?
- **Retrospect.** *(open — revisit when the first real project runs the check, or when item Y is built
  on top of it.)*

---

## 2026-07-04 — Safeguard-rot check (safeguards assert their own anchor)

- **Change.** Built the safeguard-rot check (ROADMAP item **H**). Two files. In
  `claude-audit-base.sh`: a `guarded "<what>" "<anchor-file>" "<symbol|''>" && { <real check> }`
  helper that confirms a guard's declared **anchor** still resolves *before* the real check runs
  (anchor present → run it; anchor gone → **WARN loudly and skip the body**), plus a new
  **`SAFEGUARD SELF-CHECK`** section ("audit the audit") that rolls up every anchored guard
  exercised this run and names the rotted ones. The rot-prone template guards were converted to the
  convention — INVARIANTS **#1** (pure-module, file anchor) and **#3** (diagnostic read-back, file +
  *symbol* anchor `your_log_table`) and the **REGRESSION GUARDS** example (file + symbol anchor tied
  to the fix). In `claude-project-kickoff.md`: a **§1.6** teaching subsection + one Quick-Checklist
  line.
- **Rationale (the bet).** A safeguard is a `grep`, and a grep rots **silently**: an "absent from
  `file.x`" guard keeps returning green the day someone renames `file.x` or refactors the thing away —
  it protects nothing but still *reads* as protection. That is **worse than no guard** (false
  confidence — *a check that no longer runs is just prose*, §1.3a). The bet: a guard that **declares
  the anchor it depends on** and fails loud when that anchor is gone converts the most dangerous
  failure mode of the safety net — a dead guard that looks alive — into a visible WARN, at the cost of
  one wrapper call. The self-check is the same idea pointed at the audit's *own* guards, mirroring the
  wiki's `stale`/`coverage` (a check that checks itself).
- **What it replaced.** Net-new; nothing removed. It **hardens the safety net** the kit already
  teaches (glossary *safeguard* / *the safety net*; §1.6's "add a regression guard for every bug")
  rather than adding a new artifact — the existing template safeguards were rewritten *through* the
  helper, not duplicated. Reuses the house `pass`/`warn`/`fail` idiom and the INVARIANTS grep-limits
  candor (no new vocabulary; the audit is still a **verifier**, each check a **safeguard** — not a
  "sensor").
- **Shelf-life/risk class.** **Permanent** — its force is a property of the world, not the model: a
  grep's literal match silently stops matching under a rename no matter how capable the model gets, so
  a guard that doesn't assert its own anchor will always be able to die quiet. Zero blast-radius:
  the shipped template has **no active** `guarded` calls (every converted example stays a commented
  placeholder), so `GUARDS_TOTAL=0` and the self-check emits a `·` info line — the `WARN`/`FAIL` tally
  is unchanged *by construction*, not by luck.
- **Related ROADMAP item.** **H** (safeguard-rot check), build-order step 4 (security + false-security
  hygiene, beside **G** dependency-vuln scan). Feeds **O**: the self-check is the audit verifying its
  own guards, the same "verify adoption with a verifier, not a self-report" posture O applies to the
  whole kit.
- **Commit.** `7fec8a9` (the two-file feature) + this log entry.
- **Design choices worth pointing at.**
  - **Gate-clause form, not an eval wrapper.** `guarded … && { real check }` keeps the guard body
    **plain shell** (no `'\''`-escaped eval string). On a lost anchor `guarded` returns 1 and the
    `&& { }` body is skipped — the load-bearing property (**a missing anchor never reaches a `pass`**)
    falls out of ordinary `&&` short-circuiting under `set -uo pipefail` (no `set -e` to fight).
  - **Registry, not a text-scan, for the self-check.** The self-check reads counters `guarded`
    populates as it runs (`GUARDS_TOTAL` / `GUARDS_ROTTED` / a names string), **not** a grep-and-eval
    over the script's own source. A static parser could mis-parse a multi-line call or fail to expand a
    `$VAR` and report a **live** guard as rotted — a self-check that cries wolf about the safety net is
    exactly the false-confidence-in-reverse H exists to kill. The registry tests the *actually
    resolved* path at runtime, so it cannot false-positive. Plain int/string counters (not a bash
    array) keep it safe under `set -u` on old bash (3.2). Honest cost: it only covers guards that
    **ran** this pass — a guard behind a disabled branch isn't rolled up until re-enabled, at which
    point `guarded` flags it in place (stated in the section comment).
  - **Structural rot only — the honest half, named not faked.** The check proves each anchor still
    **exists**; it **cannot** prove the anchor still **means** what the guard assumed (semantic rot:
    file/symbol present but the surrounding code refactored so the pattern no longer bites). That is a
    human read — a review / LLM-judge pass — flagged in a comment that mirrors the `~line 122`
    INVARIANTS grep-limits note. Build the structural half; name the semantic half.
  - **Conversion scoped on the merits.** Only the rot-prone **named-file** guards were wrapped;
    whole-dir scanners (INVARIANTS #2/#4/#5 over `$SRC`/`$UI`/`$ROOT/content`) were left unwrapped
    with an in-file note — a dir-scan anchors to a dir that can't rot the insidious silent way a
    renamed named-file guard does (and a bad `$SRC` fails everything visibly). So "convert the
    template safeguards" reads as a judgment call, not three that were missed.
  - **Proven on real fixtures, not asserted.** A scratch project ran the *verbatim* shipped helper +
    self-check with one active guard: (a) anchor present → guard passes, self-check green (`1 guard,
    all anchors resolve`); (b) anchor file renamed → `⚠ lost its anchor … (rotted, NOT passed)`, zero
    pass lines, self-check names it; (c) file kept but symbol `compare_digest` removed → the finer
    **symbol** anchor fires (`…:compare_digest`).
- **Signal to watch.** In real projects: do authors actually **wrap** their absence-in-a-file guards
  in `guarded`, or keep writing bare greps that rot silently — the exact gap this exists to close? Does
  the self-check's `·`-when-empty stay quiet enough to not be noise, yet the roll-up WARN get **read**
  when a guard rots? And the honest boundary in practice: how often does a guard's anchor **survive** a
  refactor while its *meaning* silently drifts (semantic rot the grep can't catch)? If semantic drift
  turns out to bite often, the durable fix is to route those guards through the **behavioral-eval /
  judgment** pass (item A), not to over-claim what an anchor check can prove.
- **Retrospect.** *(open — revisit at the next maintenance moment, or the first time a real guard's
  anchor rots in an adopted project.)*

---

## 2026-07-04 — Dependency-vulnerability scan + entropy secret pass (known-CVE + unlabeled-secret coverage)

- **Change.** Built the dependency-vulnerability scan and a stronger secret scanner (ROADMAP item
  **G**) — both in `claude-audit-base.sh`, plus a teaching note in `claude-project-kickoff.md`
  **§1.6** and one Quick-Checklist line. **Part 1:** a new **`DEPENDENCY VULNERABILITIES`** section
  with an `sca_scan` helper that detects the ecosystem from its **lockfile** (`package-lock.json` /
  `yarn.lock` / `pnpm-lock.yaml` · `poetry.lock` / `Pipfile.lock` / `requirements.txt` · `Cargo.lock`
  · `go.sum` · `Gemfile.lock` · `composer.lock`), shells out to that ecosystem's **own** scanner
  (`npm/yarn/pnpm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `bundler-audit`,
  `composer audit`), and gates on the tool's own **high/critical** severity — WARN, not FAIL.
  **Part 2:** an **entropy pass** inside `SECURITY` — awk-computed Shannon entropy (hex ≥ 3.0,
  base64 ≥ 4.5 bits/char) flagging long unlabeled high-entropy strings the prefix-bound `key=` grep
  misses, behind a git-SHA / UUID / placeholder allowlist. `AUDIT_SKIP_SCA=1` skips the
  network-bound Part 1.
- **Rationale (the bet).** The audit already caught *committed* secrets and *unpinned* versions but
  not the thing that bites in practice: **a dependency you already use, correctly pinned, that has
  *since* had a security hole published against it.** The bet: **detect the ecosystem, shell out to
  its native scanner, gate on the tool's own severity** — no bespoke CVE database, no JSON parsing —
  catches that whole class cheaply and stays current for free (the scanner owns the advisory DB).
  Field-evidence backing: AI writes vulnerable code at a flat ~45% rate across model generations
  (Veracode, README citation block), so this is *appreciating* pressure, not a passing-model quirk.
  The load-bearing rule is **`SKIPPED ≠ PASS`**: a scan that couldn't run must degrade **loud**,
  never green — "prose is not a boundary" turned on the audit itself (a check that reads as
  protection but never ran is worse than no check).
- **What it replaced.** Net-new; nothing removed. It is the **other half of the `DEPENDENCIES`
  (restraint — Principle 8) section** — that one keys on the *manifest* and nudges toward fewer +
  pinned deps; this keys on the *lockfile* (the resolved tree a scanner needs) and asks whether a
  pinned dep has a *published* hole. Part 2 **strengthens** the prefix-bound `SECURITY` secret grep
  rather than replacing it — the two run side by side (labeled vs. unlabeled).
- **Shelf-life/risk class.** **Permanent** — its force comes from properties of the world, not a
  model limitation: CVEs get published against pinned deps regardless of how capable the model is
  (and against advisories dated *after* any model's cutoff), and credentials are high-entropy
  strings by construction. Blast-radius is low but **higher than the doc-only R/V/B changes**: this
  is the kit's first audit safeguard that **executes external tools and reaches the network** — so
  it's held to read-only scanners, WARN-only (never FAIL, never a write), a loud-SKIP on every
  couldn't-run path, and an `AUDIT_SKIP_SCA` off-switch.
- **Related ROADMAP item.** **G** (dependency-vulnerability scan) — Hygiene/catch-up type
  (the field knows SCA; do it because it's load-bearing), build-order **step 4** alongside **H**
  (safeguard-rot). Feeds **O**: a conformance check can grep that the scan is wired into a project's
  `scripts/audit.sh`.
- **Commit.** `7771982` (the two-file feature) + this log entry.
- **Design choices worth pointing at.**
  - **Keyed on the lockfile, not the manifest.** A scanner needs the *resolved* dependency tree, so
    Part 1 branches on lockfiles — a clean split from `DEPENDENCIES`, which keys on manifests for the
    pinning nudge. **Polyglot-safe:** the driver loops *every* present lockfile with **no `break`**,
    so a repo carrying two ecosystems gets both scanned.
  - **`SKIPPED ≠ PASS`, via the house neutral `·` bullet.** All four couldn't-run paths —
    scanner-absent, offline / advisory-DB unreachable, no-lockfile, `AUDIT_SKIP_SCA` — print a visible
    `SKIPPED` on the `·` bullet that touches **no** PASS/WARN/FAIL counter and never changes the exit
    code. Never a silent green, never a spurious FAIL.
  - **The classifier's split is deliberately asymmetric.** `command -v` gates "not installed"; exit 0
    is the *only* PASS; a non-zero exit is split — a network/advisory-DB failure → loud SKIP, anything
    else → WARN. **Unknown-nonzero defaults to WARN, never SKIP**, so a real finding can never hide
    behind a false "offline." The network regex is kept **tight to infra-failure signatures** (DNS,
    connection, registry/DB HTTP errors) and was **validated against real npm findings-vs-offline
    output** — a findings report never matches it (proven, not asserted; the sandbox's `502 / audit
    endpoint returned an error` does match, so a blocked registry SKIPs rather than false-greens).
  - **Deliberate don't-over-build line.** No CVE database, no JSON→bespoke-report parsing, no new
    runtime dependency of the audit's own (entropy is `awk`, a standard tool). **Honest per-ecosystem
    caveats** in comments, mirroring the `~line 122` grep-limits candor: yarn classic's exit code is a
    severity *bitmask* that ignores `--level`; `pip-audit` has no severity flag (WARNs on any
    advisory); **bare `pip-audit` on a poetry/pipenv repo scans the active *env*, not the lockfile —
    a weaker PASS**, flagged inline with the export-to-requirements fix.
  - **Entropy allowlist proven non-vacuous.** A 40-hex git SHA has entropy ≈ 4.0 and *would* fire at
    the hex 3.0 threshold — verified by running the pipeline **without** the allowlist (SHA fires)
    vs. **with** it (only the planted bare secret survives). So the allowlist does real work; it isn't
    theatre.
- **Signal to watch.** Do adopting projects actually **install** the ecosystem scanners, or does the
  scan mostly land on `SKIPPED (scanner not installed)` — i.e., does the loud SKIP prompt an install
  (or CI wiring), or get tuned out as noise? Does the entropy pass hold a **low false-positive rate**
  on real source trees, or does it need a tighter allowlist / per-repo annotation escape-hatch? At a
  Hardened-tier project that promotes the vuln scan to **FAIL**, does an unpatched upstream CVE cause
  churn the WARN default was chosen to avoid? If the SKIPs get ignored, the durable fix is **wiring
  the scanner install into setup / CI**, not more prose.
- **Retrospect.** *(open — revisit at the next maintenance moment, or when item O's conformance check
  greps for the scan being wired.)*

---

## 2026-07-04 — Action-risk gates (gate agent actions by reversibility × reach)

- **Change.** Built the action-risk taxonomy (ROADMAP item **R**) — a project-neutral
  classification of what an agent can do *beyond editing its own code* (send a message, publish,
  delete non-git state, spend, change a record other systems read), gated by **reversibility ×
  reach**. Five files: new **§1.3c** teaching in `claude-project-kickoff.md`; a marker-tagged
  **action-risk table** in the §1.5 `CLAUDE.md` skeleton + a Quick-Checklist line (same file); a
  two-way cross-reference in `securing-claude-sessions.md` (the five levels / Level B ↔ §1.3c);
  commented, marker-tagged `ask`/`deny` examples in `templates/project.settings.json`; and a new
  **`ACTION-RISK GATES`** section in `claude-audit-base.sh`. A one-line status note under ROADMAP
  item R points item **O** at the marker.
- **Rationale (the bet).** A risk *table* is Level-A prose, and **prose is not a boundary** — a row
  labelled `ask`/`deny` gates nothing until a real rule exists at Level B (`.claude/settings.json`)
  or the managed floor. The bet: the taxonomy earns its keep only if its dangerous rows become
  **deterministic** ask/deny rules *and* the wiring is machine-checkable. The load-bearing invention
  is a single greppable **marker** (`action-risk`) planted on both the `CLAUDE.md` table and each
  paired settings rule — the join that lets the audit prove "the dangerous classes are enforced, not
  just described," which a bare `ask`/`deny` grep **cannot** do (the floor already ships
  `ask(git push)` + `deny(secret reads)`, so ask/deny always exist).
- **What it replaced.** Net-new taxonomy; nothing removed. It is the **generalization of the §1.3a
  boundary bullet** ("Hard boundaries are deny/ask rules — not a conversational 'don't push'")
  beyond code edits — built *from* that seed and referencing it, not duplicating it. Reuses the root
  `HARNESS_LOG.md`'s `low`/`medium`/`high` risk vocabulary (no fourth scale) and bridges into
  `securing-claude-sessions.md`'s five levels (no parallel framework) — the two anti-goals the
  ROADMAP set for R.
- **Shelf-life/risk class.** **Permanent** — its force is a property of the world, not the model: *a
  control is only as strong as the agent's inability to reach it*, and a sentence in a prompt can be
  reasoned past or dropped on context compaction no matter how capable the model gets. Zero
  blast-radius: documentation + templates with placeholders (never a filled-in instance) + a
  WARN-only presence check that executes nothing.
- **Related ROADMAP item.** **R** (action-risk tiers) — one of the two highest-value cross-check
  newcomers alongside **V** (name the reviewer), build-order step 3. Feeds **O**: the `action-risk`
  marker is precisely what O's "action-risk tiers defined (R)?" conformance check greps — the table
  marker in the *project's* `CLAUDE.md` plus a paired tag on a `.claude/settings.json` rule.
- **Commit.** `77e171e` (the five-file feature) + this log entry.
- **Design choices worth pointing at.**
  - **The marker is the whole mechanism.** `<!-- action-risk -->` on the skeleton table; an
    **inline** `// action-risk` comment on each settings rule. The audit joins the two files by this
    token and **skips the floor's own rules** (they carry no tag) — resolving the "ask/deny always
    exist, so a grep can't tell a floor rule from an action-risk rule" problem a naive check trips on.
  - **Two properties make the check honest, both proven empirically (not asserted).** (1) It keys on
    the **marker**, not on `ask`/`deny` presence — so the floor's own untagged `ask(git push)` does
    **not** silence it (shown: the fixture WARNed *with* `ask(git push)` present). (2) It counts the
    marker only on an **active (non-`//`) settings line** — so the template's own commented
    `action-risk` examples, which ship into *every* project's `settings.json`, can't create a false
    green (shown: the `^\s*//` filter yields empty on the template). That second point was the subtle
    trap: shipping the token in template comments would have **disabled the check for every project**;
    the filter neutralizes it and, as a bonus, correctly ignores commented-out (inactive) rules.
  - **Deliberate under-/over-build line.** A presence/wiring check mirroring the secret-READ and
    behavioral-evals precedents — **not** a table parser. Row-by-row semantic correctness (is *this*
    row wired to the *right* rule?) is left to a read/judgment pass, flagged in an honest code comment
    that mirrors the `~line 122` grep-limits note.
  - **Tier-aware WARN, not FAIL.** A throwaway that only edits its own code omits the table and the
    check stays **silent** — unlike the evals check (which WARNs on absence), because action-risk
    gating is *conditional* on the project having outward actions.
  - **Numbering vs. concept.** §1.3c sits after §1.3b but generalizes §1.3a; it opens with an
    explicit back-reference to that bullet, which is what reconciles the numbering slot with the idea.
- **Signal to watch.** When item **O** ships: does the `action-risk` marker reliably survive into
  generated project `CLAUDE.md` **and** `settings.json`, giving O's grep a stable table↔rule join? Do
  real projects actually **wire** the `ask`/`deny` rows, or leave the placeholder table sitting as
  prose — the exact failure this check exists to catch? And does the **inline-tag** convention hold,
  or do projects tag on the line *above* the rule (which the `^\s*//` filter would miss → a false
  WARN)? If the last, the durable fix is a smarter filter or a more distinctive marker — not more prose.
- **Retrospect.** *(open — revisit when item O's conformance check lands, same trigger as the V entry.)*

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

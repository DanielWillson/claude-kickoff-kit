# Glossary — the kit's vocabulary

The canonical terms the kit uses, chosen for a mix of *simple* and *technically descriptive*.
This is the naming standard, and the docs speak it. Where a widely-used, multi-source industry
term names the same idea, it's noted inline; one-person coinages are credited in the docs
(README / LESSONS), not here. Each term points to the doc(s) that explain or implement it, where
there's a clear home.

## The core frame

- **Harness** — Everything around the fixed model: the instructions it reads, the checks it must
  pass, the boundaries it can't cross, the knowledge it can look up. The model is fixed; the
  harness is what you build. *— [`README.md`](README.md)*
- **Agent = Model + Harness** — The decomposition (Birgitta Böckeler): an agent's reliability
  comes from the harness you build around it, not from the model alone. *— [`README.md`](README.md)*
- **Runtime harness / durable harness** — *Runtime* = Claude Code itself (configured, not built).
  *Durable* = the files the kit leaves in the project (CLAUDE.md, settings, the audit, the wiki,
  the README, the spec) that outlast a single session. *— [`README.md`](README.md)*
- **Directives & verifiers** — The two halves of the durable harness. **Directives** steer the
  agent *before* it acts (CLAUDE.md, the spec, the rules). **Verifiers** check its work *after* it
  acts (the audit, tests, a second agent reviewing). *— [`README.md`](README.md) "How the pieces fit together"*
- **The safety net · safeguards · safeguarding** — The practice where every fixed mistake becomes a
  permanent check, so the harness only ever gets stronger. Each check is a **safeguard**; the
  growing set of them is **the safety net** (you add a strand per fix and never cut one); the habit
  itself is **safeguarding**. *— [`README.md`](README.md), [`LESSONS.md`](LESSONS.md); the mechanics in
  [`claude-project-kickoff.md`](claude-project-kickoff.md) §1.6 + the audit's `REGRESSION GUARDS` section*
- **Builder & judge** — Separate the agent that produces the work from a fresh-context agent that
  grades it — because an agent grading its own work tends to praise it. The judge is independent on
  purpose. (The agent literature often calls this pairing *generator/evaluator*.)
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Part 3*
- **The contract** — CLAUDE.md: the always-loaded, evolving agreement about how to work in this
  project. (One thing named "contract," on purpose — see *the brief*.)
  *— the CLAUDE.md skeleton in [`claude-project-kickoff.md`](claude-project-kickoff.md) §1.5*
- **The brief** — A *frozen, throwaway snapshot* of the shared invariants and data shapes, handed
  to parallel agents at fan-out so they don't drift apart. Named so "contract" refers only to
  CLAUDE.md. *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Part 3*

## Principles & disciplines

- **Front-load verification** — Run each check at the earliest, cheapest point it can run:
  cheap/fast/deterministic ones first, slow/expensive ones later — so a problem is caught at its
  cheapest moment, before the agent builds on top of it. (The common industry name for the
  principle is *shift-left*.) *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Principle 6*
- **Permanent / depreciating / appreciating** — The three shelf-lives of a harness component.
  **Permanent**: its force comes from a property of the world, not the model — keep forever.
  **Depreciating**: it compensates for a model weakness — re-audit at every upgrade.
  **Appreciating**: worth more as the model improves. *— [`README.md`](README.md) "What scales with the model"*
- **Reconcile against code** — Docs (the wiki, the README, CLAUDE.md) check themselves against the
  actual source files, so they can't silently rot. *— [`llm-wiki-kickoff.md`](llm-wiki-kickoff.md)*
- **One writer per file** — In multi-agent work, every file has exactly one owning writer — no two
  agents edit the same file. *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Part 3*
- **Probe-first** — Verify what your actual environment supports before assuming a feature exists;
  treat the harness like a dependency you check, not one you trust on faith.
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Part 3*

## Setup & the safety floor

- **The floor** — The unbreakable safety baseline the agent can't weaken: the OS sandbox plus
  deny/ask rules. The *per-repo floor* is the committed `.claude/settings.json`; the *managed / hard
  floor* is the root-owned, machine-level settings the agent can't touch.
  *— [`securing-claude-sessions.md`](securing-claude-sessions.md), [`CHEATSHEET.md`](CHEATSHEET.md), [`templates/`](templates/)*
- **The five levels** — The canonical ladder of security controls, weakest to strongest:
  conversation/mode → project config → OS sandbox → managed settings → server-side. (The
  cheatsheet's "seven layers" is the same ladder split finer — "five levels" is the canonical name.)
  *— [`securing-claude-sessions.md`](securing-claude-sessions.md)*
- **The intake** — The nine up-front questions (stack, sensitive paths, deploy target, who else
  commits, etc.) that shape a project's settings, CLAUDE.md, and hardening.
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) §1.0*
- **Lean / Standard / Hardened** — The three setup tiers, scaled to a project's lifespan and risk.
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) §1.0*
- **The foundation** — The shared, load-bearing code (schema, types, invariants, design tokens) the
  lead builds inline — never delegated to a fanned-out agent.
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Part 3*

## Tests & baselines

- **Critical-path test** — One integration test through the make-or-break end-to-end flow, proving
  the pieces work *together* — part of the Definition of Done alongside the unit tests.
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Part 3*
- **Baseline** — A frozen snapshot of the current known-correct output, captured *before* a refactor
  and asserted unchanged *after*, to prove behavior didn't silently drift. (The classic testing
  terms for this are a *test oracle* or *golden master*.)
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Principle 10*

## Workflow & states

- **Preflight** — The fixed session-start routine: read the git log → the progress log → the task
  list → pick the top task, *before* doing any work.
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Part 3*
- **The loop trap** — When an agent loops unproductively on a bug it can't fix; the signal to stop,
  reset the context, and restructure the problem by hand.
  *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Principles 7 & 9*

## Codebase qualities

- **Harness-friendly / harness-friendliness** — A property of the *codebase*: how well it lets an
  agent work *and check its own work* (fast tests, clear structure, a CLI that reports results, good
  logs). Harness-friendly code gives the agent the feedback it needs; unfriendly code makes it flail
  blind. *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Principle 1*
- **Harness-friendly features** — The specific things that make a codebase harness-friendly: a
  Makefile `test` target, a `--json` flag, clear folders, `PASS`/`FAIL` output. The ingredients;
  harness-friendliness is their sum. *— [`claude-project-kickoff.md`](claude-project-kickoff.md) Principle 1*

## Kept as-is

`floor` · `intake` · `Lean / Standard / Hardened` · `one writer per file` · `probe-first` ·
`reconcile` — plus the standard/borrowed vocabulary the kit speaks on purpose (deny/ask/allow, the
sandbox, context rot, defense in depth, least privilege, "prose is not a boundary," "humans steer /
agents execute," etc.). *Security vocabulary lives in [`securing-claude-sessions.md`](securing-claude-sessions.md)
and [`CHEATSHEET.md`](CHEATSHEET.md).*

## Roadmap items — built

Shipped into the kit; each points to where it lives.

| Item | Name | What it is | Lives in |
|---|---|---|---|
| A | **Behavioral evals** | Saved tests of the agent's *judgment* (not the code), run at model/CLAUDE.md/skill changes. | [`claude-eval-base.sh`](claude-eval-base.sh), [`evals-template/`](evals-template/), kickoff §1.6b, audit `BEHAVIORAL EVALS` |
| B | **Harness scorecard** | A monthly trend of cheap numbers showing whether the harness is paying off. | [`scripts/harness-metrics.sh`](scripts/harness-metrics.sh), kickoff §1.6a |
| V | **Name the reviewer** | Every project names *who* reviews the agent's work and *what source of truth* they check against. | kickoff §1.5 (`## Review` block) + Quick Checklist |
| X | **Harness change log** | An append-only record of what changed in the harness and why, with a **portable, machine-legible schema** so an agent can read a *trusted* sibling repo's log and **propose** borrowings — human decides, never auto-applied. | [`HARNESS_LOG.md`](HARNESS_LOG.md) (portable schema), kickoff §1.6a (cross-repo learning), [`wiki/harness-log.md`](wiki/harness-log.md) |
| R | **Action-risk tiers** | Classify the agent's actions by reversibility × reach; wire the dangerous ones to deny/ask, not prose. The CLAUDE.md table names each gate's *exact settings rule*; the audit joins table↔rule **by that rule string** (comment-free — settings is strict JSON). | kickoff §1.3c + the `<!-- action-risk -->` table in §1.5 + the audit/conformance command-pattern join (§1.6) + [`templates/project.settings.json`](templates/project.settings.json) |
| G | **Dependency-vulnerability scan** | An audit step that detects each ecosystem from its lockfile and shells out to that ecosystem's own scanner (npm/pip/cargo/…) to flag dependencies with published CVEs, plus an entropy pass that catches unlabeled secrets the `key=` grep misses. | [`claude-audit-base.sh`](claude-audit-base.sh) (`DEPENDENCY VULNERABILITIES` + entropy pass in `SECURITY`) + kickoff §1.6 + Quick Checklist |
| H | **Safeguard-rot check** | Each safeguard asserts its own anchor so it WARNs (rotted) instead of silently dying green; a self-check audits the audit's own guards. Structural rot only — semantic drift is a human read. | [`claude-audit-base.sh`](claude-audit-base.sh) (`guarded` helper + `SAFEGUARD SELF-CHECK`) + kickoff §1.6 + Quick Checklist |
| O | **Adoption check + fan-out verifier** | A roster check that a repo *actually* adopted the kit's artifacts (CLAUDE.md + routing/reviewer blocks, the secret-read floor, a valid audit, evals, ≥3 wiki pages, action-risk gates), rolled into an adoption scorecard; FAILs only the irreducible floor, WARNs what a lean project may skip, and fans out one sub-agent per area so no single context reads the whole kit. | [`scripts/kit-conformance.sh`](scripts/kit-conformance.sh) + kickoff §1.6c (teaching + fan-out playbook) + [`claude-project-adoption.md`](claude-project-adoption.md) DoD + Quick Checklist |
| Y | **Kit-update proposals** | Re-review a repo against a *newer* kit: re-run the adoption guide's evaluate→propose over the delta since the version stamp, propose fit-appropriate retrofits, the human decides, then append a reviewed-through entry that **advances the baseline** so already-declined items aren't re-raised. Docs-only, on-prompt, propose-never-apply. | [`claude-project-adoption.md`](claude-project-adoption.md) §6 + kickoff §1.6a (fill the version stamp) |
| W | **Harness manifest** | A tier-optional root registry of the harness's own parts, tracking the one axis its siblings don't — *what each part assumes × when last verified × the event that makes it stale* — grouped by shelf-life class. Not presence (that's conformance) nor history (that's the log). | [`HARNESS_MANIFEST.md`](HARNESS_MANIFEST.md) (template) + kickoff §1.6a + [`wiki/harness-manifest.md`](wiki/harness-manifest.md) (kit's own) |
| J | **Post-upgrade re-verify** | Treat a Claude Code *tool* upgrade like a model upgrade — a scheduled maintenance event: re-run §1.4's "prove it bites" checks, because an upgrade can silently drop a setting (CC 2.1.201 discards a whole settings.json on a `//` comment). Realized as the manifest's re-verify trigger. | kickoff §1.4 + §1.6a + README shelf-life doctrine + the [`HARNESS_MANIFEST.md`](HARNESS_MANIFEST.md) trigger column |

## Roadmap items — planned

Names locked; definitions use the vocabulary above. Build state and detail live in
[`ROADMAP.md`](ROADMAP.md).

| Item | Name | One-line definition |
|---|---|---|
| C | **Flight recorder** | A durable record of what an agent did during a run, so you can inspect *why* it went wrong or got expensive. |
| S | **Non-git rollback** | Snapshot-and-recover rituals for state git doesn't cover (databases, hosted configs, deploys, external backends). |
| E | **Spec-as-source** | Treating the spec as a living, reconciled source of intent — not a fill-in-once doc. |
| D | **Cross-project memory** | A queryable knowledge layer for when per-project markdown files stop scaling across many projects. |
| T | **Tool inventory** | A list of every tool/connector the agent has — scopes, where its credential lives, how to disable it. |
| U | **Incident runbook** | The forward "when an agent does damage" procedure: contain → revoke → identify what was touched → undo → add a safeguard. |
| I | **Baseline for fuzzy output** | The tolerance/rubric version of the baseline check, for output that isn't exactly reproducible. |
| F | **Untrusted-content rule** | Fetched/tool content is *data, not instruction* (the sandbox limits damage, not the hijack). |
| K–N | **Internal-consistency fixes** | Four small edits reconciling places the kit contradicts itself. |

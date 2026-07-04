# Glossary — the kit's vocabulary

The canonical terms the kit uses, chosen for a mix of *simple* and *technically descriptive*.
This is the naming standard the docs should converge on. `(was: …)` marks a term that replaced
an earlier name — useful until the rename pass lands across the docs.

## The core frame

- **Harness** — Everything around the fixed model: the instructions it reads, the checks it must
  pass, the boundaries it can't cross, the knowledge it can look up. The model is fixed; the
  harness is what you build.
- **Agent = Model + Harness** — The decomposition (Birgitta Böckeler): an agent's reliability
  comes from the harness you build around it, not from the model alone.
- **Runtime harness / durable harness** — *Runtime* = Claude Code itself (configured, not built).
  *Durable* = the files the kit leaves in the project (CLAUDE.md, settings, the audit, the wiki,
  the README, the spec) that outlast a single session.
- **Directives & verifiers** *(was: guides & sensors)* — The two halves of the durable harness.
  **Directives** steer the agent *before* it acts (CLAUDE.md, the spec, the rules). **Verifiers**
  check its work *after* it acts (the audit, tests, a second agent reviewing).
- **The safety net · safeguards · safeguarding** *(was: the ratchet)* — The practice where every
  fixed mistake becomes a permanent check, so the harness only ever gets stronger. Each check is a
  **safeguard**; the growing set of them is **the safety net** (you add a strand per fix and never
  cut one); the habit itself is **safeguarding**. (The field also calls this "compound
  engineering.")
- **Builder & judge** *(was: doer/judge)* — Separate the agent that produces the work from a
  fresh-context agent that grades it — because an agent grading its own work tends to praise it.
  The judge is independent on purpose.
- **The contract** — CLAUDE.md: the always-loaded, evolving agreement about how to work in this
  project. (One thing named "contract," on purpose — see *the brief*.)
- **The brief** *(was: CONTRACT.md)* — A *frozen, throwaway snapshot* of the shared invariants and
  data shapes, handed to parallel agents at fan-out so they don't drift apart. Renamed so
  "contract" refers only to CLAUDE.md.

## Principles & disciplines

- **Front-load verification** *(was: keep quality left)* — Run each check at the earliest, cheapest
  point it can run: cheap/fast/deterministic ones first, slow/expensive ones later — so a problem
  is caught at its cheapest moment, before the agent builds on top of it.
- **Permanent / depreciating / appreciating** *(permanent was: invariant)* — The three shelf-lives
  of a harness component. **Permanent**: its force comes from a property of the world, not the
  model — keep forever. **Depreciating**: it compensates for a model weakness — re-audit at every
  upgrade. **Appreciating**: worth more as the model improves.
- **Reconcile against code** — Docs (the wiki, the README, CLAUDE.md) check themselves against the
  actual source files, so they can't silently rot.
- **One writer per file** — In multi-agent work, every file has exactly one owning writer — no two
  agents edit the same file.
- **Probe-first** — Verify what your actual environment supports before assuming a feature exists;
  treat the harness like a dependency you check, not one you trust on faith.

## Setup & the safety floor

- **The floor** — The unbreakable safety baseline the agent can't weaken: the OS sandbox plus
  deny/ask rules. The *per-repo floor* is the committed `.claude/settings.json`; the *managed / hard
  floor* is the root-owned, machine-level settings the agent can't touch.
- **The five levels** — The canonical ladder of security controls, weakest to strongest:
  conversation/mode → project config → OS sandbox → managed settings → server-side. (The
  cheatsheet's "seven layers" is the same ladder split finer — "five levels" is the canonical name.)
- **The intake** — The nine up-front questions (stack, sensitive paths, deploy target, who else
  commits, etc.) that shape a project's settings, CLAUDE.md, and hardening.
- **Lean / Standard / Hardened** — The three setup tiers, scaled to a project's lifespan and risk.
- **The foundation** *(was: the trunk)* — The shared, load-bearing code (schema, types, invariants,
  design tokens) the lead builds inline — never delegated to a fanned-out agent.

## Tests & baselines

- **Critical-path test** *(was: spine test)* — One integration test through the make-or-break
  end-to-end flow, proving the pieces work *together* — part of the Definition of Done alongside
  the unit tests.
- **Baseline** *(was: oracle / golden oracle)* — A frozen snapshot of the current known-correct
  output, captured *before* a refactor and asserted unchanged *after*, to prove behavior didn't
  silently drift.

## Workflow & states

- **Preflight** *(was: the bearings ritual)* — The fixed session-start routine: read the git log →
  the progress log → the task list → pick the top task, *before* doing any work.
- **The loop trap** *(was: the slop zone)* — When an agent loops unproductively on a bug it can't
  fix; the signal to stop, reset the context, and restructure the problem by hand.

## Codebase qualities

- **Harness-friendly / harness-friendliness** *(was: harnessability)* — A property of the
  *codebase*: how well it lets an agent work *and check its own work* (fast tests, clear structure,
  a CLI that reports results, good logs). Harness-friendly code gives the agent the feedback it
  needs; unfriendly code makes it flail blind.
- **Harness-friendly features** *(was: ambient affordances)* — The specific things that make a
  codebase harness-friendly: a Makefile `test` target, a `--json` flag, clear folders, `PASS`/`FAIL`
  output. The ingredients; harness-friendliness is their sum.

## Kept as-is

`floor` · `intake` · `Lean / Standard / Hardened` · `one writer per file` · `probe-first` ·
`reconcile` — plus the standard/borrowed vocabulary the kit speaks on purpose (deny/ask/allow, the
sandbox, context rot, defense in depth, least privilege, "prose is not a boundary," "humans steer /
agents execute," etc.).

## Roadmap items (planned additions to the kit)

Names locked; definitions use the vocabulary above. Build state lives in `ROADMAP.md`.

| Item | Name | One-line definition |
|---|---|---|
| A | **Behavioral evals** | Saved tests of the agent's *judgment* (not the code), run at model/CLAUDE.md/skill changes to catch behavior regressions. |
| B | **Harness scorecard** | A monthly trend of cheap numbers showing whether the harness is actually paying off. |
| C | **Flight recorder** | A durable record of what an agent did during a run, so you can inspect *why* it went wrong or got expensive. |
| D | **Cross-project memory** | A queryable knowledge layer for when per-project markdown files stop scaling across many projects. |
| E | **Spec-as-source** | Treating the spec as a living, reconciled source of intent — not a fill-in-once doc. |
| F | **Untrusted-content rule** | Fetched/tool content is *data, not instruction* (the sandbox limits damage, not the hijack). |
| G | **Dependency-vulnerability scan** | An audit step that flags libraries with known published security holes, plus stronger secret detection. |
| H | **Safeguard-rot check** | Makes each safeguard verify its own target still exists, so it fails loud instead of silently dying. |
| I | **Baseline for fuzzy output** | The tolerance/rubric version of the baseline check, for output that isn't exactly reproducible. |
| J | **Post-upgrade re-verify** | Re-running the "prove it still bites" checks after a Claude Code upgrade — a tool upgrade is a maintenance event. |
| K–N | **Internal-consistency fixes** | Four small edits reconciling places the kit contradicts itself (size rule vs. skeleton, paste rule, date-stamps, Principle 4 ↔ 3.11). |
| O | **Adoption check + fan-out verifier** | A script that checks a repo actually adopted the kit's artifacts, run by focused sub-agents so no one context reads the whole kit. |
| R | **Action-risk tiers** | Classify the agent's possible actions by reversibility × reach, and wire the dangerous ones to deny/ask (not prose). |
| S | **Non-git rollback** | Snapshot-and-recover rituals for state git doesn't cover (databases, hosted configs, deploys, external backends). |
| T | **Tool inventory** | A list of every tool/connector the agent has — scopes, where its credential lives, how to disable it. |
| U | **Incident runbook** | The forward "when an agent does damage" procedure: contain → revoke → identify what was touched → undo → add a safeguard. |
| V | **Name the reviewer** | Every project names *who* reviews the agent's work and *what source of truth* they check against. |
| W | **Harness manifest** | A running list of the harness's own parts, each tagged with what it assumes and when it was last checked — so an upgrade is a checklist, not a guess. |
| X | **Harness change log** | An append-only record (`HARNESS_LOG.md`) of what changed in the harness and why — portable enough for cross-repo learning. |
| Y | **Kit-update proposals** | The adoption skill re-reviews a repo and proposes upgrades when the kit itself has improved since adoption. |

## Still to do

The **rename pass across the docs** — README, LESSONS, the kickoff guide, the security docs, and
ROADMAP still use the old terms (guides/sensors, the ratchet, the oracle, etc.). This glossary is
the target; the sweep applies it (and untangles the collisions above) as one careful, verified edit.

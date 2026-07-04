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

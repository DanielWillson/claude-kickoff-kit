# Fable Review — Multi-Lens Analysis of the Claude Harness Kit

**Date:** 2026-07-06
**Method:** Fable 5 read the core docs firsthand (ROADMAP, README, the full kickoff guide, LESSONS, glossary, CHEATSHEET, SKILL.md, the adoption guide, HARNESS_LOG); seven independent **Sonnet 5 (max effort)** agents each deep-read one area (~1.18M subagent tokens, 279 tool calls), reproduced bugs in scratch repos, and live-verified claims against vendor docs and primary sources; Fable synthesized. The kit was evaluated **as if all ROADMAP items A–Y were already built as designed** — gaps named here are beyond the roadmap.
**Per-area reports:** [entry surface](01-entry-surface.md) · [kickoff guide](02-kickoff-doc.md) · [adoption & cross-repo](03-adoption-crossrepo.md) · [security](04-security.md) · [evals & metrics](05-evals-metrics.md) · [knowledge layer](06-knowledge-layer.md) · [outsider read-through](07-outsider-readthrough.md)

**The questions asked (by the maintainer):** the kit's three intentions are (1) a kicking-off point for new Claude Code projects, (2) a skill for existing projects to adopt harness best practices, (3) a teaching tool for people stepping past vibecoding. Against those: (a) how well does it accomplish each, (b) highest-impact improvements, (c) what to understand deeply vs. trust Claude on, (d) what's missing beyond those lenses, (e) what it does exceptionally well, (f) what to teach/build with each member of a five-person CS/ops/data team, (g) what becomes unimportant vs. stays vital as models and harnesses improve over 1–2 years.

---

# The verdict in one paragraph

This kit is a genuinely unusual artifact: its epistemic discipline (verified citations, honest scaling, self-application) puts it ahead of nearly everything published in this space, and its security teaching is the best-written material of its kind the agents or I have seen. But it currently serves the three intentions in a lopsided order — **adoption (2) ≥ serious kickoff (1) ≫ silly kickoff ≫ teaching (3)** — and the fan-out found something sharper than a gap: **several of the kit's own verifiers fail exactly the "prove it bites" test the kit preaches**, including an eval runner that *crashes the moment it catches its first real regression*. The teaching intention, which is also what the team in (f) needs, is the furthest from realized: a roleplayed non-engineer couldn't complete step zero.

---

## (a) How well does it accomplish each goal?

**As a kickoff point (intention 1): strong for serious projects, heavy for silly ones.** The tiering is real, not cosmetic — the agent that read all 1,678 lines confirmed Lean genuinely skips things, and the "scale honestly" gates recur consistently through all 214 checklist/list items. The intake-first design, the copy-paste floor, and the bite-tests all work as documented (the pre-commit hook's index-bit-vs-disk-bit sequence was reproduced command-for-command and is correct — a detail most engineers would get wrong). Two misses: Part 0's full machine-hardening ceremony reads as an unconditional prerequisite even for a toy (the fact that it's skippable in favor of the per-repo floor lives in one buried parenthetical at line 333), and there's no worked Lean example — a Lean reader synthesizes their path by *subtracting* from a Standard-oriented narrative. Time-to-first-fun is high, and the failure mode the kit itself names ("over-setup gets skipped wholesale") is a live risk at the silly end.

**As an adoption skill (intention 2): the best-designed part of the kit — undermined by its verifier.** Evaluate→interview→propose, secret-as-live-incident triage (gitignore → `git rm --cached` → *rotate* → audit FAIL, before anything else), baseline-before-improvement, wiki-from-history: the adoption agent called this "more concrete and operationally correct than most retrofit guidance." But the payoff step — "verify with a verifier, not by re-reading this list" — has holes: `kit-conformance.sh` gives a **clean PASS on a malformed `.claude/settings.json`** (it greps text but never JSON-validates, while it *does* `bash -n` its sibling audit.sh three sections above — an inconsistency, not a scope decision), and a **false FAIL on a legitimate AGENTS.md-only repo** (hardcoded filename, despite the kit's own "Claude reads either" policy). Both reproduced on fixtures.

**As a teaching tool (intention 3): strong philosophy, missing on-ramp — roughly backwards from what the learner needs first.** The roleplay agent (playing a CS manager with a year of chat-Claude and one vibecoded tool) found the README's conceptual sections genuinely landed — the four-level safety ladder, "start skeptical," model+harness — and could be repeated to a boss "without embarrassment." Then the operational cliff: nothing anywhere says what Claude Code *is* (a terminal app distinct from claude.ai), how to install it, or what a terminal prompt is; "clone or symlink this repo to `~/.claude/skills/harness-kit`" packs three unperformable operations into one clause; MCP/CLI/CI are never defined; Part 0 assumes admin rights with no MDM-laptop branch; and there is no path at all for someone whose prior "project" lived in a chat window or a no-code tool — Intake Q1 presupposes a stack. The glossary — built to solve exactly this reader's problem — is linked from *nowhere* a reader would organically pass (grep-confirmed: zero links from README, kickoff, SKILL.md).

---

## (b) Highest-impact improvements

Ranked. The first is qualitatively different from the rest.

**1. Turn "prove it bites" on the kit's own tooling — fix the found bugs and add fixture tests for every shipped script's FAIL path.** The fan-out found, and reproduced:

- `claude-eval-base.sh:101` — a golden-eval **failure crashes the whole runner** (`«$expected»`'s UTF-8 guillemet byte gets consumed into the variable name → unbound-variable error) on stock and Homebrew bash. The tool's teaching moment ("your eval just caught something!") presents as a broken tool. Tellingly, ROADMAP annotates H, O, and X with "proven on fixtures" — item A has no such annotation, and that's exactly where the bug lives.
- The rubric judge's verdict extraction (`grep -m1 -oE 'PASS|FAIL'` over the judge's *entire output*) can flip a verdict in either direction — proven both ways.
- `kit-conformance.sh`: no JSON-validity check on the settings floor (false PASS); hardcoded `CLAUDE.md` (false FAIL).
- The action-risk mechanism's prescribed **inline `//` tag on a JSON array element is invalid JSON** — the template ships it, conformance blesses it, Python's parser rejects it, and the kit's own dogfooded settings file quietly avoids the risky form it prescribes to others. Verify what Claude Code's parser actually accepts before this false-PASS ships into projects.
- `harness-metrics.sh` counts commented-out example checks — 24% inflation on the kit's own reference template, and it worsens (not fades) as a real audit.sh accumulates.

A `kit-tests/` fixture suite that deliberately breaks each artifact and asserts the failure surfaces is the kit's own doctrine, aimed inward. This is also the highest-credibility move: a kit about verification whose verifiers are verified.

**2. Build the absolute-zero on-ramp (unlocks intention 3 and the team).** One ordered document: what Claude Code is → install → a one-hour guided Lean kickoff on a real toy, showing each artifact created and each safeguard *firing* (stage a fake `.env`, watch it block). Link the glossary from the front door. Define MCP/CLI/CI once. Add the MDM/no-admin branch to Part 0. People learn this material by watching a deny rule fire, not by reading about pecking orders.

**3. Make the managed floor's absence loud, somewhere, ever.** The security agent's top finding: the kit's *only* hard guarantees live in a manual, root-privileged, hand-placed file with no installer and no durable verification — and conformance treats it as a permanent silent SKIP by design. A team could roll the kit out fleet-wide, pass every check, and run entirely on soft, agent-editable guarantees indefinitely. A small `verify-floor` script (read the root-owned file's critical keys — checking *content* doesn't violate the SKIPPED≠PASS principle the way inferring from absence would) + two lines backporting the machine-cred denies (`~/.ssh/**`, `~/.aws/**`) into `templates/project.settings.json` — which the kit's own `.claude/settings.json` already does but the template it hands to others doesn't.

**4. Ship the wiki's maintenance engine as code, or re-scope it.** The engine (lint/reconcile/stale/coverage/gaps) is the wiki's entire defense against becoming "confident lies" — and it exists only as a 704-line prose spec. Every sibling verifier ships runnable; this one doesn't, the audit can't detect its absence, and the likeliest kickoff outcome is "wrote SCHEMA.md and two pages, never built reconcile" — precisely the worse-than-no-wiki state §1 warns about.

**5. Split the kickoff driver from the teaching.** The ~32K-token doc is read whole by the session that must then execute it faithfully — the kit's own context-is-a-budget doctrine, unapplied to itself (the one place its "do as I say" and "do as I do" have visibly diverged). An agent-facing runbook per tier + the rationale kept as human-facing companion would cut the execution context by more than half.

**6. A hygiene batch**, each cheap: dedupe the built-status tables (glossary says A/B/G/V built; ROADMAP's summary table doesn't — the kit's own "contradictory docs" failure mode, live in the repo); track and index `prompts/` (untracked, unreferenced, and two of four files already rotted — a stale repo path — within 48 hours, with no item-H-style check pointed at it); banner `styleguide.html` as a real example to study-then-replace (it's 1,279 lines of a personal app, with named real people in it); ship a CI workflow template (the audit's own comments argue audit-in-CI is strictly superior to the pre-commit hook it *does* ship wiring for); an MCP/WebFetch deny-by-default template line; flag the `docker *` sandbox exclusion as the one-command root escape it is.

---

## (c) What to understand deeply vs. trust

The kit itself contains the right rule, and the eval-runner bug is its perfect cautionary tale: **trust construction wherever failure is loud and behaviorally verifiable; understand deeply wherever failure is silent.**

**Understand deeply (this is the expertise, and it transfers to every AI system you'll ever deploy):**

1. **Control strength = the agent's inability to reach it.** Where a rule *lives* — not what it says — determines whether it's a wall or a preference. Includes the specifics: stock Claude Code reads `~/.ssh` unprompted; the sandbox is Bash-only (native Read/Write/Edit, WebFetch, MCP never cross it); deny rules are a sieve; an allowlist can't un-leak a read.
2. **Why self-report is worthless and verification is the whole game.** Builder/judge separation, correlated errors within one context, "the check passed" ≠ "the thing it describes is true." The conformance agent had to discover empirically that a settings file's failure mode is *silent* — that's the humbling lesson an expert has internalized.
3. **Context as a budget; knowledge placement.** Explains most day-to-day agent behavior, and why a boundary stated in chat isn't one.
4. **Reversibility × reach.** The kit gives the taxonomy; classifying *your* actions is irreducibly your judgment. This is the single most transferable skill to non-code work.
5. **The shelf-life doctrine itself** — so you know what to re-audit at each model upgrade rather than cargo-culting your own harness.
6. **Golden-vs-rubric choice and durable skepticism toward any LLM-judge verdict** — including your own harness's.

**Safe to trust Claude on (verify behaviorally, don't hand-audit):** the JSON/glob syntax of settings files (all key names were independently verified current, including obscure ones); the bash internals of the scripts *once fixture-tested* — the `guarded()` rot-detector and the conformance exit-code arithmetic both survived independent adversarial re-verification; the wiki bookkeeping; citation formatting. The precondition matters: trust is earned per-artifact by watching its FAIL path fire once, not granted by genre.

---

## (d) Missing beyond the three lenses

- **The kit's own integration eval.** Nothing runs a full kickoff against a fixture repo and asserts conformance passes end-to-end. (The lens above, made permanent.)
- **A fleet layer.** The maintainer will soon have many kit-derived repos. X gives portable logs and D gestures at queryable memory, but nothing aggregates: conformance across all repos, one view of which floors are installed, which harnesses are rotting. This is where the real leverage compounds.
- **A data-in-context doctrine for knowledge work.** The dev/prod-data-boundary block exists, but "what customer data / PII may enter a session's context, and what may leave via MCP connectors" is the governance question for non-code use — and it's the first question a CS team hits (their tools are Intercom, CRM, email). The content/editorial appendix proves archetypes work; an **ops/analyst archetype** is the missing one.
- **The human-verification layer of the teaching goal.** Nothing checks that the *person* learned — no exercises, no "break this fixture and watch the guard fire" drills. Item U (runbook) has no fire-drill companion either.
- **Eval/harness cost math.** The docs say evals "cost tokens" but never give a number anyone could budget against; B stubs cost-per-merged-change. For teaching non-engineers, "this habit costs ~$X/month" is load-bearing.
- **A rubric-judge identity record** — a stored verdict doesn't record which judge model graded it, so trend comparisons across judge upgrades are quietly invalid (item J's discipline, unextended).

---

## (e) What it does exceptionally well

Being stingy, five things — several confirmed by independent reproduction, which is itself the point:

1. **Epistemic hygiene that survives adversarial checking.** Five marquee citations live-fetched against primary sources matched verbatim, including the Böckeler byline correction that requires actually opening the article. Lesson 7 (folklore wearing citation's clothes) is the best single page in the kit. Almost nothing in this genre survives this test; this kit was *built* to.
2. **The security teaching, at three deliberate depths.** The reachability principle applied consistently — every template comment reasons from the one sentence — and the "deny rules are a sieve" analysis verified *current-to-the-week* against vendor docs, including hostname-only proxy semantics and the domain-fronting caveat.
3. **The conformance exit-model** (FAIL only what no correct adoption could omit / WARN what a lean project may skip / SKIPPED ≠ PASS) — a genuinely transferable answer to how a checker stays honest across project scales, better than most real CI tooling.
4. **Honest scaling and refusal to fabricate**, everywhere: "human note required" instead of fake zeros, "don't build the ledger below volume," LLM-judge noise disclosure that actually shapes the design rather than sitting as a bolted-on disclaimer.
5. **Self-application.** The kit keeps its own wiki, ran its own depreciation audit, reversed two of its own stale rules, and confesses its own past misattribution. The `guarded()` rot-detector — "how would my own greps tell me they stopped protecting anything" — is an idea not seen in field tooling.

---

## (f) The team

*(Context: the maintainer manages a data analyst, a customer success manager, a head of customer success, a customer service specialist, and an operations specialist — and wants to make each capable of building with AI and prepared for how AI reshapes their roles.)*

The common core for all five — before any role split — is **LESSONS.md + securing-claude-sessions.md + the action-risk instinct** (reversible? stays inside the project? then it can run; otherwise it gates). That, plus the safety-net habit (every mistake becomes a permanent check) and the provenance rule (a naked factual claim is a defect), is the durable literacy. None of them should read the kickoff doc except the analyst. Note the dependency: **the on-ramp from (b)#2 is the prerequisite for everything below.**

**Data analyst** — the one person for whom the full engineering track pays off. Teach git properly, then a real kit adoption on an analysis repo. Their world *is* Principle 10: calculations that must reconcile → golden-output baselines are their native artifact, and audit greps encoding data invariants (row counts, reconciliation totals, "the unit is 1,200W — NOT 800W") are their safety net. Where the role goes: from producing dashboards to **owning the verification layer for AI-produced analysis** — the person who can say "this number is right, and here's the check that proves it." That role appreciates as generation gets cheap.

**Customer service specialist** — most exposed role, and the most elegant reframe available: the move from *answering* tickets to **writing the evals that grade the system that answers them**. They are the best judge of a good answer; golden cases and rubrics for the support AI are item A with zero code, and the §1.5 "Verified facts / corrected claims" block is literally designed for their knowledge ("the bot keeps saying X; the correct answer is Y; here's the regression check"). Have them own the support bot's eval suite and its incident pages. That is a durable, senior skill.

**CSM** — knowledge-work automation with an outward-facing edge. Everything they touch is irreversible+outward (emails, CRM records, customer comms) → teach action-risk tiers *first*, and the untrusted-content rule (they process customer-authored text all day — that's a prompt-injection surface). Build: propose-only automations — account-health digests, QBR prep, renewal-risk summaries — where AI drafts with citations to the ticket/call and the human sends. The provenance rule is their quality bar.

**Head of CS** — they *are* item V. Their leverage isn't building; it's the four named reviewer capabilities: **write a clear spec, define "done," verify against a named source of truth, work in small batches.** Teach them spec-writing and eval-thinking; have them set the team's action-risk policy (what may an agent ever send to a customer unattended? — that's their call, wired as gates, not prose) and own the team's HARNESS_LOG. Their future job is managing a blended human+agent team where review capacity is the constraint they allocate.

**Operations specialist** — highest blast radius, least git coverage. Their entire world is **non-git state** (no-code backends, automation scenarios, billing systems), so items S, T, U are *their* curriculum: snapshot-before-change rituals, dry-run + batch-cap patterns, the tool inventory (they'll accumulate connectors fastest), and the incident runbook. Build one automation end-to-end *with* them — snapshot ritual, `--dry-run` mode, ask-gate, batch cap — and make it the template every subsequent one copies.

---

## (g) What becomes unimportant vs. stays vital (1–2 years)

The kit's own shelf-life doctrine already answers this well, and the agents' mechanism-level reasoning mostly endorses its placements. Where it can be sharpened:

**Depreciating fastest (already visibly rotting):**

- **CHEATSHEET-class mechanics.** The permission engine shipped half a dozen behavior changes *within the 2.1.x line alone* (verified live). Exact key names, the recognized-Bash-readers list, classifier drop-lists — vital function, weeks-scale content. Item J/W/M is the right hedge; the gap is that only 2 of dozens of such claims in the kickoff doc are date-stamped, so you can't tell which sentences are due.
- **Part 3's operational mechanics.** Keep-awake, quota timing, prompt-proofing, worktree choreography — runtimes are absorbing all of it (cloud/scheduled runs already moot `caffeinate`). The kit has *already* reversed two of its own Part 3 rules; expect that to keep happening. The judgment layer (one writer per file, foundation-inline, don't trust self-reports) survives.
- **The context-window justifications specifically.** O's fan-out is argued from "one session can't hold the kit" — that reason weakens as windows grow. But note the deeper reason survives: "Confident and Wrong" is a verification-incentive problem, not a context-size problem. Keep the practice, expect to rewrite the *why*.
- **Possibly the hand-rolled wiki engine.** The knowledge agent confirmed live that Claude Code's native auto-memory is *already* wiki-shaped (index + cross-linked topic files). If a project-scoped, git-tracked, reconciled variant ships natively, llm-wiki-kickoff §4 becomes configuration instead of construction. The doctrine that survives is the *criterion*: knowledge must be inspectable, versioned, and reconciled against ground truth — "files not memory" is the current implementation of that rule, not the rule itself. This is the kit doctrine most likely to be half-wrong in two years.

**Appreciating (the kit's durable identity):**

- **Security-by-reachability.** More autonomy → more vital, never less. Prompt injection remains unsolved; "where does this rule live and who can change it" is the right question under any future schema.
- **Evals and the verification layer.** ROADMAP §4 is right that evaluating non-deterministic agents is the field's hardest problem — "did this change help" is a comparison problem that capability *scales*, not solves. One sharpening: METR's ~7-month task-horizon doubling implies eval suites must **grow with autonomy** — 8–15 fixtures will read as quaint.
- **Action-risk gating.** As agents gain tools and reach, reversibility×reach becomes the central governance question of the whole field — for companies, not just repos. This may quietly be the kit's most important export, and it's the piece that generalizes furthest beyond code.
- **Reconcile-against-truth and provenance.** Docs rot at any model IQ; a smarter agent acts on a stale belief *longer and more confidently* before a human notices.
- **The cross-repo/fleet layer (X→Y→D).** Network-effect value, independent of model quality.

**The strategic risk to name plainly:** the kit's structural bet is that individuals hand-assemble harnesses from documents. Vendors are absorbing the harness — sandboxing defaults, native memory, built-in review skills, plan mode. The kit's durable position isn't "the source of the machinery"; it's **the judgment layer that decides what the machinery should do, and the verification discipline that proves the vendor's defaults actually bite on your machine**. Items J, W, and Y are exactly the right hedge — the kit that survives is the one that keeps running its own depreciation audit. On the evidence of this review, it's one of the few artifacts in the field constitutionally capable of doing that.

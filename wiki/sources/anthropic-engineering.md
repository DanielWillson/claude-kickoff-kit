---
title: "Anthropic engineering writing on agent harnesses"
type: source
status: current
updated: 2026-07-01
verified: 2026-07-01
code: [../../claude-project-kickoff.md, ../../README.md]
related: ["[[claude-code-feature-matrix]]", "[[2026-07-audit-pass]]"]
summary: "What Anthropic's own engineering posts actually say about harnesses, verified with verbatim quotes"
---

# Anthropic engineering writing on agent harnesses

All quotes below were fetched and checked verbatim against the live pages on 2026-07-01,
then re-checked by independent adversarial verifiers. This page backs the kit's Part 3
(items 8, 14, and the probe lead-in), the README bibliography entry, and the README's
"What scales with the model" section.

## The two harness posts (the kit's closest neighbors)

**Effective harnesses for long-running agents** (2025-11-26)
<https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents>
- Compaction alone is insufficient: *"However, compaction isn't sufficient. Out of the box,
  even a frontier coding model like Opus 4.5 running on the Claude Agent SDK in a loop
  across multiple context windows will fall short of building a production-quality web app
  if it's only given a high-level prompt."*
- The central pattern is an **initializer agent**: *"The very first agent session uses a
  specialized prompt that asks the model to set up the initial environment: an `init.sh`
  script, a claude-progress.txt file that keeps a log of what agents have done, and an
  initial git commit."* (Their kickoff ritual — independent convergence with this kit.)
- **One feature at a time**, from a JSON feature list whose only editable field is a
  `passes` status: *"This incremental approach turned out to be critical."*
- A fixed **bearings ritual** opens every session: run `pwd`, read git logs + progress
  files, read the feature list, pick the highest-priority feature. → kit Part 3.14.
- Dominant failure mode: *"Claude's tendency to mark a feature as complete without proper
  testing"* — fixed by giving it end-to-end verification tools (browser automation) and
  explicitly prompting their use. → kit Part 3.7/3.8, §1.6.

**Harness design for long-running application development** (2026-03-24)
<https://www.anthropic.com/engineering/harness-design-long-running-apps>
- Scales to a **planner / generator / evaluator** triad because: *"When asked to evaluate
  work they've produced, agents tend to respond by confidently praising the work—even when
  mediocre. … Separating the agent doing the work from the agent judging it proves to be a
  strong lever."* → kit Part 3.8 (doer/judge split), Principle 6.
- Prefers **full context resets with structured handoff artifacts** over compaction: *"A
  reset provides a clean slate, at the cost of the handoff artifact having enough state for
  the next agent."* → kit Principle 9.
- The self-audit anchor: *"Every component in a harness encodes an assumption about what
  the model can't do on its own."* → README "What scales with the model". Same doctrine
  restated in **Scaling Managed Agents** (2026-04-08,
  <https://www.anthropic.com/engineering/managed-agents>): *"those assumptions need to be
  frequently questioned because they can go stale as models improve."*

## Foundations

**Building effective agents** (2024-12-19)
<https://www.anthropic.com/engineering/building-effective-agents>
- *"the most successful implementations weren't using complex frameworks or specialized
  libraries. Instead, they were building with simple, composable patterns"*; add complexity
  *"only when it demonstrably improves outcomes."* → the kit's stdlib-only / no-framework
  posture (Principle 8).
- Agents need *"'ground truth' from the environment at each step"*; sandboxed testing +
  guardrails because autonomy compounds errors. → guides-and-sensors, the sandbox floor.

**Effective context engineering for AI agents** (2025-09-29)
<https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
- **Context rot**: *"as the number of tokens in the context window increases, the model's
  ability to accurately recall information from that context decreases"* — context is an
  attention budget. → why the contract stays lean and depth lives one pointer away.
- Three long-horizon techniques: compaction, **structured note-taking** (persistent files
  outside the window), and **sub-agents that return distilled summaries**. → the wiki,
  Part 3.13/3.14.
- System-prompt "altitude": neither hardcoded if/else logic nor vague platitudes.

**How we built our multi-agent research system** (2025-06-13)
<https://www.anthropic.com/engineering/built-multi-agent-research-system>
- *"token usage by itself explains 80% of the variance"* in research performance.
- Delegation quality decides success: *"Each subagent needs an objective, an output format,
  guidance on the tools and sources to use, and clear task boundaries."* → Part 3.3
  (CONTRACT.md as the subagents' shared brain).
- Evaluate **end state**, not process; store essential state in external memory before
  phase transitions. → Part 3.7/3.14.

**Writing effective tools for agents** (2025-09-11)
<https://www.anthropic.com/engineering/writing-tools-for-agents>
- Tools are *"a contract between deterministic systems and non-deterministic agents"*;
  consolidate operations, return only high-signal tokens; *"Even small refinements to tool
  descriptions can yield dramatic improvements."*

**Claude Code best-practices** (living docs page; the April 2025 engineering post now
308-redirects here) <https://code.claude.com/docs/en/best-practices>
- Verification first: *"Claude stops when the work looks done. Without a check it can run,
  'looks done' is the only signal available, and you become the verification loop."*
- CLAUDE.md doctrine: *"Keep it concise. For each line, ask: 'Would removing this cause
  Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore
  your actual instructions!"* → [[claude-md-size]].
- `/clear` after two failed corrections on the same issue (context polluted by failed
  attempts). → Principle 7/9 convergence.
- Adversarial review with a calibration warning: *"A reviewer prompted to find gaps will
  usually report some, even when the work is sound."* → Principle 6's reviewer should be
  scoped to correctness gaps.

## Security posts (backing the field guide + CHEATSHEET posture)

- **Sandboxing** (2025-10-20, <https://www.anthropic.com/engineering/claude-code-sandboxing>):
  sandboxing cut permission prompts **84%** in internal usage; containment neutralizes
  successful prompt injections; runtime open-sourced.
- **Auto mode** (2026-03-25, <https://www.anthropic.com/engineering/claude-code-auto-mode>):
  classifier-mediated approvals; users approve **93%** of prompts by default; honest **17%
  false-negative** rate on real overeager actions — the classifier is a probabilistic
  backstop, exactly as the CHEATSHEET ranks it. Canonical block case: an agent grepping
  env/config for alternative API tokens after an auth error.
- **How we contain Claude across products** (2026-05-25,
  <https://www.anthropic.com/engineering/how-we-contain-claude>): *"Rather than supervising
  what the agent does, we supervise what it's able to do"* via sandboxes/VMs/egress
  controls; prefer battle-tested primitives over custom security code; model-layer defenses
  fail exactly when the user types the instruction. → the kit's "a control is only as
  strong as the agent's inability to reach it."

## Dead ends (searched, not found)

- No standalone Anthropic *research* publication on coding-agent harnesses — it's all
  engineering-blog material.
- The original dated April 2025 best-practices post is gone (permanent redirect to the
  rewritten living page); claims about its original wording can't be verified from the
  live site.

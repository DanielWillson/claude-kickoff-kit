---
title: "The July 2026 audit pass — what was load-bearing, what was compensation"
type: decision
status: current
updated: 2026-07-01
verified: 2026-07-01
code: [../../claude-project-kickoff.md, ../../README.md, ../../llm-wiki-kickoff.md, ../../securing-claude-sessions.md]
related: ["[[anthropic-engineering]]", "[[claude-code-feature-matrix]]", "[[claude-md-size]]", "[[reasoning-extraction]]", "[[skills-shortlist]]", "[[operator-field-reports]]"]
summary: "Classification and outcomes of the 2026-07-01 Fable-driven audit: what was kept as invariant, cut as re-taught default, or reversed as stale"
---

# The July 2026 audit pass

**Context.** With a frontier model (Fable 5) reading the kit cold, every instruction was
classified: load-bearing regardless of model capability, or compensation for a weaker
model's judgment. A 30-agent research workflow verified the field's current state against
primary sources first (see the source pages). The security floor was excluded from the
simplification exercise **by design** — prose can't bind an agent that can be injected or
wrong, at any capability level.

**Kept as invariant** (force comes from properties of the world, not the model):
the security stack; reconcile-against-ground-truth; knowledge placement/routing (a fact
not in context doesn't exist); independent verification (self-reports are claims; errors
within one context are correlated); commit granularity as the human review surface; the
intake questions (facts the model can't derive); dependency restraint (binds harder as
models get more productive); the hard-won environment facts (§1.1a, sidecars, hooksPath).

**Cut or compressed as re-taught defaults** (current harnesses instruct these already):
Principle 3's narration mechanics (kept: the teaching-tone depth preference); Part 3.1's
scout-then-fan-out coaching; Part 2's "don't use agents for serial one-liners" tail.
Considered and **kept**: Principle 7's two-attempts tripwire (still a real failure mode in
long autonomous runs — passes the per-line test).

**Reversed as stale against 2026 tooling** (see [[claude-code-feature-matrix]]):
- Part 3.4 "partition by directory, **not worktrees**" → per-agent worktree isolation is
  now first-class and in-repo; rule generalized to *one writer per file*.
- Part 3.12 "prefer free-text over output schemas" → structured output now validates with
  retry at the tool-call layer; schema the verdicts, still verify work on disk.

**Added.** Part 3 probe lead-in (verify the harness like an installed dependency);
3.13 model tiering; 3.14 the cold-session trail (progress log + pass/fail task list +
bearings ritual — convergent with [[anthropic-engineering]]'s initializer pattern);
doer/judge split in 3.8; skills-as-dependencies in §1.3a; model refusals as a Level-A
control in the field guide; the memory-vs-wiki seam in the wiki guide §2.2; README's
"What scales with the model" (the three shelf lives + the per-line test at every model
upgrade); root SKILL.md (kit-as-skill delivery); sourced size guidance in §1.5
([[claude-md-size]]).

**Rejected.**
- Wholesale condensation-by-rewrite of the kickoff doc in one pass (cross-reference web +
  deliberate point-of-use repetition; surgical trims instead — a follow-up condensation
  ran with adversarial diff review).
- A standalone model-refusals document (a section carries it).
- Part 3 "budget tracking" guidance as if universal (no per-run token-budget primitive
  exists in baseline Claude Code — an environment-specific feature; the probe finds it
  where it exists).
- Mandating any community skill ([[skills-shortlist]]).

**The durable lesson** (now README "What scales with the model"): *"Every component in a
harness encodes an assumption about what the model can't do on its own"* (Anthropic).
A model upgrade is a scheduled maintenance event for the harness — re-run this audit's
per-line test; leave the invariants alone.

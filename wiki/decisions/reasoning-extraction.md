---
title: "Reasoning-extraction refusals vs. 'narrate the why' — no conflict"
type: decision
status: current
updated: 2026-07-01
verified: 2026-07-01
code: [../../claude-project-kickoff.md, ../../securing-claude-sessions.md]
related: ["[[anthropic-engineering]]", "[[2026-07-audit-pass]]"]
summary: "Principle 3's rationale-narration does not risk Fable-class reasoning_extraction refusals; the category targets reproducing internal thinking traces"
---

# Reasoning-extraction refusals vs. Principle 3

**Context.** The kit's Principle 3 asks the agent to explain the why behind non-trivial
choices. Claude Fable 5 ships a documented refusal category named `reasoning_extraction`.
Could the principle trip it?

**What the documentation actually says (all read 2026-07-01).**
- Refusals doc (<https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback>):
  *"reasoning_extraction — The request asks the model to reproduce its internal reasoning
  in the response text."*
- Fable/Mythos intro (<https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5>):
  *"The raw chain of thought is never returned"*; `thinking.display` controls
  summary-vs-empty.
- Fable prompting guide (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5>):
  risky wording is prompts that *"echo, transcribe, or explain its internal reasoning as
  response text"*; audit prompts for *"reflection or show-your-thinking instructions."*
  **The same guide's own recommended prompts** instruct rationale-in-output: lead with the
  outcome, *"Supporting detail and reasoning come after"*; *"give a recommendation"* when
  weighing choices.
- System card (full PDF grepped) and launch post: the term does not appear; classifiers
  are described as cyber / bio-chem / distillation. Claude Code's model-config page
  documents fallback for cyber/bio content only (and notes fallback can fire from
  workspace context like CLAUDE.md — not from narration instructions).

**Verdict.** No documented basis for a conflict. Every trigger phrasing has the *internal
thinking trace* as its object; explaining the rationale for decisions in ordinary output
is Anthropic's own recommended style. The line to hold in any harness prose: point
narration instructions at **decisions** ("explain why you chose this approach"), never at
the **thinking trace** ("show your thinking", "transcribe your reasoning").

**Applied.** Principle 3 (kickoff Part 2) now carries the disambiguating sentence; the
field guide's Level-A refusals note names the category.

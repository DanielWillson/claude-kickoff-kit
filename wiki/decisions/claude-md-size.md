---
title: "CLAUDE.md size guidance — the 50-line rule is unsourced"
type: decision
status: current
updated: 2026-07-01
verified: 2026-07-01
code: [../../claude-project-kickoff.md]
related: ["[[anthropic-engineering]]", "[[2026-07-audit-pass]]"]
summary: "Verdict on the circulating 50-line and 150–200-instruction claims; what the primary sources actually say"
---

# CLAUDE.md size guidance

**Context.** Two claims circulate: (1) a CLAUDE.md/AGENTS.md should stay under ~50 lines;
(2) instruction-following degrades past 150–200 discrete instructions. The kit's §1.5
needed a sourced position.

**Evidence (each read at the primary source, 2026-07-01).**
- Anthropic memory docs (<https://code.claude.com/docs/en/memory>): target **under ~200
  lines** per CLAUDE.md file.
- Anthropic best-practices (<https://code.claude.com/docs/en/best-practices>): no number;
  *"Keep it concise. For each line, ask: 'Would removing this cause Claude to make
  mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual
  instructions!"*
- OpenAI harness engineering (Feb 2026, <https://openai.com/index/harness-engineering/>;
  fetched via full-text mirror — openai.com blocks bots): AGENTS.md at *roughly 100 lines*,
  a "table of contents" over the docs system-of-record.
- HumanLayer, *Writing a good CLAUDE.md* (2025-11-25,
  <https://www.humanlayer.dev/blog/writing-a-good-claude-md>): consensus *"< 300 lines is
  best, and shorter is even better"*; their own root file is *"less than sixty lines"* —
  **descriptive, not prescriptive**. Their "150–200 instructions" line paraphrases IFScale;
  their "~50 instructions in Claude Code's system prompt" stat is their own uncited
  analysis.
- IFScale paper (arXiv 2507.11538, July 2025): 500-keyword report benchmark across 20
  mid-2025 models. Only the top two reasoning models held near-perfect compliance
  *"through 150 or more instructions"*; mid-tier models show a critical zone at 150–300;
  best models scored **68% at 500**. **No sentence in the paper asserts a universal
  150–200 cliff.**

**Verdict.**
1. The 50-line rule: **unsourced** — appears only in uncited aggregator blogs; probably a
   mashup of HumanLayer's <60-line example and their ~50-instruction stat. Rejected.
2. The 150–200 cliff: **real phenomenon, wrong precision** — degradation with instruction
   count is measured, the specific cliff is a downstream paraphrase.
3. What the kit says (§1.5): under ~200 lines (Anthropic), ~100-line table-of-contents
   (OpenAI), prune per-line, and the *instruction count* — not line count — is the budget
   that binds. That mechanism is the real argument for "depth graduates to the wiki."

**Rejected along the way.** Attributing the small-CLAUDE.md rule to Dex Horthy's *Advanced
Context Engineering* post — read it; it contains no length or instruction-count guidance
at all. A common misattribution.

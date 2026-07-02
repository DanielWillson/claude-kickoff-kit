---
title: "Skills/plugins to recommend alongside the kit — posture first, shortlist second"
type: decision
status: current
updated: 2026-07-01
verified: 2026-07-01
code: [../../README.md, ../../claude-project-kickoff.md]
related: ["[[operator-field-reports]]", "[[2026-07-audit-pass]]"]
summary: "No community skill is universally load-bearing; the durable rule is vet-like-a-dependency; dated shortlist with evidence"
---

# Skills/plugins alongside the kit

**Context.** Should the kit recommend any open-source skills as near-mandatory companions?

**Ecosystem facts (verified 2026-07-01).**
- Skills/plugins are stable: agentskills.io open standard; commands merged into skills;
  official marketplace built in (`/plugin install <name>@claude-plugins-official`), 255
  plugins in the live marketplace.json; per-plugin context-cost estimates (v2.1.143+) and
  a "not used recently" pruning nudge (v2.1.187+).
- **Anthropic disclaims verification of third-party contents even in its official
  directory**: *"Make sure you trust a plugin before installing… Anthropic does not
  control what MCP servers, files, or other software are included."* Docs classify plugins
  as components that *"can execute arbitrary code on your machine."*
- Top installs (claude.com/plugins): Frontend Design 984,520; **Superpowers 885,322**;
  Code Review 394,574; Context7 385,456.
- **Superpowers** (obra / Jesse Vincent): 243,555 stars, MIT, v6.1.0 (2026-06-30),
  actively maintained, carried in the official marketplace. Hands-on audit of the cloned
  code: SessionStart hook injects only local SKILL.md content; the single disclosed
  phone-home is a version-bearing logo URL in an optional UI honoring opt-out env vars.
  Real criticism from operators: token cost/ceremony, plan-editing rigidity, and some
  users reporting worse results (HN, 2026-04).
- **Context7**: popular docs-lookup, but a thin client for a **closed-source hosted API**
  (backend/crawler proprietary; queries leave the machine).
- Best directory: hesreallyhim/awesome-claude-code (47.7k stars, active).

**Verdict.** Nothing clears the bar of "fundamentally important install." The durable
content is the **posture** (kickoff §1.3a): a skill is installed instructions inside the
prompt-level trust boundary — read before installing, prefer pinned copies, few. The dated
shortlist (README): Anthropic's `security-guidance` (three-layer review; complementary to
the kit's floor), the per-language **LSP plugin**, `frontend-design` for UI;
**superpowers** as a clearly-optional opinionated methodology, never a default.

**Rejected.** Mandating superpowers (token cost + rigidity + credible dissent; the kit
already carries its own methodology); recommending Context7 without the closed-backend
caveat; bundling any third-party skill inside the kit (drift + trust surface).

**Dead ends.** ruvnet/claude-flow (repo gone); kieranklaassen/compounding-engineering (no
repo at cited path); the "93k stars" superpowers figure (stale — 243.6k live); Anthropic
publishes no formal security-review criteria for marketplace admission (only a submission
form).

---
title: "Operator field reports (2025–2026)"
type: source
status: current
updated: 2026-07-01
verified: 2026-07-01
code: [../../claude-project-kickoff.md, ../../llm-wiki-kickoff.md]
related: ["[[anthropic-engineering]]", "[[skills-shortlist]]", "[[2026-07-audit-pass]]"]
summary: "First-hand practitioner accounts of what actually worked or failed in day-to-day agent harnesses, with quotes"
---

# Operator field reports (2025–2026)

Beyond the kit's headline sources (Böckeler, OpenAI, Stripe, Karpathy). Each entry: the
battle-tested specific, quote-checked against the primary page on 2026-07-01. Ordered by
how hard the finding cuts.

**Aaron Gustafson — Optimizing Your Codebase for AI Coding Agents** (2025-10-21)
<https://www.aaron-gustafson.com/notebook/optimizing-your-codebase-for-ai-coding-agents/>
Measured his agent spending **~40% of its time deciding which of several contradictory docs
to trust**. Consolidating to a single source of truth + fast single-purpose validation
scripts cut processing time ~40% and tokens ~75%. *"Optimizing for AI agents isn't really
about AI. It's about removing ambiguity, eliminating redundancy, and making implicit
knowledge explicit."* → the strongest independent measurement behind the kit's
one-claim-one-home rule (`llm-wiki-kickoff.md` §2.9) and reconcile-against-code.

**Armin Ronacher** — three posts, one arc:
- *Agentic Coding Recommendations* (2025-06-12, <https://lucumr.pocoo.org/2025/6/12/agentic-coding/>):
  tools must **fail fast — hangs are worse than crashes**; everything the app prints is
  *also logged to a file* so the agent can inspect its own runs; deliberate MCP minimalism
  (plain scripts/CLIs first, MCP *"only if the alternative is too unreliable"*).
- *Things That Didn't Work* (2025-07-30, <https://lucumr.pocoo.org/2025/7/30/things-that-didnt-work/>):
  abandoned most slash commands (no gain over conversation + an issue URL), hooks
  (*"I haven't seen any efficiency gains from them yet"*), and headless mode; mixed
  read/write subagent parallelism *"create[s] chaos."* → sobering counterweight: harness
  automation must earn its keep per-operator; the kit's tiers exist for this reason.
- *Agent Design Is Still Hard* (2025-11-21, <https://lucumr.pocoo.org/2025/11/21/agents-are-hard/>):
  objectives must be continuously **re-injected** into long loops (even an "echo tool"
  reflecting the task back improves progression); context editing invalidates caches —
  *"There is really no way around it."*

**Mitchell Hashimoto — Vibing a Non-Trivial Ghostty Feature** (2025-10-11)
<https://mitchellh.com/writing/non-trivial-vibing>
16 sessions, $15.98, ~8 wall-clock hours for one real feature. The load-bearing habits:
**manual scaffolding** (he writes signatures + TODO comments, agent fills in — *"AI is very
good at fill-in-the-blank or draw-the-rest-of-the-owl"*); a persistent **spec.md**
re-anchors every session (*"Consult the @spec.md and work on some task"*) — the file, not
the chat, is the memory; named the **"slop zone"** (agent looping on a bug it can't fix) —
what we call the loop trap — with recovery by manual restructuring; ends every feature with a read-only review prompt
(*"…Don't write any code."*). → Part 3.2 (foundation stays inline), Principle 7, Principle 9.

**HumanLayer — Advanced Context Engineering for Coding Agents / ace-fca** (2025)
<https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md>
Research → plan → implement with **human review concentrated on the plan, not the diff**:
*"A bad line of code is… a bad line of code. But a bad line of a **plan** could lead to
hundreds of bad lines of code."* Keep context utilization at 40–60%. Priority ordering:
*incorrect* context < *missing* context < *noise*, because *"the contents of your context
window are the ONLY lever you have to affect the quality of your output."* → Principle 6.

**Steve Yegge** — the scale failure and its numbers:
- *Introducing Beads* (2025-10-13, <https://steve-yegge.medium.com/introducing-beads-a-coding-agent-memory-system-637d7d92514a>):
  605 decaying markdown plan files; agents going *"full-blown bugshit amnesiac"* mid-plan —
  prose dependencies can't be queried; his fix is a git-backed JSONL issue graph. → honest
  boundary of the kit's markdown-file patterns: they hold at project scale, not fleet scale.
- *Six New Tips* (2025-12-07, <https://steve-yegge.medium.com/six-new-tips-for-better-coding-with-agents-d4e9c86e42a9>):
  **Rule of Five** — output converges after 4–5 review/improve iterations per artifact;
  budget 30–40% on code health; the **merge wall** — pause agent swarms during structural
  refactors.

**Every (Kieran Klaassen / Dan Shipper) — Compound Engineering** (2025-12-11)
<https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents>
After every review, lessons are written back into CLAUDE.md / docs / review agents, tested
by *"Would the system catch this automatically next time?"* — *"The plan and review steps
should comprise 80 percent of an engineer's time."* What Every calls compound
engineering, we call the safety net — independent convergence with it (README "big idea"). Klaassen's CLAUDE.md rule: *"Keep it short, keep it alive."*
(2025-08-18, <https://every.to/source-code/my-ai-had-already-fixed-the-code-before-i-saw-it>)

**Amp (Thorsten Ball, Quinn Slack) — Raising an Agent, ep. 9** (2026-01-22)
<https://ampcode.com/podcast/episode-9>
*"You want to weld the agent to the code base… knows exactly how to verify its changes and
get feedback."* Build feedback affordances into the app itself: a CLI flag that screenshots
the running TUI for the agent; data-only subcommands so verification doesn't require
parsing a UI; AGENTS.md pointing at the right feedback tool per change. → the field's
sharpest phrasing of what Böckeler calls guides-and-sensors (we call them directives and
verifiers) as a *codebase property* — Böckeler's harnessability, which we call
harness-friendliness.

**Simon Willison**:
- *Parallel coding agents* (2025-10-05, <https://simonwillison.net/2025/Oct/5/parallel-coding-agents/>):
  runs parallel agents only on research/PoCs, code questions, low-stakes maintenance, and
  self-specified work — **review cost, not generation cost, is the bottleneck**; *"Code
  that started from your own specification is a lot less effort to review."*
- *Designing agentic loops* (2025-09-30, <https://simonwillison.net/2025/Sep/30/designing-agentic-loops/>):
  YOLO-mode risk model = file destruction, exfiltration, machine-as-attack-proxy;
  mitigation is credential scoping with **hard budget caps** (a dedicated Fly.io org with a
  $5 limit). → same posture as the kit's least-privilege secret handling.
- *Claude Skills* (2025-10-16, <https://simonwillison.net/2025/Oct/16/claude-skills/>):
  skills beat MCP on token economics — *"each skill only takes up a few dozen extra
  tokens"* vs. tens of thousands for a large MCP server. → [[skills-shortlist]].

**Jesse Vincent — Superpowers** (2025-10-09, <https://blog.fsck.com/2025/10/09/superpowers/>)
Skills need a **forcing function**: the bootstrap makes use mandatory (*"If you have a
skill to do something, you must use it"*). Validated compliance by pressure-testing
subagents with high-stakes scenarios after naive testing failed — *"Claude was quizzing the
subagents like they were on a gameshow."* → prose instructions don't self-enforce; the
kit's answer is deterministic gates where it matters.

**Geoffrey Litt — Stevens** (2025-04-12,
<https://www.geoffreylitt.com/2025/04/12/how-i-made-a-useful-ai-assistant-with-one-sqlite-table-and-a-handful-of-cron-jobs>)
A genuinely useful assistant on **one SQLite table + cron jobs** — *"you don't need fancy
techniques or libraries to build useful personal tools with LLMs."* → complexity is earned.

## Dead ends (searched, not found)

- No literal "Dan Shipper Claude Code diaries" series; Every's concrete material is
  Klaassen's.
- No canonical "agent-first codebase" essay — the root is Amp's podcast ep. 9.
- Hashimoto's "I do not care what the AI said… I want to see the contributor's thinking"
  (Ghostty PR policy) reached us only via a secondary source (SpecStory newsletter) —
  treat as secondary.

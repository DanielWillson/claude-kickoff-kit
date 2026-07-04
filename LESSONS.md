# Field Lessons — working with LLMs when the work has to be right

*v1, claims verified against primary sources 2026-07-01 (the full corpus — verbatim
quotes, URLs, verification dates, and the dead ends — lives in [`wiki/`](wiki/index.md)).
Written for a human — engineer or product manager — leveling up their understanding of
LLMs: not how to prompt, but how to think about what these systems actually are, where
they measurably fail, and what the working answers look like. The kit's other documents
apply these lessons; this one explains them.*

---

## Lesson 1 — The field converged on one loop, from four directions

Four groups who never compared notes shipped the same design. Martin Fowler calls it
guides-and-sensors. Anthropic's harness team built an initializer → generator → evaluator
pipeline. Every calls it "compound engineering." This kit calls it the safety net. Strip the
vocabulary and it's one idea:

> **A harness is a system that converts mistakes into permanent checks.**

The test that makes it operational comes from Every: after any failure, ask *"Would the
system catch this automatically next time?"* If the answer is no, the fix isn't finished —
you removed the bug but kept the vulnerability to it. A fixed bug should leave three
artifacts behind: a one-line guardrail where the agent always looks, a mechanical check
that fails if it recurs, and a written record of what was tried and why it failed.

Independent convergence is the strongest evidence available in a young field. When four
serious operators derive the same structure from different starting points, that structure
is probably load-bearing, not fashion.

## Lesson 2 — Verification is the whole game

The two failure modes that matter most were **measured, not speculated**, by Anthropic on
its own models
([source](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents),
[source](https://www.anthropic.com/engineering/harness-design-long-running-apps)):

1. **Agents mark work complete without testing it.** An agent stops when the work *looks*
   done — and unless you hand it a check it can *run*, "looks done" is the only signal it
   has. The fix is not exhortation; it's executable verification: tests, an audit script,
   browser automation, anything that returns pass/fail without a human.
2. **Agents grade their own work generously.** Asked to evaluate what they produced,
   agents *"tend to respond by confidently praising the work — even when mediocre."*
   Anthropic's fix was structural: separate the agent that builds from the agent that
   judges, with fresh context. The deeper reason this works: errors *within* one context
   are correlated — the same misunderstanding that produced the bug will approve it.

Two corollaries from operators:

- **Build verification into the thing itself.** The Amp team's phrase is *"weld the agent
  to the codebase"*: a CLI flag that screenshots the running app, a data-only subcommand
  that skips the UI, a docs file that names which feedback tool fits which change. An
  affordance the agent can't miss beats an instruction it might skip.
- **Review cost, not generation cost, is the bottleneck** (Simon Willison). Agents made
  writing code cheap; they made *trusting* code the scarce resource. This is why small,
  logical commits matter more with agents, not less — commit granularity *is* the human
  review surface — and why work that starts from your own spec is worth more than work
  the agent invented.

**For the skeptic, this is the pivotal lesson:** nothing here asks you to trust the model.
It asks you to build the same machinery you'd build around fallible humans — code review,
CI, independent QA — and aim it at a tireless collaborator that works at 100× the volume.

## Lesson 3 — Context is a budget; files are the memory

Three measured facts about how these systems actually behave:

- **Recall degrades as context grows.** Anthropic names it *"context rot"*: the longer the
  context window gets, the worse the model is at using any given fact in it
  ([source](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
  Context is an attention budget, not a bucket.
- **Instruction-following sags with instruction count.** The one real measurement (the
  IFScale benchmark, [arXiv 2507.11538](https://arxiv.org/abs/2507.11538)) found even
  frontier models start dropping instructions somewhere in the low hundreds, weaker models
  much sooner. So a rules file is a budget too — spent per instruction, not per line.
- **Long sessions lose conversational state.** When a session's context fills, it gets
  summarized ("compacted") — and instructions that lived only in chat can vanish, while
  files reload from disk intact. A boundary you stated in conversation is a boundary the
  agent may simply no longer have.

Everything that works follows from these three facts:

- Keep the always-loaded instruction file **lean** — Anthropic's own target is under ~200
  lines, pruned per-line by *"would removing this cause mistakes?"* — and push depth into
  documents loaded on demand.
- Put anything that must survive — decisions, progress, invariants — **in files, not in
  chat**. For work spanning multiple sessions: a progress log, a task list whose only
  writable field is pass/fail, and a fixed session-start ritual (read the git log, the
  progress log, the task list — *then* work).
- Rank the harms in this order (HumanLayer): **incorrect context is worse than missing
  context, which is worse than noise** — because *"the contents of your context window
  are the ONLY lever you have to affect the quality of your output."* A confident wrong
  line in a doc does more damage than the doc's absence. That is the entire argument for
  documentation that mechanically verifies itself against the code instead of being
  trusted on faith. One measured case (Aaron Gustafson, Microsoft): an agent spent ~40% of
  its time deciding which of several contradictory docs to trust; consolidating to one
  source of truth cut token use ~75%.

## Lesson 4 — Harness components have shelf lives

Anthropic's harness team, one sentence: *"Every component in a harness encodes an
assumption about what the model can't do on its own."* Models improve; assumptions go
stale; some flip from helpful to actively wrong. It happened inside this kit — two of its
own rules (against per-agent worktrees, against structured agent output) were correct when
written and *backwards* one tooling generation later.

Sort every harness component into three piles:

- **Permanent** — its force comes from a property of the *world*, not the model's
  judgment: documents rot regardless of who reads them; a fact not in context doesn't
  exist at any IQ; a self-report is a claim from any model; human review bandwidth doesn't
  scale with model capability; prose can't bind an agent that can be manipulated or wrong.
  These survive every upgrade. **The security floor is in this pile** — a more autonomous
  model needs it more, not less.
- **Depreciating** — compensation for what some model couldn't do: step-by-step coaching,
  "don't forget to X" reminders, how-to-think guidance. Re-audit at every model upgrade
  with the per-line test; yesterday's essential guardrail is today's noise (see Lesson 3
  on what noise costs).
- **Appreciating** — worth *more* as models improve: delegation structure (a stronger
  orchestrator extracts more from the same fan-out) and the safety net itself (a stronger
  model converts every permanent check into more autonomy safely granted).

The habit: **treat a model upgrade as a scheduled maintenance event for your harness**,
not just a version bump.

## Lesson 5 — Instructions are dependencies

An installable "skill" or plugin is prose (often plus scripts) that you place inside your
agent's trust boundary — it steers everything the agent does when it triggers. Anthropic
explicitly disclaims verifying third-party contents *even in its official directory*
(*"Anthropic does not control what MCP servers, files, or other software are included in
plugins and cannot verify them"*). So treat installed instructions exactly like installed
code: read before installing, pin versions, prefer few, from authors you trust.

And hold one contrarian data point close: Armin Ronacher — as serious an operator as they
come — built slash commands, hooks, and headless automation, then **abandoned most of
them** because plain conversation performed just as well. The lesson isn't that harness
automation is useless (measured wins exist); it's that **every piece of harness must earn
its keep, per line, against the simplest alternative** — the same law that governs the
instruction file governs the whole apparatus. A harness is also a system, and unverified
complexity in it is exactly as suspect as unverified complexity in your code.

## Lesson 6 — Judgment is not a boundary (the security lesson, compressed)

The numbers make the argument better than principles do. Anthropic's own published
measurements: OS-level sandboxing cut permission interruptions **84%** while *hardening*
the boundary — safety and speed improved together, they are not a trade-off. And the
model-based classifier that reviews agent actions in auto mode misses about **17%** of
genuinely overeager actions — good backstop, never a wall.

Hence the hierarchy this kit builds on: an OS-enforced sandbox and server-side rules are
*boundaries*; deny/ask rules are *deterministic backstops*; classifiers and the model's
own judgment are *probabilistic backstops*; prose is *advice*. The one-line rule: **a
control is only as strong as the agent's inability to reach it.** The full teaching
version is [`securing-claude-sessions.md`](securing-claude-sessions.md).

## Lesson 7 — Read the field like it reads code: verify, don't vibe

Two claims circulated widely in 2025–26: "keep your agent instruction file under 50
lines" and "instruction-following collapses past 150–200 instructions." Chasing them to
primary sources found: **no source anywhere states the 50-line rule** (it appears to be a
mashup of one company's descriptive "our file is under sixty lines" and their own uncited
statistic), and the 150–200 "cliff" is a narrowed paraphrase of a real paper that found
something more nuanced. The numbers were folklore wearing citation's clothes — and both
were *directionally* right, which is exactly what makes folklore dangerous: it survives
spot-checks.

The meta-lesson for anyone learning this field: it is young, it moves monthly, and its
best-known "facts" are often three paraphrases away from the evidence. The same
discipline this document urges for agent harnesses applies to learning about them —
an unverified claim is worse than no claim, because you'll build on it with confidence.

## The numbers worth carrying in your head

| Number | What it means | Source |
|---|---|---|
| 84% | fewer permission interruptions after sandboxing — hard boundaries *reduce* friction | Anthropic, Oct 2025 |
| 17% | of genuinely overeager agent actions missed by the auto-mode classifier — judgment ≠ wall | Anthropic, Mar 2026 |
| 80% | of multi-agent performance variance explained by token spend alone — attention is the resource | Anthropic, Jun 2025 |
| ~40% / ~75% | agent time lost to contradictory docs / token cut from consolidating to one source of truth | Gustafson, Oct 2025 |
| 4–5 | review-improve iterations before agent output converges ("Rule of Five") — budget for them | Yegge, Dec 2025 |
| <~200 lines | Anthropic's own target for an instruction file, pruned per-line | Anthropic docs |

## If you read three things end-to-end

1. **Anthropic — [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)** (Nov 2025) — the measured failure modes and the initializer/progress-file/one-feature-at-a-time pattern.
2. **Anthropic — [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps)** (Mar 2026) — builder/judge separation, and the "every component encodes an assumption" principle.
3. **HumanLayer — [Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)** (2025) — context as the only lever; review the plan, not the diff.

Then the operator accounts in [`wiki/sources/operator-field-reports.md`](wiki/sources/operator-field-reports.md)
— Hashimoto, Ronacher, Willison, Yegge — for what the polished posts leave out.

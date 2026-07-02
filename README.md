# Claude Kickoff Kit

The Claude Kickoff Kit is a portable set of documents, handed to a fresh Claude Code session
**at the very start of a new project**. It does three jobs at once: it walks Claude through
setting the project up, it lays out a philosophy for how to build, and it provides templates
that seed the project's first documentation, health checks, and safety rules.

The kit is *scaffolding*. It works for any kind of project, in any programming language. It is
used once, at the beginning — and it is **never copied into the project's own code**. Once a
project is on its feet, the kit's job is done.

## The big idea: an agent is a model plus a harness

A useful way to think about coding agents has been going around the field lately, and it comes
from Martin Fowler. The model is Claude itself, and that part is fixed — nobody using the kit is
changing how Claude thinks. Everything *else* is the harness: the instructions the agent reads, the checks it has
to pass, the boundaries it isn't allowed to cross, and the knowledge it can look up. That
surrounding structure, far more than any single cleverly-worded prompt, is what decides whether
an agent does good, reliable work.

The word "harness" gets used two ways, and it helps to keep them apart:
- The **runtime** harness is Claude Code itself — the program, its tools, its built-in safety
  checks. Nobody builds this; it just gets configured.
- The **durable** harness is the set of files the kit helps create and leaves behind in the
  project: the agent's instruction file, its settings, a health-check script, a knowledge wiki,
  a README for people, and a product spec. *This* is what the kit is for, and it outlasts any
  single work session — even a future upgrade to a smarter model.

The whole point of the kit is to build that durable harness in one sitting, and then step out
of the way.

## How the pieces fit together

Borrowing Fowler's vocabulary again, the durable harness is built from two kinds of help, both
aimed at the same goal: making the agent's output trustworthy.

- **Guides** point the agent in the right direction *before* it starts working. These are
  things like the always-on instruction file, the product spec, the design style guide, and the
  short list of rules the project must never break. Good guides mean a better first draft.
- **Sensors** check the agent's work *after* it acts, so mistakes get caught and corrected.
  These are things like the automated health-check script, the test suite, a second agent
  reviewing the first one's plan, and the wiki's habit of checking itself against the real code.
  Good sensors catch what the guides missed.

(Fowler calls these "feedforward" and "feedback" controls; "guides" and "sensors" are the same
idea in plainer words.)

The two halves form a loop, and a person closes it by hand. When a sensor keeps catching the
same kind of mistake, the fix isn't to nag the agent — it's to *strengthen a guide* so the
mistake can't happen again. A bug becomes a permanent check in the health script. A nasty
surprise becomes a one-line warning in the instruction file. A dead end becomes a written-up
"we tried this, here's why it failed" page in the wiki. Every mistake leaves behind something
that stops it from coming back. That habit only ever tightens, like a ratchet, and it is the
single most valuable thing the kit installs.

It is also why the kit insists that its documents **check themselves against the actual code**,
rather than being trusted on faith. A guide or a knowledge page that has quietly gone out of
date is *worse* than having none at all, because the agent will follow it with total
confidence — straight into the wrong thing.

### One thing this picture leaves out: safety is a separate question

Guides and sensors are about *quality*. Safety — keeping the agent from doing something
destructive, or from leaking a secret — works differently, and the kit is careful not to blur
the two.

The key idea is that safety controls are not all equally strong. They sit in a clear pecking
order, strongest to weakest:

1. **A locked room, enforced by the operating system.** The agent runs inside a sandbox: a
   boundary the computer itself imposes. The agent simply cannot write files outside the project
   folder or reach out to the open internet. This is the only true wall.
2. **Hard rules that block or pause an action.** Some actions are flatly blocked ("never read
   the password file"). Others trigger a pause to ask a human first ("about to send code up to the
   shared repository where teammates will get it — okay?"). These are mechanical: they fire every time, with no judgment
   involved.
3. **The agent's own safety judgment.** Claude has a built-in check that looks at each action
   and decides whether it seems safe. It is good — but it is a judgment call, usually right
   rather than guaranteed right.
4. **Plain-text instructions.** Anything written as ordinary prose, such as the agent's
   instruction file, is advice, not a control. The agent can misread it, or even edit it. A
   sentence is never a safety guarantee.

The practical rule that falls out of this: the safety rules that truly cannot be allowed to
fail must live where the agent can't reach them to weaken them. The two security documents
(`securing-claude-sessions.md` and `CHEATSHEET.md`) cover this in full; the quality harness
above sits on top of this safety floor.

## What's in here

Each file is labeled with what it does, and why it earns a place.

- **`claude-project-kickoff.md`** — the starting point. It is the setup checklist — version
  control (the running history of every change), safety settings, the instruction file, the
  health check, the wiki — plus ten principles for how to build, plus a playbook for running
  several agents at once. Read this
  first; it drives everything else.
- **`llm-wiki-kickoff.md`** — how to set up the project's **wiki**: a small, self-maintaining
  knowledge base for the deeper "how does this part work, and what have we already learned the
  hard way" material. Its core rule is that the wiki checks itself against the code, so it can't
  quietly drift out of date. This is where the "we tried X, it failed because Y" history lives —
  the kind of thing nothing else records. (The idea comes from Andrej Karpathy; see the sources
  at the end.)
- **`claude-audit-base.sh`** — a starter **health-check script**. It gets copied into the
  project and grown over time, gaining a new check every time a bug is fixed. It is the
  project's fastest, most reliable sensor: an ordinary script, no AI involved, that runs
  anywhere.
- **`prd-template.md`** — a fill-in-the-blanks **product spec**: what's being built, why, and
  which rules must always hold. It is a guide — the place those must-never-break rules get named
  before any code exists.
- **`readme-template.md`** — a fill-in-the-blanks **README for people** — the project's front
  door. It explains what the project is and how to run it, in plain language, for a reader who
  may not be an engineer. (Deliberately separate from the agent's instruction file: people read
  this one, the agent reads that one.)
- **`styleguide.html`** — an *example* design style guide, for a project with a user interface
  (swap in a real one). It defines the project's colors, spacing, and fonts in one place, so the
  look stays consistent across screens.
- **`templates/`** — copy-paste **settings files**, in three layers: a machine-wide locked floor
  only an administrator can change, a per-project file that travels with the code, and a
  per-machine file for local preferences. `templates/README.md` explains the three layers. (This
  is the safety side of things, not the quality harness.)
- **`CHEATSHEET.md`** — a terse, verified reference for exactly how Claude Code's permission and
  sandbox machinery behaves. For when the precise mechanics matter.
- **`securing-claude-sessions.md`** — a plain-English **field guide** to the safety model: the
  pecking order above, told as a story, with the rule of thumb that *a control is only as strong
  as the agent's inability to reach it*. The teaching companion to the cheat sheet.
- **`SKILL.md`** — the wrapper that lets the whole kit double as an installable **skill**
  (see "How to use it" below). It adds a second delivery mechanism, not new content.

### Worth installing alongside the kit? (verified 2026-07-01 — dates matter here)

Nothing is mandatory, and the posture matters more than any list: a skill or plugin is
**installed instructions inside the agent's trust boundary** — vet it like a dependency
(read it before installing, prefer a pinned copy; the kickoff guide §1.3a carries the
rule). With that said, the shortlist that survived a primary-source check: Anthropic's own
**`security-guidance`**, the **LSP plugin** for your language, and **`frontend-design`**
for UI work — all in the built-in official marketplace. The community standout by adoption
is **`superpowers`** (obra) — actively maintained, and a code audit this kit ran found it
clean — but it is token-hungry and opinionated about workflow, with credible operator
dissent: an optional methodology add-on, never a default. Lists like this one go stale;
re-check adoption and read the `SKILL.md` yourself before trusting anything here.

## How to use it

Two ways to hand the kit to a fresh session:

- **Point a session at the files** (works anywhere): give it the kickoff guide and let it
  pull the rest as each step needs them.
- **Install the kit as a skill** (one time): clone or symlink this repo to
  `~/.claude/skills/project-kickoff` — the `SKILL.md` at the repo root makes the whole kit
  double as a skill package. From then on, saying "kick off a new project" in any session
  triggers the ritual, with the documents loaded on demand instead of pasted up front.
  Nothing else changes: the kit still never enters the project it sets up.

Either way: at the start of a new project, Claude runs the setup, takes the
principles on board, and produces the project's lasting files: the instruction file, the
settings, the health-check script, the wiki, the README, and the filled-in spec. *Those* live
in the project's code. The kit itself does not. After setup, the kit drops away — day-to-day
work reads the project's own slim instruction file and wiki, never the kit again.

The working relationship this sets up is, in OpenAI's phrase, **"humans steer, agents
execute."** But "steer" means something specific here. Steering is *setting the boundaries up
front and reviewing the work in small batches afterward.* It is **not** approving every
individual step (that would defeat the point of an agent that can run on its own), and it is
**not** a casual instruction dropped into chat (those get forgotten the moment the conversation
is summarized to save space). The agent works largely unattended, and a second agent reviews its
plans.

## The thinking behind it

- **Knowledge that keeps itself honest.** The wiki and the README both check themselves against
  the code, so the documentation can't silently rot. A knowledge base trusted on faith slowly
  fills with confident-sounding lies; one that is checked against the real code goes out of date
  *visibly*, which is the only kind of out-of-date anyone can actually fix. (Fowler calls the
  general habit "keeping quality left" — catching problems early and cheaply, instead of
  discovering them once the agent has already built on bad information.)
- **Keep knowledge in the project, not in the agent's private memory.** What the project knows
  lives in the project's own files: the wiki, the instruction file, and the notes attached to
  each saved change. The agent's personal memory is only for personal working-style preferences,
  never project facts. (A fact about *this* project, saved into the agent's global memory, would
  leak into every other project it ever works on.) As OpenAI puts it, from the agent's point of
  view *anything it can't see at the moment it's working doesn't exist* — so the instruction file
  is kept short, a table of contents that points to the deeper material rather than trying to
  hold all of it.
- **Three readers, three documents, no overlap.** The README is for people. The instruction
  file is for the agent, and stays short. The wiki is for depth and history, read only when
  needed. Most setups merge the first two; keeping them apart is what lets the agent's file stay
  lean *and* the human's file stay readable.
- **Rules any tool can follow, not tied to one agent.** The durable rules live where
  anything can read or run them: the instruction file (any AI, any tool, or any person can read
  it) and the health-check script (which runs on its own, or as part of an automated pipeline —
  the machinery that runs checks on every change without anyone starting it by hand).
  The Claude-specific conveniences — like an automatic save at the end of each session — are a
  nice-to-have layer on top. When more than one thing changes the project (another AI tool, a
  human teammate, an automated pipeline), a couple of tool-neutral safety nets carry the
  guarantees instead.
- **Used once, then gone.** The kit is scaffolding; only what it produces sticks around. (The
  health check even warns if a kit file ever gets copied into a project by mistake.)
- **The hardest safety rules belong at the machine level, not inside the project.** Here is the
  reasoning, step by step. A settings file that lives *inside* the project can be edited by the
  agent — so it is useful, but it is "soft": it can't be trusted to hold a line a determined
  agent wants to cross. The non-negotiable safety rules — no overriding the safety system, no
  reading credentials, the locked room — therefore live somewhere the agent can't touch: a
  settings file owned by the computer's administrator, plus the operating-system sandbox. The
  in-project settings file still does real work, carrying the project's own specifics and the
  rules meant to travel to teammates, and the two layers add together rather than fighting. But
  the unbreakable floor sits one level down, out of the agent's reach. (The short version: the
  sandbox is the wall; block-and-pause rules are mechanical backstops; the agent's own judgment
  is a good guess; plain prose is not a control at all.)

## What scales with the model, and what doesn't

The kit claims the durable harness "outlasts a model upgrade." Be precise about *how*,
because its parts age differently — as Anthropic's harness team puts it, *"every component
in a harness encodes an assumption about what the model can't do on its own."* Three shelf
lives:

- **Invariant — keep forever.** Anything whose force comes from a property of the world,
  not from the model's judgment: the security floor (prose can't bind an agent that can be
  manipulated or simply wrong — truer as autonomy grows, not less); reconcile-against-code
  (documents rot no matter who reads them); knowledge placement (a fact not in context
  doesn't exist, at any level of intelligence); independent verification (a self-report is
  a claim from any model — errors inside one context are correlated); commit granularity
  (human review bandwidth doesn't scale with the model).
- **Depreciating — re-audit at every model upgrade.** Prescriptive step-lists, how-to-think
  coaching, "don't forget to X" reminders: each exists because some model once needed it,
  and each turns into dead weight — or into actively wrong advice — once default behavior
  catches up. The per-line test: *would a fresh session of the current model get this wrong
  without the line?* If not, cut it. (This kit runs that audit on itself: the July 2026
  pass cut its scout-then-fan-out coaching and *reversed* its own stale advice against
  structured agent output.)
- **Appreciating — worth more as the model improves.** Delegation structure (a stronger
  orchestrator makes tiering and fan-out more valuable, not less) and the ratchet itself
  (every mistake becomes a permanent check): a more capable model converts both into more
  leverage per unit of setup.

The habit this section encodes: **a model upgrade is a scheduled maintenance event for the
harness**, not just a version bump. Re-run the per-line test on `CLAUDE.md` and on the
kit's own guidance; leave the invariants alone.

## Where these ideas come from

The kit didn't invent this approach. It assembles a set of ideas the field has been working out
in the open over the past year. Each of these is worth reading directly:

- **Martin Fowler — *Harness engineering for coding agent users.*** The guides-and-sensors
  framing, the habit of "keeping quality left," and the idea of building up a project's harness
  over time. [martinfowler.com](https://martinfowler.com/articles/harness-engineering.html)
- **OpenAI — *Harness engineering: leveraging Codex in an agent-first world.*** "Humans steer,
  agents execute," the instruction file as a "table of contents" rather than an encyclopedia,
  and the project's knowledge base as its "system of record."
  [openai.com](https://openai.com/index/harness-engineering/)
- **Stripe — *Minions: one-shot, end-to-end coding agents.*** What it takes to run agents from
  request to finished change on a real, enormous codebase, with mechanical safety steps wired
  into the agent's loop.
  [stripe.dev](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents)
- **Anthropic — *Effective harnesses for long-running agents* (Nov 2025) and *Harness design
  for long-running application development* (Mar 2026).** The engineering write-ups closest to
  this kit's own subject, from the company that trains the model. Three findings this kit
  leans on directly: an **initializer agent** that scaffolds the environment before any code
  is written (their version of this kickoff ritual); a progress log, a one-feature-at-a-time
  task list, and a session-start "bearings ritual" as the way work survives across context
  windows (the kit's Part 3.14); and — after measuring that agents asked to grade their own
  work "confidently praise it, even when mediocre" — a hard split between the agent that
  builds and the agent that judges (Part 3.8). Also the sharpest one-line reason this kit
  must keep re-auditing itself: *"Every component in a harness encodes an assumption about
  what the model can't do on its own."*
  [anthropic.com](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) ·
  [anthropic.com](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- **Andrej Karpathy — the *LLM wiki* pattern (April 2026).** The direct inspiration for the
  kit's wiki. The insight: instead of having an AI re-read raw documents from scratch on every
  question, have it build and maintain a structured wiki of plain notes that *compounds* over
  time — *"Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase"* (in
  plainer terms: the note-taking app is the workshop, the AI does the writing, and the wiki is
  the thing being built). The tedious part of any knowledge base is the bookkeeping, and, as
  Karpathy puts it, "LLMs don't get bored, don't forget to update a cross-reference, and can
  touch 15 files in one pass." The kit applies this
  to a *codebase* specifically: the running code is the source of truth, and every wiki page is
  continuously checked back against it.
  [gist.github.com](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)

> The style guide and spec are swapped out per project; the guides and templates are the
> reusable core.

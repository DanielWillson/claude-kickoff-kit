# <Project> — PRD / Spec

> **Per-project, interchangeable** (like the styleguide) — fill this in per project; it is
> not boilerplate to keep verbatim. Part of the **Harness Kit** (see
> `claude-project-kickoff.md`). Hand it to a fresh session *with* the kickoff guide.
>
> **How it feeds the build:** the kickoff's §1.6 audit and `CLAUDE.md` extract this doc's
> **load-bearing invariants** (the ones an agent could silently violate) into greps +
> contract lines; the **Open decisions** table is what you resolve before fan-out
> (Part 3's `BRIEF.md`). Keep this lean — it states **what the system should do and the
> product intent behind it**, not *how* it's built (that's the code) and not *why the code
> came to be the way it is* (that's the wiki's decision/history pages).
>
> **This is a *living* doc — the home of intent, not a fill-once artifact.** It is the source
> of truth for *intended* behavior, so keep it current the way you keep `CLAUDE.md` and the
> `README` current: **when you change behavior on purpose, update this spec in the SAME commit**
> as the change. Keep it at the repo **root** (or wherever your `reconcile-code` docs live) so
> the audit's freshness check finds it.

<!-- reconcile-code: PUT-PATHS-HERE -->
<!-- ^ Keep the line above on ONE line. List the core files that *implement this spec's intent* —
     the modules behind its capabilities/invariants (the API/router, the domain logic, the data
     model). The audit (kickoff §1.6) WARNs when any of them has a commit NEWER than this spec:
     a signal to **reconcile in whichever direction is right** — either intent changed and the
     spec is stale, or the code drifted from still-correct intent. It does NOT mean "the spec is
     wrong." Keep the list short + real; an unfilled `PUT-PATHS-HERE` placeholder is simply skipped — and
     so is a listed path you later rename without fixing it here, so if you move a file, update this line
     too (a path that no longer exists is skipped, not flagged). -->

## Problem & goal
<The one job this exists to do, in 1–3 sentences. What's broken/missing today.>

## Users & jobs-to-be-done
<Who uses it; the concrete jobs they're hiring it for. For a single-user/self-hosted
tool, say so — it changes the auth/scale/privacy posture.>

## Core capabilities (the "must")
<Bulleted, scoped. Each is a capability, not a screen. Mark MVP vs. later.>

## Non-goals (the "explicitly not")
<What this deliberately does NOT do — the cheapest scope control there is. An agent will
gold-plate without this.>

## Invariants (load-bearing rules)
<The rules that must hold everywhere — the ones a parallel agent or a cold session would
violate inconsistently (identity/dedup keys, immutable fields, sign conventions, "compute
in one place", "never load all rows", privacy/offline constraints). Each one earns an
audit grep (kickoff §1.6) and a `CLAUDE.md` line.>

## Data model / key entities (if applicable)
<Entities + the identity rule + what's mutable vs. derived. Where computed values are
derived (API layer, not client — Principle 1). Omit for non-data projects.>

## Success criteria (machine-checkable where possible)
<How you know it works: the critical-path integration test, key endpoints answer, expected
output counts. This becomes the Definition of Done (Part 3.7).>

## Production runtime (if this deploys as a running system)
<The kit hardens the *development session*; the deployed system's own operational needs live
HERE or nowhere (intake Q10). Omit the whole section for a local tool or library. Four
questions, each with an answer or an explicit "decide by <date>":
- **Path to production** — how a change reaches users (pipeline/steps), and whether a
  staging/preview step exists between merge and prod.
- **Runtime secrets** — how the *running app* loads its credentials (platform env/secret
  manager/injected at deploy) — NOT the dev `.env` the settings floor denies; include who can
  rotate them.
- **Observability** — how you'd know it's down or erroring before a user tells you (logs
  that persist, an uptime check, error tracking), and where those signals land.
- **Deploy rollback** — how a bad deploy is undone (previous artifact/revision), distinct
  from `RUNBOOK.md`'s agent-mistake recovery.>

## Open decisions
| Decision | Options | Leaning / resolved |
|---|---|---|
| <e.g. where vintage lives> | <on entity vs. on events> | <decide before fan-out> |

<This table tracks *status*. When you resolve one, the durable *why* graduates to a wiki
decision page (kickoff §1.5b) — the PRD records what was decided, the wiki keeps the
rationale over time.>

## Deferred / future
<Real but out-of-scope-now items, so they're captured without bloating the build. Convert
relative dates to absolute.>

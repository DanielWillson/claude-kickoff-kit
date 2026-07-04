# <Project> — PRD / Spec

> **Per-project, interchangeable** (like the styleguide) — fill this in per project; it is
> not boilerplate to keep verbatim. Part of the **Kickoff Kit** (see
> `claude-project-kickoff.md`). Hand it to a fresh session *with* the kickoff guide.
>
> **How it feeds the build:** the kickoff's §1.6 audit and `CLAUDE.md` extract this doc's
> **load-bearing invariants** (the ones an agent could silently violate) into greps +
> contract lines; the **Open decisions** table is what you resolve before fan-out
> (Part 3's `BRIEF.md`). Keep this lean — it states *what & why*, not *how*.

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

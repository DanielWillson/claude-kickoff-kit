# HARNESS_MANIFEST.md — what your harness assumes, and when you last checked it  ·  TEMPLATE (this project owns it)

> **Seeded by the Claude Harness Kit, then handed to you. It is now yours.** Delete this banner and
> the example rows once your own are in.
>
> **TIER-OPTIONAL.** A tiny harness — a `CLAUDE.md` plus a deny floor — does **not** need a manifest;
> skip it. Add one once the harness has several moving parts whose freshness you'd otherwise have to
> hold in your head. Scale honestly: a small project's manifest is three rows.

## What this is — and how it differs from its siblings

This is a **registry of your harness's own parts**, tracking the one axis nothing else does:
**what version or assumption each part rests on × when you last verified it × the event that makes
it stale.** Keep it from drifting into a duplicate of the two siblings it sits beside:

- **`scripts/kit-conformance.sh` checks _presence_** — *is each part installed?* (a roster).
- **`HARNESS_LOG.md` records _change_** — *what changed in the harness, and why?* (append-only history).
- **This manifest tracks _assumptions + freshness_** — *what does each part bet on, and is that bet
  still fresh?* (mutable current state).

If you find yourself copying a presence checklist or a change history in here, stop — that belongs in
one of the other two. (The "two verifiers must not disagree" rule: don't let the three become rosters
that contradict each other.)

## Why it exists

Every harness part is **a bet against a moving world** — a Claude Code version, a model generation, an
external API's behavior. When the world moves, a bet can go stale *silently*: a settings key a tool
upgrade quietly drops, a "don't forget to X" line the model no longer needs. This manifest makes
*which bets are due for a re-check* something you can **read** instead of remember. It is the
current-state companion to the shelf-life doctrine (README, *"What scales with the model, and what
doesn't"*): **permanent** parts never expire, **depreciating** parts get re-audited at every model or
tool upgrade, **appreciating** parts grow more valuable as the model improves.

## The re-verify trigger — the load-bearing column

Each row names the **event** that makes it stale, not a calendar reminder:

- **Model upgrade** — re-run the behavioral evals (§1.6b) to prove the new model helped, not
  regressed; re-run the per-line test on any *depreciating* prose (README shelf-life doctrine).
- **Claude Code (tool) upgrade** — re-run §1.4's **"prove it bites"** checks. A tool upgrade can
  **silently drop a setting**: Claude Code 2.1.201, for one, discards a *whole* `settings.json` on a
  single `//` comment, voiding every deny rule with no error. Treat a tool upgrade like a model
  upgrade — **a scheduled maintenance event, not a version bump** (item **J**).
- **Never (permanent)** — the part's force is a property of the world, not the model's judgment (the
  security floor, reconcile-against-code, independent verification); leave it alone.

## Manifest

Fill / trim rows for **this** project's harness. `Assumes` names the version or dependency the part
is pinned to; `Last verified` is the date you actually re-checked it (not the date you wrote it down).

| Component | Assumes (version / dependency) | Shelf-life | Last verified | Re-verify trigger |
|---|---|---|---|---|
| `.claude/settings.json` + managed floor | Claude Code `<cc-version>` settings schema (strict JSON, no JSONC) | depreciating | `<YYYY-MM-DD>` | **Claude Code upgrade** → re-run §1.4 (prove a denied read still blocks, bypass still rejected) |
| Security deny / sandbox floor | OS sandbox + Claude Code sandbox semantics | permanent | `<YYYY-MM-DD>` | **Claude Code upgrade** → re-prove §1.4; otherwise never |
| `CLAUDE.md` directives | current model's default behavior | depreciating | `<YYYY-MM-DD>` | **Model upgrade** → per-line test (would a fresh session get this wrong without the line?) |
| Behavioral evals (`evals/`) | current model generation | appreciating | `<YYYY-MM-DD>` | **Model upgrade** → re-run `scripts/eval.sh` (§1.6b) |
| `scripts/audit.sh` invariants | this project's code shape (paths, symbols) | depreciating | `<YYYY-MM-DD>` | **Refactor** → the audit's own safeguard-rot self-check (§1.6) flags dead anchors |

## How to use it

- **Update `Last verified` when you actually re-checked** that part — after an upgrade, or a periodic
  sweep. An old date is a *nudge*, not a failure; whether it's stale is your judgment.
- **Add a row when you add a harness part; delete a row when you retire one.** This is *current state*
  — the retirement itself belongs in `HARNESS_LOG.md`, which is the history.
- **Unfilled placeholders (`<cc-version>`, `<YYYY-MM-DD>`) mean the row was never really verified** —
  fill them or drop the row.

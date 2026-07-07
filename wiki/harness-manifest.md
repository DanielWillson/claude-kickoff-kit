# Harness manifest — the kit's own harness, what it assumes, and when last verified

> **Where this lives, and why here.** This is the Claude Harness Kit's *own* instance of the
> harness-manifest practice it ships (ROADMAP item **W**). The kit seeds a **blank
> `HARNESS_MANIFEST.md` template** at a project's repo **root**; that root name is reserved for the
> template, so the kit keeps its *own* filled-in manifest here under `wiki/`, beside its other
> self-knowledge ([[harness-log]], [[SCHEMA]], [[index]]). Same practice, run on the kit itself —
> exactly as it does for the change-log. Being kit-internal, this *may* cite maintainer docs
> (`ROADMAP.md`), which the shipped root template must never do.

**What this tracks (and what it doesn't).** Per the shipped template: this registers the ONE axis the
kit's other verifiers don't — **what each harness part assumes × when it was last verified × the event
that makes it stale**. Presence is [`scripts/kit-conformance.sh`](../scripts/kit-conformance.sh)'s job;
change history is [[harness-log]]'s. This is assumptions + freshness only.

**Shelf-life classes** (README, *"What scales with the model"*): **permanent** (force comes from the
world — never expires), **depreciating** (existed because a model/tool once needed it — re-audit at
every upgrade), **appreciating** (worth more as the model improves).

_Last full sweep: 2026-07-06._

| Component | Assumes (version / dependency) | Shelf-life | Last verified | Re-verify trigger |
|---|---|---|---|---|
| `templates/*.settings.json` + managed floor | **Claude Code 2.1.201** settings schema — strict JSON, **no JSONC** (verified via its `--debug` load log) | depreciating | 2026-07-06 | **CC upgrade** → re-confirm strict-JSON-only; if JSONC (#17968) ships, the comment-free rule reverses (item Y) |
| Security deny / sandbox templates | OS sandbox + CC sandbox governs Bash only; native/MCP/WebFetch are permission-only | permanent | 2026-07-06 | **CC upgrade** → re-prove the deny/sandbox split (§1.4); the *principle* is permanent |
| `claude-audit-base.sh` + `scripts/kit-conformance.sh` | POSIX bash 3.2+; `python3` as the strict-JSON proxy | depreciating | 2026-07-06 | **CC settings-parser change** → re-check the `json.load` gate still matches what CC accepts |
| `evals-template/` + `claude-eval-base.sh` | current model generation; `EVAL_CMD`/`EVAL_JUDGE_CMD` stub seam | appreciating | 2026-07-06 | **Model upgrade** → the eval-runner selftest is model-free, but the *fixtures'* golden values may shift |
| `CLAUDE.md` / kickoff prose (directives, coaching) | current model's default behavior | depreciating | 2026-07-06 | **Model upgrade** → per-line test (the July 2026 pass already cut stale coaching + reversed structured-output advice) |
| README field citations (METR, Veracode, SWE-Bench, …) | sources current as of the dated verification | depreciating | 2026-07-03 | **Periodic** → re-fetch each URL before reuse (Lesson 7); date-stamped in README §"Field evidence" |
| CI selftest (`.github/workflows/selftest.yml`) | GitHub Actions; `actions/checkout` pinned to a SHA | permanent | 2026-07-06 | **Action bump** → re-pin the SHA (the *practice* of pinning is permanent) |

**Known gap (item M, still open).** Version-specific facts (`2.1.201`, red-team stats) still live
scattered across several kit docs. This manifest gives them a *dated home* for harness components, but
does not itself sweep every inline mention — that doc-wide date-stamping pass is item **M**.

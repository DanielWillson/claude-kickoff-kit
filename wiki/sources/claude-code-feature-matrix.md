---
title: "Claude Code multi-agent feature matrix (verified 2026-07-01)"
type: source
status: current
updated: 2026-07-01
verified: 2026-07-01
code: [../../claude-project-kickoff.md]
related: ["[[anthropic-engineering]]", "[[2026-07-audit-pass]]"]
summary: "What's stable vs. preview vs. experimental in Claude Code's multi-agent tooling, from the official docs — backs Part 3's probe paragraph"
---

# Claude Code multi-agent feature matrix

Verified against the live official docs (code.claude.com/docs) on **2026-07-01**. This
page backs the kit's Part 3 probe lead-in. **This is exactly the kind of page that rots**:
re-verify before trusting it after any major Claude Code release — better yet, do what
Part 3 says and probe the live environment instead of trusting this page.

## Stable & universal ("The Claude Code CLI and everything that runs locally work identically on every provider" — [feature-availability](https://code.claude.com/docs/en/feature-availability))

- **Subagents** ([sub-agents](https://code.claude.com/docs/en/sub-agents)) — own context
  window, return a summary. Per-agent `model` frontmatter (`sonnet`/`opus`/`haiku`/`fable`/
  full ID/`inherit`); `--agents` JSON flag (model, tools, permissionMode, maxTurns,
  background, isolation, effort); background execution (Ctrl+B); nesting to fixed depth 5
  (v2.1.172+); resume via SendMessage; per-agent memory/MCP/hooks/skills; built-ins
  Explore (Haiku, read-only), Plan, general-purpose. Task tool renamed **Agent** in
  v2.1.63 (alias kept).
- **Worktrees** ([worktrees](https://code.claude.com/docs/en/worktrees)) — `--worktree/-w`,
  checkouts under `.claude/worktrees/`, `isolation: worktree` per subagent,
  `.worktreeinclude`, WorktreeCreate/Remove hooks.
- **Hooks** ([hooks-guide](https://code.claude.com/docs/en/hooks-guide)) — incl.
  SubagentStart/Stop, per-subagent frontmatter hooks.
- **Plan mode** ([permission-modes](https://code.claude.com/docs/en/permission-modes)) —
  read-only research → proposed plan → approved edit mode; `opusplan` pairs models.
- **Headless** ([headless](https://code.claude.com/docs/en/headless)) — `claude -p`,
  `--output-format`, **`--json-schema` for typed output**, `--continue/--resume`.
- **Checkpointing** ([checkpointing](https://code.claude.com/docs/en/checkpointing)) —
  automatic per user prompt; `/rewind`; **blind to bash-command file changes**; not a git
  substitute.
- **Compaction** ([context-window](https://code.claude.com/docs/en/context-window)) —
  automatic; documented survival rules: project-root CLAUDE.md + auto memory **reload from
  disk**; conversation-only instructions can be lost; skill bodies re-inject capped
  5k/skill, 25k total. Applies to subagents too.
- **Dynamic workflows** ([workflows](https://code.claude.com/docs/en/workflows)) —
  v2.1.154+, all paid plans and all providers; **Pro must enable in /config**.

## Preview / experimental (never load-bearing without checking)

- **Agent view** (`claude agents`, `/bg`) — research preview, v2.1.139+; background
  sessions auto-move into worktrees.
- **Agent teams** ([agent-teams](https://code.claude.com/docs/en/agent-teams)) —
  experimental, disabled by default (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`); **~7× token
  cost** with teammates in plan mode ([costs](https://code.claude.com/docs/en/costs));
  **no worktree isolation** (partition files manually); no per-teammate permission modes
  at spawn; teammates don't inherit the lead's /model.
- **Model-spawned forks** (/fork is default-on since v2.1.161; *Claude spawning forks
  itself* is labeled experimental).

## Doesn't exist (dead ends — don't cite these)

- **"Swarms"** — zero occurrences in official docs; community vocabulary only.
- **Per-run token budget** — no such primitive; real levers are `maxTurns`, `effort`,
  spend limits, `MAX_THINKING_TOKENS`, `CLAUDE_CODE_MAX_OUTPUT_TOKENS`.
- **TeamCreate/TeamDelete tools** — removed (pre-v2.1.178 docs are stale).

## Session-survival facts the kit leans on

- A boundary stated only in conversation **can be lost on compaction**; files and
  deny/ask rules reload/persist — official basis for kickoff Principle 4 / §1.3a.
- Sessions resume via `--continue` / `--resume` / `--from-pr`; transcript JSONL format is
  declared internal/unstable.

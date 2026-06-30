# Claude Kickoff Kit

A portable set of docs you hand to a fresh Claude Code session **at the start of a new
project** — a setup ritual, a working philosophy, and the templates that seed a project's
durable knowledge, health checks, and docs. It is *project-agnostic scaffolding*: used once
per project, and **never committed into the project's own repo**.

## What's in here
- **`claude-project-kickoff.md`** — the entry point. The setup ritual (git, a sandboxed
  `.claude/settings.json`, `CLAUDE.md`, the audit, the wiki), the building principles, and the
  autonomous / multi-agent playbook. Read this first; it drives the rest.
- **`llm-wiki-kickoff.md`** — how to stand up the project's self-maintaining,
  reconcile-against-code knowledge **wiki** (the depth + decision/incident-history layer).
- **`claude-audit-base.sh`** — a stack-agnostic code-health **audit** you copy to
  `scripts/audit.sh` and grow with each invariant and every fixed bug.
- **`prd-template.md`** — a fill-in PRD/spec skeleton (what & why, invariants, open decisions).
- **`readme-template.md`** — a fill-in, **human-facing** project README stub (the project's
  front door), with a `reconcile-code` anchor so the audit flags it when it drifts from the code.
- **`styleguide.html`** — an *example* per-project design styleguide (swap in your own).
- **`templates/`** — copy-paste **settings templates**: `managed-settings.template.json` (the machine-wide
  hard floor), `project.settings.json` (the committed per-repo floor), and `project.settings.local.json.example`
  (per-machine sandbox-enable + `autoMode`). See `templates/README.md` for the three-layer model.
- **`CHEATSHEET.md`** — the verified Claude Code permission/sandbox mechanics (Bash-only sandbox,
  deny-rules-are-a-sieve, settings precedence + array-merge, launch-dir-only load, macOS egress limits).
- **`securing-claude-sessions.md`** — a narrative **field guide** to the security model (the five
  enforcement levels, defense-in-depth, *"a control is only as strong as the agent's inability to reach
  it"*). The teaching companion to `CHEATSHEET.md`; written against an example deployment.

## How to use it
At a new project's kickoff, hand Claude the relevant files (always the kickoff guide; the
others as the project needs them). Claude runs the setup, internalizes the principles, and
produces the project's **durable artifacts** — `CLAUDE.md`, `.claude/settings.json`,
`scripts/audit.sh`, `wiki/`, `README.md`, and the filled-in PRD. *Those* live in the project
repo; this kit does not. After buildout the kit drops away — ongoing work reads the project's
lean `CLAUDE.md` + wiki, never this kit.

## Design stance
- **Self-improving knowledge** — the wiki (and the project README) reconcile against the
  code, so docs can't silently rot.
- **Lean on the repo, not machine-local memory** — project knowledge lives in the repo (wiki
  + `CLAUDE.md` + commit bodies); memory is for user-level preferences only, and a
  project-specific fact never goes in global `~/.claude/CLAUDE.md` (it would pollute every
  other project). Default any project fact to the wiki.
- **Tool-agnostic by the repo, not by one agent** — the durable rules live where *any* tool
  reads or runs them: the contract's *content* (read by any LLM/tool/human) and the audit
  (run on demand or in CI). Claude-specific machinery (the Stop-hook auto-commit,
  `.claude/settings.json`, `/wiki`) is a convenience *adapter* on top. When a second
  committer is in play (another LLM, a teammate, CI), a coarse secret-only `git` pre-commit
  hook + the audit-in-CI carry the guarantee (kickoff §1.3b). Auto-commit itself can't be
  made tool-agnostic — git has no commit-on-change event — so only the *rules* travel, not
  the *act* of committing.
- **Scaffolding vs. artifacts** — the kit is used once; only its outputs persist (the audit
  even warns if a kit source file gets committed into a project).
- **The hard floor is machine-level, not repo-level** — the un-negotiable *security* floor (no-bypass,
  credential denies, the OS sandbox) lives in **root-owned managed settings + the OS sandbox** (kickoff
  **Part 0**), because a committed `.claude/settings.json` is agent-editable and therefore *soft*. The committed
  per-repo floor still carries project specifics and the gates that should travel to teammates; array-merge keeps
  both layers live at once. The model: *the sandbox is the boundary; `deny`/`ask` are deterministic backstops;
  the classifier is probabilistic; prose is not a control* (see `CHEATSHEET.md`).

> The styleguide and PRD are interchangeable per project; the guides and templates are the
> reusable core.

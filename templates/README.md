# Settings templates — the three-layer model

Claude Code reads settings from four scopes. **Precedence:** `managed > CLI > local > project > user`.
Within `permissions`: **deny > ask > allow**. Array settings (`deny`/`ask`/`allow`/`allowedDomains`/
`excludedCommands`) **MERGE across scopes** — so a managed `deny` is authoritative *and* a repo can still add
its own `allow`/hosts. You get un-editable denies **without** the heavy enterprise `allowManaged*Only` locks.

**A control is only as strong as the agent's inability to reach it.** Weakest → strongest:
`CLAUDE.md` / `autoMode` prose (advisory) → committed project settings (agent-editable) →
`settings.local.json` (per-machine) → user settings → **managed (root-owned, un-editable)** →
**the OS sandbox** → **server-side (GitHub rulesets)**. *Hard* guarantees live only in the last three.

| File | Where it goes | Hardness | Carries |
|---|---|---|---|
| **`managed-settings.template.json`** | hand-placed at `/Library/Application Support/ClaudeCode/managed-settings.json` (root-owned) | **HARD** | the generic floor: no-bypass, credential read/write denies, destructive-Bash denies, the OS sandbox + credential denies, universal hosts/caches, irreversible-op `ask` gates. **Zero project names.** |
| **`project.settings.json`** | committed `.claude/settings.json`, travels with the repo | soft (agent-editable; changes on `git pull`) | THIS project's `allow`/`ask`, its hosts, its secret denies, its hooks. **Never `defaultMode`.** |
| **`project.settings.local.json.example`** | per-machine, gitignored (copy to `.claude/settings.local.json`) | soft | per-repo `sandbox.enabled` (if scoping per-repo) + `autoMode` advisory policy. |

`defaultMode: "auto"` goes ONLY in your **user** `~/.claude/settings.json` — it is silently ignored from project/local.

## Why managed is the hard floor (and the committed file is not)

The committed `.claude/settings.json` is the right home for project specifics and for gates that should *travel*
to teammates — but it is a **mutable input**, not a boundary: the agent can edit it, and a `git pull` can change
it. The only settings the agent genuinely cannot reach are **managed** (root-owned) and the **OS sandbox**. So put
the un-negotiable floor in managed, and keep the committed file for convenience + project-specific rules.

The array-merge rule is what makes this practical: because a managed `deny` merges with (and outranks) everything
below it, one generic managed floor protects **every** repo on the machine *while still letting each repo add its
own `allow`s and hosts*. That is the whole point — hardness without enterprise lockdown.

## Install order

1. **Genericize and install the managed floor.** Add your own infra hosts to `network.allowedDomains`; remove what
   doesn't apply. Hand-place it, then run **`claude doctor`** (invalid/too-old keys are silently stripped) and
   **`/status`** (confirm the source resolves to `managed`). See `../claude-project-kickoff.md` **Part 0** for the
   staged rollout (shakeout mode → per-repo inventory → flip `allowUnsandboxedCommands:false`).
2. **Per repo:** copy `project.settings.json` to `.claude/settings.json`; fill in the daily commands, hosts, and
   sensitive paths. Commit it.
3. **Optional:** copy `project.settings.local.json.example` to `.claude/settings.local.json` (and gitignore it).
4. **Once:** set `defaultMode:"auto"` in your user `~/.claude/settings.json`.
5. **Verify it bites** (post-restart): read `~/.ssh/id_rsa` → blocked; `cat .env` → blocked;
   `git push --force` on a throwaway branch → **prompts**; attempt bypass mode → **rejected** (and `/status`
   shows the source as `managed`).

See **`../CHEATSHEET.md`** for the verified mechanics behind all of this.

> **Genericize before sharing.** A managed file carrying machine-specific hosts (a tailnet IP, an internal domain)
> leaks machine specifics into a shared kit — exactly what the audit forbids. Ship only universal hosts; add your own
> locally.
>
> **Managed can only be a *template* here.** It is root-owned and hand-placed; a repo can never *activate* a managed
> file. The repo carries the template; you install it by hand.

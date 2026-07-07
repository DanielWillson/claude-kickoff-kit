# Settings templates — the three-layer model

Claude Code reads settings from four scopes. **Precedence:** `managed > CLI > local > project > user`.
Within `permissions`: **deny > ask > allow**. Array settings (`deny`/`ask`/`allow`/`allowedDomains`/
`excludedCommands`) **MERGE across scopes** — so a managed `deny` is authoritative *and* a repo can still add
its own `allow`/hosts. You get un-editable denies **without** the heavy enterprise `allowManaged*Only` locks.

## ⚠ These files are STRICT JSON — no comments

Claude Code parses `settings.json` (project, user, **and** managed) as **strict JSON — not JSONC.** A single
`//` or `/* */` comment makes Claude Code **silently drop the ENTIRE file**: every `deny`/`ask`/hook rule stops
applying, with **no error** — so a well-meaning banner comment silently voids your whole floor. *(Verified
against Claude Code **2.1.201**, 2026-07-06, via its own settings-load debug log — a comment-bearing file
loaded `0 rule(s)`; JSONC support is [anthropics/claude-code#17968](https://github.com/anthropics/claude-code/issues/17968),
still open. If it ever ships this reverses — and re-checking it is exactly item **Y**'s job.)*

**So these templates ship comment-free, and all their teaching lives in this README.** When you adapt one,
keep it valid JSON — put notes here or in `CLAUDE.md`, never in the JSON. Both `scripts/audit.sh` and
`scripts/kit-conformance.sh` **FAIL** a settings file that isn't strict-JSON-loadable, so a stray comment
surfaces loudly instead of silently voiding your gates.

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

## Wiring an action-risk gate (comment-free)

If the project can act *beyond editing its own code* (publish, send a message, delete non-git state, spend),
gate that command deterministically (kickoff §1.3c). The kit used to tag the settings rule with an inline
`// action-risk` comment — that silently voided the whole file, so it's gone. The comment-free join:

1. In `CLAUDE.md`'s `## Action-risk gates` table (under the `<!-- action-risk -->` marker — markdown, so
   comments are fine there), name the **exact settings rule** in the last column, e.g. `` `Bash(blog-publish *)` ``.
2. Add that **same rule, verbatim and comment-free**, to `permissions.ask` (or `deny`) in `.claude/settings.json`.

`scripts/audit.sh` (and `scripts/kit-conformance.sh`) join the two **by the rule string** and WARN if the table
names a rule that isn't wired — proving the *specific* dangerous command is gated, not just described.

## Gating outbound access — MCP and web (comment-free)

`project.settings.json` ships two default-off outbound gates, because MCP servers and the native web tools are
**unsandboxed, un-audited surfaces equivalent in risk to Bash** (kickoff §1.3a) — the OS sandbox governs *Bash*
egress only, never these.

- **MCP is denied by default** — `deny: ["mcp__*"]` turns off **every** MCP tool across all servers (the exact
  form the [permissions docs](https://code.claude.com/docs/en/permissions) bless for this). **A `deny` is
  absolute:** it outranks `ask` and `allow` at *every* scope and **carries no exceptions**, so you **cannot**
  re-enable one server by adding an `allow` rule next to it. To use a server: **remove the `mcp__*` line**
  (optionally replace it with per-server denies like `mcp__somebadserver` for the ones you still want off),
  then configure that server — its tools prompt on first use. For centrally-enforced allowlisting, use
  **managed** `allowManagedMcpServersOnly` + `allowedMcpServers`.
- **Web fetches are allowlisted by domain.** `WebFetch` prompts per domain by default; pre-approve trusted hosts
  with `allow: ["WebFetch(domain:example.com)"]` (a `deny` on bare `WebFetch` removes the tool entirely and
  can't carry per-domain exceptions, so allowlist rather than deny). For a **hard** lock that auto-blocks every
  other host with no prompt, set **managed** `sandbox.network.allowManagedDomainsOnly: true`. Note
  `sandbox.network.allowedDomains` gates only *sandboxed Bash* egress — not `WebFetch`/`WebSearch`.

## Adapting `project.settings.json`

Comment-free, so adapt by structure: `allow` is THIS project's routine daily commands (intake Q4 — swap in your
stack's build/test/lint); `ask` gates what leaves the machine (push/merge) plus any action-risk rule; `deny` is
this project's secret reads + native writes to its own guards — add the load-bearing paths that must never be
rewritten. The shipped `deny` now also carries the **machine-credential read denies** (`~/.ssh`, `~/.aws`,
`~/.npmrc`, `**/*.pem`, `**/*.token`) belt-and-suspenders — redundant with the managed floor on purpose, so a
machine that never installed the floor still can't read them. Keep **zero** project-specific names in the
**managed** template; those live per-repo, here.

## CI: wire the audit into a required check

`ci-audit.yml` is a starter GitHub Actions workflow — **copy it to `.github/workflows/audit.yml`.** It runs
`scripts/audit.sh` on every push/PR: the tool-agnostic enforcer that fires no matter who committed (a different
LLM/tool, a human, or a branch that skipped the client-side pre-commit hook — which never runs in CI). It gates
on the audit's `RESULT: FAIL` only (WARNs are surfaced, not fatal, so a lean repo isn't red on day one); flip to
strict by replacing the run step with a bare `bash scripts/audit.sh`. The token is least-privilege
(`contents: read`) and `actions/checkout` is pinned to a full commit SHA per §1.3b — re-pin when you bump it.

## A note on the managed `docker` escalation gates

The managed template `ask`-gates `docker run --privileged` and docker-socket bind-mounts (`-v`/`--volume`/
`--mount` of `/var/run/docker.sock`) — well-known one-command host-root escapes. Treat these as a **best-effort
backstop, not a boundary:** `docker *` is in the sandbox's `excludedCommands` (it runs **unsandboxed**), so the
`ask` rule is the *only* gate, and Bash argument-matching is fragile — a different flag spelling, argument order,
or wrapper can slip past it (the permissions docs warn about exactly this). The real boundary against a container
escape is not running untrusted `docker` at all; the gate just makes the obvious escalations prompt.

See **`../CHEATSHEET.md`** for the verified mechanics behind all of this.

> **Genericize before sharing.** A managed file carrying machine-specific hosts (a tailnet IP, an internal domain)
> leaks machine specifics into a shared kit — exactly what the audit forbids. Ship only universal hosts; add your own
> locally.
>
> **Managed can only be a *template* here.** It is root-owned and hand-placed; a repo can never *activate* a managed
> file. The repo carries the template; you install it by hand.

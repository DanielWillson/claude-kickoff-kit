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

**So the two real templates (`managed-settings.template.json`, `project.settings.json`) ship comment-free,
and all their teaching lives in this README.** When you adapt one, keep it valid JSON — put notes here or in
`CLAUDE.md`, never in the JSON. Both `scripts/audit.sh` and `scripts/kit-conformance.sh` **FAIL** a
`.claude/settings.json` that isn't strict-JSON-loadable, so a stray comment there surfaces loudly. **The one
deliberate exception: `project.settings.local.json.example` is JSONC** — safe only because the `.example`
extension keeps it inert. That safety ends at copy time, and **no shipped check covers `settings.local.json`**
— so when you copy it (step 3 below), **delete every `//` line**, or the whole file (including its
`autoMode` policy and any sandbox enable) is silently void.

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
3. **Optional:** copy `project.settings.local.json.example` to `.claude/settings.local.json` (and gitignore it) —
   then **strip every `//` line** (the example is JSONC; a copied comment silently voids the whole file, and no
   check covers `settings.local.json`).
4. **Once:** set `defaultMode:"auto"` in your user `~/.claude/settings.json`.
5. **Verify it bites** (post-restart): read `~/.ssh/id_rsa` → blocked; `cat .env` → blocked;
   `git push --force` on a throwaway branch → **prompts**; attempt bypass mode → **rejected** (and `/status`
   shows the source as `managed`); **and an out-of-project write** (e.g. `touch ~/Downloads/probe.txt`) →
   **blocked**. That last one is the only check on this list that proves the **sandbox** is actually on —
   the first four all pass on permission denies alone, so without it you can run the whole checklist green
   with the wall down (kickoff Part 0 names the same tell).
6. **Live-fire the canaries** (post-restart; see "Canary rules" below for why). Ask the agent to run,
   as three separate top-level commands: (a) `kit-canary-denied --probe` — must be **denied**; if the
   shell answers `command not found`, your deny rules are **inert** in that context and nothing else on
   the deny list can be trusted. (b) the same command **from an Agent-tool subagent** — subagents are the
   least-supervised context, and the 2026-07-08 incident is evidence that enforcement there can differ
   from the main loop. (c) `kit-canary-excluded --probe` — this command is *both* deny-listed *and* on
   `excludedCommands`; if it executes, **exclusion bypasses your deny rules on this machine**, and every
   excluded command (`gh *`, `docker *`, …) is gated by the classifier alone — treat their deny rules as
   decoration and move those guarantees elsewhere.
7. **Verify it flows** (the other half — a wall test alone is not enough): every *sanctioned* path must
   demonstrably work. Minimum: an agent-driven `git push` of a throwaway branch **succeeds** after its
   ask-prompt. A sanctioned path that is accidentally broken is not "extra safe" — it *manufactures
   route-around pressure*: the 2026-07-08 credential incident began with six subagents sent at a push
   that was broken by construction (the sandboxed `gh` credential helper couldn't read its own denied
   token store), and two of them "diagnosed" the failure by printing the live token. If the push canary
   fails here, **stop and fix the push path before any agent is ever told to push** (see kickoff Part 0).

## Credential-print denies + canary rules (added 2026-07-08, after a real incident)

Both templates now carry a **credential-materialization deny block** — commands whose *output is a live
credential*: `gh auth token`, `gh auth git-credential`, `gh auth status` (`--show-token` prints the token)
and `gh config` (`gh config get … oauth_token` can too), `git credential*` **and** the hyphenated
`git-credential*` helper binaries, and macOS keychain readers (`security find-generic-password`,
`find-internet-password` — where git's HTTPS credentials actually live — and `dump-keychain`). The old
list had three exact-string gaps (`git credential ` with a trailing space missed the hyphenated forms;
`gh auth git-credential` matched nothing; only *generic*-password was covered) and a full live GitHub
credential was printed into an agent transcript through them on 2026-07-08. Pattern-matching rots around
exact-string thinking: when you deny a command family, deny the *family* (bare form, hyphenated form,
sibling subcommands), and mirror the same list into any prompt that forbids it (kickoff Part 3).

Both templates also carry **canary rules** — deny rules for two commands that don't exist
(`kit-canary-denied`, `kit-canary-excluded`). They cost nothing and buy the only thing that keeps a deny
list honest: **a rule you can safely test-fire.** You can never live-test `Bash(gh auth token*)` — a
successful test *is* the leak — but the canary has three cleanly distinguishable outcomes: **denied**
(enforcement live), **`command not found`** (rules inert — the floor is down), or a permission *prompt*
(enforcement odd — investigate). `kit-canary-excluded` is additionally listed in `sandbox.excludedCommands`,
so it empirically answers a question the docs don't: **do deny rules still apply to sandbox-excluded
commands?** Run all three probes at install, after every Claude Code upgrade, and from a subagent (install
step 6). The audit's PERMISSION FLOOR section checks the canaries are *present*; only a live session can
check they *fire* — a permission rule is evaluated on the agent's top-level command string, so a canary
run from *inside* a script tests nothing.

The managed template also now sandbox-denies Bash reads of **`~/.claude/projects`** — session transcripts.
Transcripts are where leaked material actually lands (the 2026-07-08 credential was printed into one, and
`.jsonl` matches no credential-file glob), so treat them as a secret store. **Two caveats before you trust
it:** (1) **verify the key with `claude doctor`** after install — `sandbox.filesystem.denyRead` was added
from the incident and, if the schema differs in your Claude Code version, an invalid key is *silently
stripped* (the exact inert-rule failure this kit warns about). (2) `~/.claude/projects` also holds your
**memory dir** and the kit's own **transcript-scanning skills** — this blocks their *Bash* reads (native
Read / MCP session tools are unaffected; the sandbox governs Bash only). If you rely on those, **scope the
entry to a transcript subdir** rather than dropping it, or drop it knowingly.

**Two residuals this pass does NOT close** (know them):

1. *Excluded-command × deny.* The `gh`-family denies only help *if deny rules fire for an `excludedCommands`
   entry* — and on the incident machine both leaked commands were `gh` (excluded), one *already* deny-covered
   yet it ran. The docs don't state whether exclusion bypasses deny. Until the `kit-canary-excluded` probe
   (install step 6) settles it on your machine, treat the `gh`-family denies as **belt-and-suspenders, not a
   boundary.**
2. *Wrapper evasion.* A `permissions.deny` rule matches per-subcommand from the start, so Claude Code's
   operator-splitting catches `cd /tmp && gh auth token` (the `&&` subcommand is checked) — but an
   **interpreter or substitution wrapper evades it**: `bash -lc 'gh auth token'`, `X=$(gh auth token)`,
   `python3 -c '…'`. Deny rules alone can't see inside those.

Both residuals point the same way: the deterministic catch for wrapped credential-printing is a **PreToolUse
guard hook** — it runs a full-string regex *before* permission/sandbox evaluation, so it catches operator- and
interpreter-wrapped forms a prefix-glob deny cannot (a regex still can't catch a command *split* into pieces,
e.g. a Python arg-list — the true boundary there is capability-removal + the sandbox). Deny rules stay the lean
default (a code-only project needs nothing more); the hook is the **power option for credential-handling
projects**, and the kit now ships one — see the next section. Full analysis:
`../wiki/decisions/2026-07-credential-incident.md`.

## Shipping the PreToolUse guard hook (`pretool_guard.py` — the power option)

The kit ships an **optional**, stack-agnostic guard at `templates/pretool_guard.py` +
`templates/pretool_guard.selftest.sh`. **Adopt it when the project HANDLES CREDENTIALS** (publishes, calls an
authed API, holds a token) — i.e. exactly when the two residuals above bite. A code-only project can skip it and
rely on the deny rules. What it adds over deny rules: a full-command-string regex that catches the wrapped
credential-print forms (`bash -lc '…'`, `$(…)`) deny rules miss, plus native-tool secret-path blocking as a
second mechanism. What it is NOT: a boundary — it's a fail-closed *backstop* whose protocol still fails **open**
on an infra error (a crash or missing `python3` exits nonzero-but-not-2 and the call proceeds), and which a
command-splitting evasion still slips (the self-test documents both). To adopt:

1. Copy both files to `<repo>/hooks/`. Keep `Edit(hooks/**)`/`Write(hooks/**)` in `permissions.deny` (already in
   `project.settings.json`) so the agent can't edit the guard it's subject to.
2. Register it in `.claude/settings.json` (comment-free JSON):
   ```json
   "hooks": { "PreToolUse": [ { "matcher": "Bash|Read|Edit|Write|MultiEdit",
     "hooks": [ { "type": "command",
       "command": "python3 \"$CLAUDE_PROJECT_DIR/hooks/pretool_guard.py\"" } ] } ] }
   ```
3. Run `bash hooks/pretool_guard.selftest.sh` (24 assertions) and wire it into CI beside your other checks.
4. **Prove it fires in a live session** — feeding it JSON only tests the script, not that Claude Code invoked
   it: run the `kit-canary-denied --probe` canary in the main loop AND from an Agent-tool subagent (install
   step 6). A guard that isn't registered, or doesn't fire in subagents, is inert exactly where it matters most.

For a HARD guarantee (agent literally cannot reach the guard), copy it to a root-owned path and point a MANAGED
hook at it with `allowManagedHooksOnly:true` — heavier; the lean default is the committed copy + the `hooks/**`
deny + server-side `CODEOWNERS` review on `hooks/`.

**High-risk / credential-adjacent sessions** can also suppress transcript writes entirely (belt to the
transcript `denyRead` above): set `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` (all modes) or launch a one-off
non-interactive run with `--no-session-persistence`. Transcripts otherwise persist at
`~/.claude/projects/<project>/<session-id>.jsonl` (retention: `cleanupPeriodDays`, default 30) — which is why a
printed credential outlives the session until rotated *and* purged.

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

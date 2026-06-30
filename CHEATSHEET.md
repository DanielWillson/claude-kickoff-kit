# Claude Code hardening — verified mechanics cheat-sheet

Verified against Claude Code 2.1.x docs (plus noted live checks). The one-line model:

> **The OS sandbox is the boundary. `deny`/`ask` rules are *deterministic* backstops. The auto
> classifier is a *probabilistic* backstop. `CLAUDE.md` / `autoMode` prose is *not* a control.**

*New here? Read the narrative field guide [`securing-claude-sessions.md`](securing-claude-sessions.md) first to
build the mental model — this sheet is the terse reference behind it.*

## The layers (weakest → strongest)
A control is only as strong as the agent's inability to reach it.
1. **`CLAUDE.md` / `autoMode` prose** — advisory; the classifier reads it, but it's probabilistic and prompt-injectable. **Never a boundary.**
2. **Committed project `.claude/settings.json`** — travels with the repo, but **agent-editable** (and changes on `git pull`) → soft.
3. **`.claude/settings.local.json`** — per-machine, gitignored → soft.
4. **User `~/.claude/settings.json`** — personal prefs. The ONLY place `defaultMode:"auto"` works (ignored in project/local).
5. **Managed `/Library/Application Support/ClaudeCode/managed-settings.json`** — root-owned, un-overridable, the agent can't edit it. **Hard floor.**
6. **The OS sandbox** (Seatbelt on macOS / bubblewrap on Linux) — OS-enforced confinement of Bash.
7. **Server-side** (GitHub branch rulesets) — the agent can't reach them at all.

Hard guarantees live in 5 / 6 / 7. Convenience + project-specifics live in 2 / 3 / 4.

## Precedence & merge
- Settings precedence: **managed > CLI > local > project > user**.
- Permissions: **deny > ask > allow** (a deny in any scope wins; `ask` is evaluated before `allow`).
- Array settings **MERGE across scopes** → a **managed `deny` is authoritative without** the heavy `allowManaged*Only` locks. Un-editable denies *and* per-repo allows at the same time.
- `permissions.deny` applies in **every** mode. `disableBypassPermissionsMode:"disable"` blocks bypass entirely. `dontAsk` mode is **fail-closed** (auto-denies anything not pre-allowed — good for CI).

## The sandbox is Bash-only
- It governs **Bash and its child processes ONLY.** Native `Read`/`Write`/`Edit`, `WebFetch`/`WebSearch`, and MCP tools run **outside** it — permission rules only.
- It **auto-denies Bash writes to `settings.json` at every scope** (Bash can't rewrite its own policy) — but an **in-repo hook script** (`hooks/pre-commit`) is a normal workdir file; a Bash redirect can overwrite it. **In-repo guard hooks are backstops, not boundaries** — the hard guarantee is server-side (CODEOWNERS + branch protection). The `Edit/Write(hooks/**)` deny covers *native* tampering; for a hard guarantee, go server-side.
- `sandbox.enabled` can be set **per-repo** (project/local) OR machine-wide (managed). Managed booleans win and can't be downgraded.
- `autoAllowBashIfSandboxed` (default **true**, valid key): sandboxed Bash auto-runs without prompting on a bare `Bash` ask — the speed lever.

## Deny-rules are a sieve — only the sandbox is a general defense
A `Read`/`Edit` deny binds native file tools AND recognized Bash readers (`cat`/`head`/`tail`/`sed`/`grep`) — but **NOT arbitrary code reading a file** (`python3 -c open()`, `php -r`). Deny patterns are also bypassed by:
- non-`rm` deletion (`mv` / `>` / `truncate` / `os.remove` / `find -delete`),
- two-step splits (download, then exec),
- native `Write` (outside the Bash sandbox),
- another repo's session (cross-project).

**The OS sandbox is the only general defense.** Close credential reads with BOTH `permissions.deny Read(...)` (native + `cat`) AND `sandbox.credentials` / `sandbox.filesystem.denyRead` (the code-interpreter path) — and only with the sandbox **on**.

> *Empirical, one machine:* a 44-scenario red-team of a **sandbox-OFF** config found only **5** attacks deterministically blocked — the rest were classifier-only or open. Treat deny-lists as backstops, never as the boundary.

## Network egress (macOS)
- `sandbox.network.allowedDomains` binds **sandboxed Bash egress only** — not `WebFetch`/`WebSearch` (their own `WebFetch(domain:…)` permission) or MCP.
- macOS enforcement is **OS-level Seatbelt via a proxy**, allow-decided from the **client-supplied hostname** with **no TLS inspection** — a real boundary against accidental/naive egress, but **not a complete isolation boundary** (docs note domain-fronting can reach unlisted hosts). Not exfil-proof; the real anti-leak controls are **deny the read** + **no high-value secret on the machine**.
- `allowManagedDomainsOnly`: **false** (default) = the allowlist is a *seed* — unlisted hosts prompt / are classifier-judged, and repos may add hosts. **true** = a hard wall, but it **ignores all repo/user `allowedDomains`** (managed becomes the sole source) — incompatible with a per-repo-hosts model.
- **SMB / network mounts:** Seatbelt enforces file read/write rules on SMB shares **identically to local disk** (sandboxing works on a NAS). The SMB I/O itself isn't a Bash socket, so the network proxy doesn't gate the mount.

## Two gotchas that bite
- **Project `.claude/settings.json` loads ONLY from the launch directory** — no upward walk to parents, and a nested `subdir/.claude/settings.json` is ignored. (Commands & output-styles *do* search parents; settings do **not**.) A project launched from a parent dir needs its settings in that parent's `.claude/`.
- **Nothing is live until you restart.** `sandbox.*` changes initialize at session start. A tell that you're *not* yet sandboxed: the session can still write outside its project dir (e.g. to `~/Downloads`). Always run **`claude doctor`** + **`/status`** after any managed change — invalid keys are silently stripped.

## `excludedCommands` = your residual surface
Listed commands run **unsandboxed** (full filesystem + network) and auto-run — classifier-only. Keep the list minimal and `ask`-gate the mutating subcommands (`terraform apply`/`destroy`, `gcloud … delete`).

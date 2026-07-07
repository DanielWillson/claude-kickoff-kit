# TOOL_INVENTORY.md — what has access, and how to pull the plug  ·  TEMPLATE (this project owns it)

> **Seeded by the Claude Harness Kit, then handed to you. It is now yours.** Delete this banner
> and the example rows once your own are in.
>
> **TIER-OPTIONAL.** If the agent here has **no** tools beyond editing this repo's own files — no
> MCP servers, no connectors, no plugins, no outbound API integrations — you don't need this file;
> skip it. Add it the moment the agent gains its **first** tool that can reach outside the repo.
> Scale honestly: one MCP server → one row.

## What this is

A registry of **every tool the agent can invoke that reaches beyond this repo's own files** — MCP
servers, connectors, plugins, browser extensions, API integrations. Each of those is *unsandboxed,
un-audited code you granted access to*: it can read data, write to systems, spend, or send messages
on your behalf. This file is the one place that answers, per tool: **what can it touch, where does
its credential live, and how do I turn it off.** When something has too much access — or needs
killing *now* — this is where you look.

It complements, and does not replace, your access controls. Your settings deny/allow rules and any
allowlist decide *whether* a tool loads; this inventory records *what the ones you loaded can do*,
so a human (or a stressed human mid-incident) can reason about the fleet at a glance.

**Posture: deny by default, allowlist deliberately.** A tool the agent doesn't need should not be
connected. Every row here is an access grant you made on purpose — if you can't say why a row exists,
that's your signal to remove it.

## Inventory

One row per tool. `Credential location` and `How to disable` are the load-bearing columns — they are
what you reach for when a tool misbehaves, so keep them concrete and current.

| Tool / integration | Owner | Scope / permissions | Reads | Writes | Credential location | Last reviewed | How to disable |
|---|---|---|---|---|---|---|---|
| `<mcp-server-name>` (MCP) | you | `<the operations it exposes>` | `<what data it can read>` | `<Y/N — what it can write>` | `<env var / keychain / .claude/settings.local.json / vault>` | `<YYYY-MM-DD>` | remove from your MCP allowlist + restart |
| `gh` CLI (repo + PR access) | you | push, PR create/merge on `<repo>` | repo contents, PR state | Y — commits, PRs, merges | keychain (`gh auth`) / `GH_TOKEN` env | `<YYYY-MM-DD>` | `gh auth logout` / unset the token |
| `<publish-api>` integration | you | post to `<destination>` | — | Y — publishes content | `<VAULT_KEY>` in the deploy env | `<YYYY-MM-DD>` | revoke the API key at the provider + remove the env var |

(Fill / trim for **this** project. A solo project with one read-only MCP server has one row.)

## How to use it

- **Add a row when you connect a tool; delete the row when you disconnect it.** An access grant with
  no row is exactly the blind spot this file exists to prevent.
- **`Credential location` names where the secret physically lives** (an env var, the OS keychain, a
  gitignored local settings file, a vault) — never paste the secret itself here; this file is a map,
  not a store.
- **`How to disable` must be a concrete kill-switch** you could follow under pressure — the exact
  allowlist entry to remove, the OAuth grant to revoke, the config line to delete, the key to rotate.
  If a tool is ever compromised or misused, your incident runbook (`RUNBOOK.md`, if you keep one)
  sends you straight here for this column.
- **Update `Last reviewed`** when you actually re-check a tool's access (after adding scopes, a
  provider change, or a periodic sweep) — the date you looked, not the date you wrote the row.
- **A write-capable tool is a higher-risk row.** Anything with `Writes = Y` can change state you may
  not be able to undo — gate those deliberately (an approval prompt, a dry-run) rather than letting
  them run unattended.

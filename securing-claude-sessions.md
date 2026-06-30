# Securing Claude Code Sessions — A Field Guide

*For: someone who has used Claude Code a little and wants the mental model for keeping it safe.
Read it once to build the model, then use it as a reference. It is the **narrative companion** to this
kit's terse [`CHEATSHEET.md`](CHEATSHEET.md) (the verified mechanics) and the operator runbook in
[`claude-project-kickoff.md` → **Part 0**](claude-project-kickoff.md); the actual config lives in
[`templates/`](templates/).*

> **Read the concrete names as examples.** This guide is written against one real deployment — the RECmint
> wiki project this kit grew out of — so specifics like Intercom, the wiki, `publish_intercom.py`, the
> Tailscale net, a `PreToolUse` guard hook, and "Daniel's review" are **illustrative**. Substitute your
> project's equivalents; the **levels and the reasoning are universal** (same stance as the kickoff guide's
> "every concrete tool is an example"). Where this guide and the cheat-sheet use different words for the same
> thing, the mapping is spelled out right after the levels table.

---

## The one big idea

Claude Code isn't a chatbot. It's an **agent with real hands**: it can edit files, run shell
commands, hit the network, and call tools. That power is the point — and the risk. "Securing
a session" means answering two questions for every action Claude might take:

1. **Is it allowed?** (the *policy*)
2. **Where is that decided, and who can undo it?** (the *enforcement level*)

Most of this guide is about question 2, because it's the one people get wrong. The same rule
("don't let it delete files outside the repo") can be enforced in several different places —
and those places are **not equally strong.** The deeper truth:

> 🔑 **A control is only as strong as the agent's inability to reach it.**
> A rule the agent can edit is a *preference*. A rule enforced by the operating system, or by
> a server the agent can't log into, is a *wall*. Good security pushes the important
> guarantees as far from the agent's reach as the cost allows.

Keep that sentence in mind; everything below is a variation on it. You'll see us make the same
move over and over: **take an important rule and move it somewhere the agent can't touch it.**

---

## First, the baseline dial: permission modes

Before any rules, Claude Code has a **mode** that sets how much it asks you before acting. You
cycle modes with `Shift+Tab`. Understanding these is step one, because "auto mode" means
different things to different people.

| Mode | What runs without asking | Mental model |
|---|---|---|
| **default** | Reads only | "Ask me before doing anything." |
| **acceptEdits** | File edits + a few file commands (`mkdir`, `mv`, `cp`, `sed`) inside the project. Everything else still asks. | "Auto-save edits, but check with me before running things." |
| **auto** | A safety **classifier** looks at each action and auto-approves the ones it judges safe; risky ones are blocked or asked. | "Use your judgment, but a smart filter is watching." |
| **bypassPermissions** ("yolo", `--dangerously-skip-permissions`) | **Everything** — no prompts. | "I trust you completely. Go." |

On our machines, **`auto` is the default mode** (set in each machine's `~/.claude/settings.json`)
and **yolo is switched off entirely** — not by convention, but by a managed lock you'll meet at
Level D. Try to enter yolo on a work machine and it simply won't engage.

> ⚠️ **The mode is a dial, not a wall.** Even the strictest mode is the agent choosing how
> often to ask. The real guarantees come from the layers below, which hold *regardless of
> mode*. Your first proof: two rule types — **deny** and **ask** — fire even in yolo mode. Some
> controls outrank the mode entirely.

---

## The five levels (the heart of this guide)

Here are the places a control can live, ordered from **closest to the agent** (most flexible,
weakest as a hard guarantee) to **furthest from the agent** (least flexible, strongest). The
last column — *can the agent or user undo it?* — is the whole story.

| Level | Lives in | Enforced by | Can the agent/user undo it? |
|---|---|---|---|
| **A — The conversation** | the mode + the `auto` classifier | the model itself | Yes — it's the model's own behavior |
| **B — Project config** | `.claude/settings.json` (allow/ask rules + the hook) | Claude Code | Mostly no, but the file sits *in the repo*, so it's editable in principle |
| **C — The OS sandbox** | settings, enforced by the kernel | macOS Seatbelt | Per-command escape exists *unless* locked at Level D |
| **D — Managed settings** | a root-owned file only an admin can write | Claude Code + OS | **No** — user and agent are both locked out |
| **E — Server-side** | GitHub (branch rules + CODEOWNERS) | GitHub's servers | **No** — it's not even on this computer |

A key thing to notice up front: **the same kind of rule can live at different levels, and that
choice is the security decision.** We put our *convenient* rules (allow/ask) in the repo so they
ship to everyone via git — and our *non-negotiable* rules (deny, sandbox locks) in the managed
file so nobody, agent included, can weaken them. Same syntax, very different strength.

> **How these five levels map to the rest of the kit.** The [`CHEATSHEET.md`](CHEATSHEET.md) lists the same
> idea as seven layers — it splits **B** into committed-project / local / user settings, and gives the **OS
> sandbox** its own row. In the kit's vocabulary: **A** = the mode + classifier; **B** = the **per-repo floor**
> (committed `.claude/settings.json`); **C + D together = the hard floor** (the OS sandbox, turned on and
> *locked* by managed settings); **E** = server-side. One subtlety this table flattens: **C and D are partners,
> not a strict ranking** — managed (D) is what *enables* the sandbox and *removes its escape hatch*, so the
> cheat-sheet can list the kernel-enforced sandbox "above" managed while this table lists it just below. Both
> are true; read them together.

Let's walk each level: what it is, what it prevents or enables, and the trade-offs.

---

### Level A — In the conversation: modes & the `auto` classifier

**What it is.** The permission mode plus, in `auto` mode, a classifier that reviews each
proposed action and auto-approves the safe ones.

**Prevents / enables.** *Enables* fast, low-friction work — the classifier handles the
"obviously fine" 90% so you're not clicking "approve" all day. *Prevents* the obviously-bad
(it blocks things like `rm -rf /` or force-pushing to main).

**Upsides.** Smart, low-friction, no config to maintain.
**Downsides.** It's a **judgment call, not a guarantee.** A classifier can be wrong, and the
mode is something the agent itself operates. Never rely on Level A as your *only* protection
for something that really matters.

> **Teaching point:** Level A is convenience with a safety-minded default. Treat it as the
> helpful first filter, then put hard limits underneath it.

---

### Level B — In the project config: allow/ask rules & the hook

This is the layer that **travels with the repo** — it's in our committed `.claude/settings.json`,
so every teammate gets it on `git pull`. It has two tools.

**B1. Permission rules — `allow` / `ask` / `deny`.**
You write patterns that match tool calls. They're evaluated in a fixed order, **first match
wins**: **deny** (block) → **ask** (force a prompt) → **allow** (auto-approve). Deny and ask
hold *even in yolo mode*.

In our repo's `.claude/settings.json` we use:
- **`allow`** for the safe, frequent things, so `auto` mode stays smooth: `Read`/`Grep`/`Glob`,
  local git (`git add`, `git commit`, `git status`, `git diff`, `git log`), the wiki skill scripts (lint,
  manifest_diff, scaffold…), and the read-only `recmint-wiki` MCP tools.
- **`ask`** for the actions that reach outside or touch customers: `git push`,
  `gh pr create/merge`, `gh api`, **`publish_intercom.py`**, and the Intercom MCP tools. *(Local, reversible
  steps like `git add`/`git commit` are **not** gated — only the ones that actually leave the machine or reach
  customers. This matches the kit's per-repo template, which puts `git add`/`git commit` in `allow`.)*

Notice what's **not** here: the hard `deny` list. We moved that **up to the managed file
(Level D)** on purpose — a deny rule is only a guarantee if the agent can't edit the file it
lives in, and the repo is a file the agent edits. That single decision is the core idea of this
guide in action.

**B2. The hook (`PreToolUse`).**
A hook is a script Claude Code runs **before** a tool call. Ours is
`hooks/pretool_guard.py` (wired in via `.claude/settings.json`). It
inspects the exact tool call and can **block it** (`exit 2`). It's a deterministic, **fail-closed**
backstop — if it can't even parse its input, it blocks. Three things it does that the other
levels can't:
- Blocks a **native `Read`/`Edit`/`Write` of a secret path** (`.env`, `~/.ssh`, `*.pem`, …).
  This matters because the sandbox (Level C) only governs *shell* commands — it doesn't see the
  built-in file tools, so without the hook a plain `Read` of `.env` would slip through. *(In this kit's
  templates the same native-tool protection ships as plain `permissions.deny Read(...)`/`Write`/`Edit` rules —
  no script to maintain (see [`templates/project.settings.json`](templates/project.settings.json) plus the
  managed floor). A `PreToolUse` hook, as in this deployment, is an optional **more-flexible** backstop, but it
  is itself a maintained script, and an in-repo hook is editable unless pinned with `allowManagedHooksOnly`.
  Deny rules are the simpler default; the hook is the power option.)*
- Blocks destructive shell patterns (`rm -rf ~`, `sudo`, `chmod -R`, `curl … | sh`, fork bombs).
- Blocks commands that **print stored credentials** (`gh auth token`, `git credential`,
  `security find-generic-password`).

**Upsides of Level B.** Powerful, precise, and it **ships through git** — edit once, everyone
gets it. Deny/ask outrank the mode; the hook is as exact as you can program.
**Downsides.** The config lives in the repo, so by itself it's only as strong as "nobody/no
agent rewrites it." We handle that two ways: the *most critical* deny rules (secret reads,
destructive shell) are **also** written into the managed file at Level D, so they hold even if
the repo copy were tampered with — and edits to `hooks/` and `.claude/` require review via
`CODEOWNERS` (Level E). (Claude Code *can* go further — pinning the hook to a root-owned copy via
`allowManagedHooksOnly` so the agent literally cannot edit the guard it's subject to — but we've
chosen not to, to keep the managed config lean. So know this: our active guard is the editable
repo copy, backstopped by the duplicated managed deny rules, not an unbreakable managed hook.)

> **Teaching point:** Level B is strong *and* convenient — but a rule here is a wall only if the
> agent can't rewrite it. So we keep the convenient rules here and **mirror the most critical
> ones into the managed file.** Redundancy on a *different mechanism* is the point.

---

### Level C — The OS sandbox

**What it is.** A cage, built on macOS's own Seatbelt technology, wrapped around **the shell
commands Claude runs.** No install, no background service, no permanent change to the
computer — it's applied per-command and vanishes when the session ends.

**Prevents.** By default, sandboxed shell commands can only **write inside the project folder**,
and the **network is blocked except an allow-list** of hosts. So a runaway `rm -rf` or a "phone
home to evil.com" is stopped by the *operating system*, not by Claude's good behavior. *(One honest
caveat on the network half: on macOS the allow-list is enforced by a proxy that decides from the requested
**hostname** without inspecting TLS — a real stop for accidental or naive egress, but **not a complete
isolation boundary** (a determined exfil can use domain-fronting or a raw IP). The filesystem cage is the
harder half; for secrets the real control is **deny the read** + **don't keep the secret on the machine**,
not the egress list alone.)* We also
**deny the sandbox access to credential directories** (`~/.ssh`, `~/.aws`, the `gh`/`gcloud`
config dirs, `~/.npmrc`…), so a sandboxed command can't read them even though reads are
otherwise broad.

**Enables.** Because the cage already contains commands, Claude can stop *asking* about many of
them — so the sandbox means **fewer prompts AND a harder floor at once.** And our config opens
exactly the holes real work needs:
- **`excludedCommands`** — a few tools run *outside* the cage because they need their own
  network/credential access: `gh`, `gcloud`, `terraform`, `docker`, `brew`. These are
  *admin-chosen* exceptions, not the agent's call.
- **`filesystem.allowWrite`** — specific outside-the-repo paths Claude may write, namely the
  package-manager caches (`~/.cache/uv`, `~/.cache/pip`, `~/.npm`).
- **`network.allowedDomains`** — the operational hosts (GitHub, PyPI, npm, our Tailscale net…).

**Important boundaries (common misconceptions):**
- It only governs **shell commands.** Claude's file edits are limited to the project by the
  permission system; **web research (WebSearch/WebFetch) is *not* sandboxed**, so a tight
  network allow-list doesn't hurt research at all.
- An un-listed network host doesn't hard-fail in normal use — it **prompts once**
  (because we set `allowManagedDomainsOnly: false`). The allow-list is a *pre-approval to skip
  nagging*, not the only sites that exist.
- The one thing it can't cage: **computer-control tools** (screen/browser automation) run on the
  *real* desktop. We don't enable those on teammate machines.

**Upsides.** OS-enforced — far stronger than anything Claude can talk its way around. Scoped to
the project; doesn't touch their other work.
**Downsides.** A sandbox normally has a **per-command escape hatch** (Claude can retry a command
outside the cage). Convenient, but it's a door in the wall — so we *removed* it at Level D
(`allowUnsandboxedCommands: false`), and `excludedCommands` is the controlled replacement.

---

### Level D — Managed settings (the admin lock)

**What it is.** A settings file at a **system path only an administrator can write**
(`/Library/Application Support/ClaudeCode/managed-settings.json`, owned by `root`). Its values
**cannot be overridden** by the user or the agent — they always win. This file is *installed on
our machines today.*

**Prevents / enables.** This is where the guarantees that must be *unbreakable on the machine*
live. Ours includes:
- `disableBypassPermissionsMode: "disable"` → **yolo mode can't be turned on at all.**
- `sandbox.enabled: true` + `failIfUnavailable: true` → **the sandbox is always on, and Claude
  refuses to run if it can't start it** (no silent "ran without the cage").
- `allowUnsandboxedCommands: false` → **removes the escape hatch** from Level C.
- The hard **`deny` list** — reads of secret files (`.env`, `*.pem`, `id_rsa`, `~/.ssh/**`…),
  writes to shell-startup files and `~/Library/LaunchAgents`, `sudo`, `rm -rf /` or `~`,
  `chmod -R`, pipe-to-shell, and credential-printing commands.
- `excludedCommands`, `filesystem.allowWrite`, `credentials` (from Level C) — the **admin-owned
  exception valves**. Closed by default; every exception is explicit and *ours*.
- `env: CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` → strips provider credentials out of any subprocess
  Claude spawns.

**Upsides.** The strongest on-machine guarantee. Neither a curious user nor a misbehaving agent
can weaken it.
**Downsides.** It's **per-machine** — it doesn't travel through git, so an admin places it on
each computer (see the setup runbook). And strictness has a cost: with the escape hatch gone, a
command that legitimately needs to act outside the cage **fails outright** until an admin adds an
exception. (That's why we moved git worktrees *inside* the repo at `.claude/worktrees/` — so
normal work never needs to step outside.)

> **Teaching point:** Levels B and C are "strong defaults everyone gets." Level D is "the locks
> only the admin holds the key to." A guarantee you can't afford to have weakened belongs here —
> which is why our deny list and sandbox locks live here, not in the repo.

---

### Level E — Server-side (off the machine entirely)

**What it is.** Controls that live on **GitHub's servers**, not on any laptop. For us:
- A **rule on `main`** that blocks force-pushes and deletions and **requires the lint check** to
  pass. (Our `wiki-lint` also runs report-only on direct pushes, for visibility.)
- A **`CODEOWNERS`** file that **requires Daniel's review** on pull requests touching sensitive
  paths: `CLAUDE.md`, `.claude/`, `.github/`, `hooks/`, `raw/blessed/`, the MCP server scripts,
  and the publish ledgers.

**Prevents.** Protects the *shared* artifact no matter what happens on any individual machine.
Even a fully compromised laptop can't rewrite history on `main` or merge past a failing check.

**Enables.** Lets us keep the trusting workflow (seniors push directly to `main`) while still
guaranteeing the repo's integrity.

**Upsides.** The agent literally cannot reach it — there's no local file to edit. The ultimate
"can't undo it" level.
**Downsides.** It only protects what's *on the server*, not the local machine. And it has a
sharp edge worth understanding: **`CODEOWNERS` gates the *pull-request* path only — it does not
stop a direct push to `main`.** So for the sensitive *repo* paths (like `CLAUDE.md` or
`raw/blessed/`), what actually guards them is a *combination*: the `auto` classifier's judgment,
Claude Code's built-in prompting on protected paths like `.claude/`, `CODEOWNERS` review on the
PR path, and the plain fact that any direct change shows up in git history. We deliberately did
**not** add a managed hard-`deny` on those repo paths (it would block legitimate senior edits
too). Knowing that no single control is the "wall" here — that it's layered and partly
review-and-visibility rather than prevention — is exactly the kind of nuance this guide is trying
to teach.

---

## Beyond walls: detection (the audit trail)

Every level above is **preventive** — it stops a bad action. Mature security also needs
**detective** controls — a record, for when prevention is bypassed or you need to investigate
later. The reference implementation is a `ConfigChange` hook (`hooks/audit-config-change.sh` in the example deployment):
a `ConfigChange` hook that would **log every time Claude reloads its settings mid-session**, so a
loosened setting leaves a timestamped trail. *We do not currently run it* — activating it the
tamper-proof way means turning on managed hooks, and we've deliberately kept our managed config
lean (see the next note). It's here as a ready-made option if we later decide the audit trail is
worth that complexity. The lesson stands even though we haven't switched it on: know the
difference between "can I stop it?" and "would I know if it happened?"

> **Teaching point:** "Can I stop it?" and "Would I know if it happened?" are different questions.
> A good posture answers both. Walls fail silently; logs make failures visible.

---

## Secrets — a worked example of defense in depth

Secrets (like our Intercom API token) are the best illustration of layering, because we protect
*one* thing with *many* independent controls. Watch how many levels guard a single token:

1. **Least privilege (the credential itself).** The Intercom write-token can write help articles
   and *nothing else* — no access to customer conversations. If it leaks, the damage is small.
2. **Least exposure.** The write-token lives on *one* publisher machine; teammate laptops have
   none, so there's nothing to steal there.
3. **Can't read it (Level B + D).** A native `Read` of `.env` is blocked by the hook; a managed
   `deny` rule blocks it too; the sandbox denies access to credential directories.
4. **Can't smuggle it out (Level C).** Even if a command got the token, the network allow-list
   means it can only reach approved hosts — not an arbitrary server. And
   `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` strips provider creds out of subprocesses.
5. **Can't commit it.** `.gitignore` keeps `.env` out of git — but remember that stops
   *committing*, not *reading*; reading is handled by #3.
6. **Human-in-the-loop on use.** Publishing (which uses the token and reaches customers) is an
   `ask` action — a person approves each time.
7. **Rotate it.** Replace the token on a schedule (~quarterly) and immediately if a machine is
   lost or the token might have been exposed.

That's seven independent controls on one secret, spread across four levels. Pull any one and the
others still hold. *That's* defense in depth — not a slogan, a stack.

---

## How it all fits together

No single level is "the answer." They **stack**, each covering the others' gaps. A worked
example — *"Claude tries to delete a file in your home folder"*:

- **auto mode (A)** probably won't propose it. But if it did…
- the **hook + a managed deny rule (B/D)** match the pattern and block it. But if the pattern
  didn't match…
- the **sandbox (C)** blocks the write because it's outside the project — at the OS level. And
- because **yolo is disabled and the escape hatch is off (D)**, there's no mode or trick that
  gets around the sandbox. Meanwhile,
- even in a total worst case, **GitHub (E)** guarantees `main` itself is safe, and the **audit
  log** would show any settings tampering.

Several independent chances to stop one bad action, plus a record if something slips. That's the
goal: **assume any one layer can fail, and make sure another catches it.**

---

## The trade-off you'll always be balancing

Security and friction pull against each other, and the wiki's *own tools* need real power
(Python, git, network to GitHub and Intercom). So every tightening needs a **carve-out** — and
**those carve-outs are where residual risk lives** (look at our `excludedCommands` and
`allowWrite` lists: each is a deliberate, named hole). Two failure modes to watch for:

- **Too loose:** the agent can do real damage.
- **Too tight:** either the legitimate tools break, *or* teammates get so many prompts they'd
  reach for yolo to escape them — which is why we removed yolo as an option rather than relying on
  people not to use it.

Good configuration is the smallest set of named carve-outs that lets real work flow while keeping
the walls intact. When in doubt, **start tighter and open holes as real needs appear** (an
un-listed host just prompts; you add it when it comes up) — safer than starting open and trying to
close holes later.

---

## Try it yourself (15 minutes)

The fastest way to internalize this is to *watch the levels act*:

1. **Modes:** press `Shift+Tab` a few times and watch the mode indicator change. Notice how much
   it asks in each — and that **yolo won't engage** on your work machine. That refusal *is* the
   Level-D managed lock doing its job.
2. **An ask rule:** ask Claude to `git push` something trivial and watch the prompt appear
   (that's our Level-B `ask` rule). Approve or decline.
3. **A deny rule:** ask Claude to read `.env`, or to run `sudo something`. Watch it get blocked —
   and note you *can't* escape it by changing modes, because the deny lives in the managed file.
4. **The sandbox:** ask Claude to `touch ~/test.txt` (outside the project) and watch the OS refuse
   the write. Then ask it to read a web page and notice research still works fine.
5. **Inspect the real thing:** open the files in the appendix below and read the actual rules. The
   config is short; seeing it makes the table at the top concrete.

Do those five and this guide stops being abstract.

---

## Appendix — where each control actually lives (go read it)

| Control | Level | Where it lives (in this kit) |
|---|---|---|
| `auto` default mode, local dev allows | A | `~/.claude/settings.json` (per machine — never committed) |
| allow/ask rules + the repo allow-list | B | committed `.claude/settings.json` — template: [`templates/project.settings.json`](templates/project.settings.json) |
| A deterministic native-tool guard *(example deployment)* | B | a `PreToolUse` hook; **the kit ships this as `permissions.deny Read(...)` rules instead** (see the Level B note) |
| An audit / tamper-trail hook *(example deployment; off by default — see Detection)* | detection | a `ConfigChange` hook |
| Sandbox + locks, the deny list, exception valves, env scrub | C + D | `/Library/Application Support/ClaudeCode/managed-settings.json` (root-owned) — template: [`templates/managed-settings.template.json`](templates/managed-settings.template.json) |
| Per-machine sandbox-enable + `autoMode` | C / A | [`templates/project.settings.local.json.example`](templates/project.settings.local.json.example) |
| Review on sensitive paths *(example deployment)* | E | `.github/CODEOWNERS` |
| `main` branch rules + required check | E | GitHub (repo settings) |
| Verified mechanics + the operator runbook + the three-layer model | — | [`CHEATSHEET.md`](CHEATSHEET.md), [`claude-project-kickoff.md` → Part 0](claude-project-kickoff.md), [`templates/README.md`](templates/README.md) |

---

## Quick glossary

- **Permission mode** — the dial (default / acceptEdits / auto / yolo) for how much Claude asks.
- **`auto` mode** — a mode where a classifier auto-approves actions it judges safe.
- **yolo / bypassPermissions** — the mode that approves everything; we keep it disabled.
- **allow / ask / deny** — permission rules; deny and ask hold even in yolo.
- **Hook (PreToolUse)** — a script that can block a tool call before it runs (ours fails closed).
- **Sandbox** — an OS cage on shell commands (filesystem + network).
- **`excludedCommands` / `allowWrite`** — admin-chosen holes in the sandbox.
- **Managed settings** — a root-owned file whose values can't be overridden by user or agent.
- **CODEOWNERS** — a GitHub file that requires named reviewers on PRs to listed paths.
- **Detective vs preventive control** — a record of what happened vs. a wall that stops it.
- **Least privilege** — give a credential the minimum access it needs.
- **Defense in depth** — layer independent controls so one failure isn't fatal.

---

*Questions, or something here doesn't match what you see in the app or the config files? Ask —
the docs evolve faster than any single person's memory, and "this looks off" is exactly the
feedback that keeps a guide like this honest.*

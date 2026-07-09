#!/usr/bin/env python3
"""
PreToolUse credential/secret guard — BASE TEMPLATE (stack-agnostic). Part of the
Harness Kit (see claude-project-kickoff.md, securing-claude-sessions.md, and
wiki/decisions/2026-07-credential-incident.md).

WHAT THIS IS
  A deterministic, fail-closed PreToolUse hook that BLOCKS a small set of clearly
  dangerous tool calls *before* they run. It is a backstop *behind* the permission
  rules + sandbox, never the primary control. It deliberately overlaps the managed
  `permissions.deny` rules — redundancy on a *different mechanism* is the point.

WHY SHIP A HOOK AT ALL (the kit's default is deny rules; this is the power option)
  A `permissions.deny` rule matches per-subcommand, anchored at the START of the
  command string. Claude Code splits compound commands on shell operators, so
  `A && gh auth token` is caught — but an interpreter/substitution wrapper EVADES a
  deny rule entirely: `bash -lc 'gh auth token'`, `X=$(gh auth token)`,
  `python3 -c '...'`. This hook runs `re.search` over the FULL command string, so it
  catches those wrapped forms. Adopt it for any project that HANDLES CREDENTIALS
  (publishes, calls an authed API, holds a token); a code-only project can rely on
  deny rules alone. On 2026-07-08 a live GitHub credential was printed into an agent
  transcript through exactly the exact-string / wrapper gaps this guard closes.

HONEST LIMIT (a regex is a sieve, never a boundary)
  Forms that SPLIT the command text still evade — `subprocess.run(["gh","auth","token"])`,
  or a command assembled from shell variables. The real boundary is capability-removal
  (fan-out workers don't push/fetch — kickoff Part 3 #15) + the OS sandbox. This guard
  raises the cost of the easy leaks; it does not make leaking impossible. The self-test
  (pretool_guard.selftest.sh) pins BOTH the forms it catches and the ones it does not.

HOW TO WIRE IT (committed, editable — the lean default)
  1. Copy this file to <repo>/hooks/pretool_guard.py and the self-test beside it.
  2. In .claude/settings.json, register a PreToolUse hook (see templates/README.md
     "Shipping the PreToolUse guard hook"):
       "hooks": { "PreToolUse": [ { "matcher": "Bash|Read|Edit|Write|MultiEdit",
         "hooks": [ { "type": "command",
           "command": "python3 \"$CLAUDE_PROJECT_DIR/hooks/pretool_guard.py\"" } ] } ] }
  3. Add "Edit(hooks/**)" / "Write(hooks/**)" to permissions.deny so the agent can't
     edit the guard it is subject to (already in templates/project.settings.json).
  4. Run `bash hooks/pretool_guard.selftest.sh` and wire it into CI.
  For a HARD guarantee (agent literally cannot edit the guard), copy this to a
  root-owned path and point a MANAGED hook at it with `allowManagedHooksOnly:true` —
  heavier; the kit's lean default is the committed copy + the hooks/** deny.

CONTRACT (PreToolUse hook protocol — code.claude.com/docs/en/hooks)
  - stdin: JSON with tool_name, tool_input{...}, cwd, ...
  - exit 2  -> BLOCK the tool call (stderr is shown to the agent)
  - exit 0  -> NO decision; defer to the normal permission flow. NEVER approve here —
               staying silent is a *defer*, not an *allow*.
  - Fail-closed: empty / unparseable input -> BLOCK. NOTE the protocol itself fails
    OPEN on an infra error (a crash, or `python3` not found exits nonzero-but-not-2 and
    the call PROCEEDS) — which is why the self-test must confirm it actually blocks, in
    the main loop AND from a subagent.
"""
import sys
import json
import re

BLOCK, DEFER = 2, 0


def block(reason):
    sys.stderr.write("BLOCKED by pretool_guard: " + reason + "\n")
    sys.exit(BLOCK)


# Credential / secret PATHS — matched against a native file tool's file_path and against
# file arguments inside a Bash command. Tune to your stack; ordinary source never matches.
SECRET_PATH = re.compile(
    r"""(?ix)
      (^|/)\.env(\.[^/]*)?$           # .env, .env.local, ...
    | \.(token|pem|key|p12|pfx)$      # key material
    | (^|/)(id_rsa|id_ed25519|id_ecdsa|id_dsa)\b
    | /\.ssh/                         # ssh dir
    | /\.aws/                         # aws creds
    | /\.config/gh/                   # gh token store
    | /\.config/gcloud/
    | (^|/)\.npmrc$ | (^|/)\.netrc$ | (^|/)\.pypirc$
    """
)

# Same intent, matched against a Bash COMMAND string, where a secret path may be preceded
# by whitespace / quotes / `=` rather than `/` (e.g. `cat .env`).
SECRET_IN_CMD = [
    r"(?i)(^|[\s'\"=/])\.env(\.[\w.-]+)?($|[\s'\";|&>])",   # .env, .env.local
    r"(?i)\bid_(rsa|ed25519|ecdsa|dsa)\b",
    r"(?i)[\w./~-]+\.(token|pem|p12|pfx)($|[\s'\";|&>])",
    r"(?i)~?/\.ssh(/|\b)",
    r"(?i)~?/\.aws(/|\b)",
    r"(?i)/\.config/(gh|gcloud)(/|\b)",
    r"(?i)(^|[\s'\"=/])\.(npmrc|netrc|pypirc)($|[\s'\";|&>])",
]


def cmd_reads_secret(cmd):
    return any(re.search(p, cmd) for p in SECRET_IN_CMD)


def main():
    raw = sys.stdin.read()
    if not raw.strip():
        block("empty hook input (failing closed)")
    try:
        data = json.loads(raw)
    except Exception as e:
        block("unparseable hook input (failing closed): %s" % e)

    tool = data.get("tool_name", "") or ""
    ti = data.get("tool_input", {}) or {}

    # 1) Native file tools: block reads/writes of credential paths. The Bash sandbox does
    #    NOT cover these tools, so this is the only deterministic gate on a native Read of
    #    ~/.ssh, ~/.aws, or the repo .env. (The kit also ships these as permissions.deny
    #    Read(...) rules; this is the redundant-on-a-different-mechanism backstop.)
    if tool in ("Read", "Edit", "Write", "MultiEdit", "NotebookEdit"):
        fp = ti.get("file_path") or ti.get("notebook_path") or ti.get("path") or ""
        if fp and SECRET_PATH.search(fp):
            block("file tool on a credential/secret path is not allowed: %s" % fp)

    # 2) Bash
    if tool == "Bash":
        cmd = ti.get("command", "") or ""

        # destructive recursive rm targeting / ~ or $HOME
        if re.search(r"(?i)\brm\b\s+(-[a-z]*\s+)*-?[a-z]*r[a-z]*", cmd) and \
           re.search(r"(?i)(\s|^)(/|~|\$HOME|\$\{HOME\}|/\*|~/\*)(\s|/|$)", cmd):
            block("destructive recursive rm targeting / ~ or $HOME")

        SIMPLE = [
            (r"(?i)\bsudo\b", "sudo is not allowed"),
            (r"(?i)\bchmod\s+-R\b", "recursive chmod is not allowed"),
            (r"(?i)\b(curl|wget)\b[^|;&]*[|]\s*(sh|bash|zsh|dash|python3?|node|ruby|perl)\b",
             "pipe-to-interpreter (e.g. `curl ... | sh`) is not allowed"),
            (r":\s*\(\s*\)\s*\{\s*:\s*\|\s*:?\s*&\s*\}\s*;\s*:", "fork bomb"),
            # Credential-MATERIALIZATION family — commands whose OUTPUT is a live credential.
            # Deny the FAMILY, not one exact string (2026-07-08: a full credential printed via
            # `gh auth git-credential get`, which a lone `gh auth token` alternative missed; the
            # hyphenated `git-credential-*` helpers slipped past `git\s+credential`). This is
            # re.search over the FULL command string, so it ALSO catches wrapped forms a prefix-
            # glob deny rule can't (`cd /tmp && gh auth token`, `bash -lc '...'`, `$(...)`).
            # Mirror any addition into the managed + committed deny rules too.
            (r"(?i)\bgh\s+auth\b"                            # whole gh-auth family (token, git-credential, status, refresh, setup-git)
             r"|\bgh\s+config\s+get\b"                       # `gh config get ... oauth_token` prints the token
             r"|\bgit\s+credential\b|\bgit-credential"       # bare + hyphenated helper binaries
             r"|\bsecurity\s+(find-(generic|internet)-password|dump-keychain)\b"
             r"|\bkit-canary-denied\b",                      # the kit's test-fireable canary
             "printing stored credentials is not allowed"),
            # Environment-variable secret printing. NARROW on purpose to avoid false-positiving an
            # assignment like `env VITE_API_KEY=x npm run build` (a set, not a read): require
            # printenv OF a secret-named var, or `env` PIPED to a searcher for one. No \b around the
            # secret word so it matches inside identifiers like GITHUB_TOKEN (`_` is a word char).
            (r"(?i)\bprintenv\s+\S*(token|secret|key|password|credential)"
             r"|\benv\b\s*\|[^\n]*(token|secret|key|password|credential)",
             "printing environment secrets is not allowed"),
        ]
        for pat, msg in SIMPLE:
            if re.search(pat, cmd):
                block(msg)

        # reading a secret file via a shell reader
        if re.search(r"(?i)\b(cat|less|more|head|tail|strings|xxd|od|base64|sed|awk|grep|rg|nl|tac)\b", cmd) \
           and cmd_reads_secret(cmd):
            block("reading a credential/secret file via Bash is not allowed")

    sys.exit(DEFER)  # everything else: defer to the normal permission flow


if __name__ == "__main__":
    main()

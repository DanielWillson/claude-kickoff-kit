#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Self-test for pretool_guard.py — BASE TEMPLATE. Part of the Harness Kit.
# Copy to <repo>/hooks/pretool_guard.selftest.sh beside the guard, and wire into CI.
#
# WHY THIS EXISTS. A deny/guard pattern rots SILENTLY — a renamed helper, a missed
# hyphen, a wrapper form — and reads as protection while protecting nothing. Per the
# harness rule "a fixed bug leaves a mechanical check that fails if it recurs," this
# pins the guard's behavior so a future edit can't quietly re-open a gap. It feeds
# crafted hook JSON to the guard on stdin and asserts the exit code: 2 = BLOCK, 0 = DEFER.
# (It checks the guard FIRES on given inputs; it does NOT prove the hook is REGISTERED,
# nor that it fires inside an Agent subagent — those are live-session checks, see the
# kit's canary live-fire protocol in templates/README.md.)
#
# THREE SECTIONS:
#   MUST-BLOCK  — incident commands + WRAPPED variants a prefix-glob deny rule misses.
#   MUST-DEFER  — benign look-alikes (guards against the guard over-blocking real work).
#   KNOWN-EVASIONS — forms a regex CANNOT catch (documented, not asserted). If a future
#                 hardening starts catching one, promote it to MUST-BLOCK. Their existence
#                 is the reminder that the boundary is capability-removal + sandbox.
#
# Run:  bash hooks/pretool_guard.selftest.sh     (exit 0 = all assertions held)
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="${1:-$DIR/pretool_guard.py}"   # arg overrides path (lets the kit test its own template copy)
PASS=0; FAIL=0

# Feed one Bash command to the guard as hook JSON; return its exit code.
# Uses `python3 -c` with the command passed as argv (NOT a bash heredoc): a sandboxed
# shell denies bash's heredoc temp-file, and argv-passing also avoids shell→JSON escaping.
verdict() {
  python3 -c 'import json,subprocess,sys; p=json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[2]}}); sys.exit(subprocess.run([sys.executable,sys.argv[1]],input=p,capture_output=True,text=True).returncode)' "$GUARD" "$1"
}

expect_block() {
  verdict "$1" >/dev/null 2>&1
  if [ "$?" -eq 2 ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); printf '  ✗ EXPECTED BLOCK, got DEFER:  %s\n' "$1"; fi
}
expect_defer() {
  verdict "$1" >/dev/null 2>&1
  if [ "$?" -eq 0 ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); printf '  ✗ EXPECTED DEFER, got BLOCK:  %s\n' "$1"; fi
}

echo "── MUST-BLOCK: incident commands ─────────────────────────"
expect_block 'gh auth token | head -c 20'
expect_block 'gh auth git-credential get'
expect_block 'gh auth status --show-token'
expect_block 'gh config get -h github.com oauth_token'
expect_block 'git credential fill'
expect_block 'git-credential-osxkeychain get'
expect_block 'security find-generic-password -s foo'
expect_block 'security find-internet-password -s github.com'
expect_block 'security dump-keychain'
expect_block 'env | grep GITHUB_TOKEN'
expect_block 'printenv GITHUB_TOKEN'
expect_block 'cat ~/.config/gh/hosts.yml'
expect_block 'kit-canary-denied --probe'

echo "── MUST-BLOCK: WRAPPED variants (prefix-glob deny rules miss these) ─────"
expect_block 'cd /tmp && gh auth token'
expect_block 'bash -lc "gh auth token"'
expect_block 'echo $(gh auth token)'
expect_block 'X=$(gh auth git-credential get); echo done'
expect_block 'true && git-credential-osxkeychain get'

echo "── MUST-DEFER: benign look-alikes (guard must NOT over-block) ───────────"
expect_defer 'git commit -m "ok"'
expect_defer 'gh pr view 64'
expect_defer 'git config user.name'
expect_defer 'printenv PATH'
expect_defer 'env VITE_API_KEY=abc npm run build'
expect_defer 'git status'

echo "── KNOWN-EVASIONS (documented, NOT asserted — a regex cannot catch these) ──"
for e in \
  'python3 -c '\''import subprocess; subprocess.run(["gh","auth","token"])'\''' \
  'C=gh; A=auth; T=token; $C $A $T'; do
  verdict "$e" >/dev/null 2>&1
  rc=$?
  [ "$rc" -eq 2 ] && note="now CAUGHT — promote to MUST-BLOCK & update docs" || note="evades (as documented) — boundary is capability-removal + sandbox"
  printf '  · %s  →  %s\n' "$e" "$note"
done

echo
printf "  PASS: %s   FAIL: %s\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && { echo "  RESULT: guard behaves as pinned ✓"; exit 0; } \
                  || { echo "  RESULT: guard REGRESSED — a credential-print gap re-opened, or a benign command is now blocked"; exit 1; }

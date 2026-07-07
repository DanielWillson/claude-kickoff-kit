#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Regression self-test for the behavioral-eval runner (../claude-eval-base.sh).
# Part of the Harness Kit. Guards the two §9.1-item-A defects that shipped in the
# runner's *failure* paths — the paths a happy-path smoke never exercises, which is
# exactly where both bugs hid (the ROADMAP's telling omission: A never carried a
# "proven on fixtures" annotation). Run it whenever you touch the runner, and at a
# model/judge change. NO LIVE MODEL: everything is driven through the runner's own
# EVAL_CMD / EVAL_JUDGE_CMD stub seam, so it is deterministic and free.
#
#   BUG 1 — a golden that FAILS must print `FAIL` and let the suite CONTINUE, not abort
#           the whole run with `unbound variable` (unbraced $var before the `»` guillemet
#           under `set -u`). Asserted under LANG=en_US.UTF-8, where the crash reproduces.
#   BUG 2 — the rubric verdict must come from the judge's trailing `VERDICT:` line, so a
#           judge that reasons before concluding cannot flip the result either direction.
#
# Run:   bash evals-template/eval-runner.selftest.sh
# Exit:  0 = the runner's fail-paths behave; 1 = a guarded bug regressed.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$SCRIPT_DIR/../claude-eval-base.sh"
TMP="${TMPDIR:-/tmp}"
WORK="$TMP/eval-selftest.$$"
trap 'rm -rf "$WORK"' EXIT

[ -f "$RUNNER" ] || { echo "  ✗ runner not found at $RUNNER"; exit 1; }
mkdir -p "$WORK/golden" "$WORK/rubric"

pass_ct=0; fail_ct=0
ok()  { printf '  ✓ %s\n' "$1"; pass_ct=$((pass_ct+1)); }
bad() { printf '  ✗ %s\n' "$1"; fail_ct=$((fail_ct+1)); }
has()   { if grep -qF -- "$2" "$1"; then ok   "$3"; else bad "$3  (missing: $2)";    fi; }
lacks() { if grep -qF -- "$2" "$1"; then bad  "$3  (unexpected: $2)"; else ok "$3";  fi; }

# ── fixtures ────────────────────────────────────────────────────────────────
# Two goldens: #1 sorts first and FAILS (expects a value the stub won't return); #2 sorts
# last and PASSES. A single stub builder returns `MATCH`, so #1 fails and #2 passes.
cat > "$WORK/golden/aa-golden-fails.eval.md" <<'EOF'
---
grade: golden
---
## input
Reply with ONLY the path.
## expected
config/timeout.conf
EOF
cat > "$WORK/golden/zz-golden-passes.eval.md" <<'EOF'
---
grade: golden
---
## input
Reply with ONLY the token.
## expected
MATCH
EOF
cat > "$WORK/rubric/mm-rubric.eval.md" <<'EOF'
---
grade: rubric
---
## input
Answer the question.
## rubric
- Satisfies the checklist.
EOF

# ── stub judges (new VERDICT: protocol) — reasoning carries the OPPOSITE keyword, the real
#    verdict is the LAST `VERDICT:` line. If the extraction ever reverts to "first PASS|FAIL
#    anywhere", these flip and the asserts below fail — that is the regression trap.
cat > "$WORK/judge-concludes-fail.sh" <<'EOF'
#!/usr/bin/env bash
cat >/dev/null
printf 'This answer is tempting to PASS at first glance, but it misses checklist item 2.\nVERDICT: FAIL\n'
EOF
cat > "$WORK/judge-concludes-pass.sh" <<'EOF'
#!/usr/bin/env bash
cat >/dev/null
printf 'One might FAIL this for tone, but it satisfies every checklist item.\nVERDICT: PASS\n'
EOF
# A judge that ignores the protocol (no VERDICT: line) must fail SAFE, not silently pass.
cat > "$WORK/judge-nonconforming.sh" <<'EOF'
#!/usr/bin/env bash
cat >/dev/null
printf 'It satisfies every item.\nOverall verdict: PASS\n'
EOF
chmod +x "$WORK"/judge-*.sh 2>/dev/null || true

echo
echo "── EVAL-RUNNER REGRESSION SELF-TEST ─────────────────────"
echo "   runner: $RUNNER"

# ── 0. syntax ────────────────────────────────────────────────────────────────
if bash -n "$RUNNER" 2>/dev/null; then ok "runner parses (bash -n)"; else bad "runner has a syntax error (bash -n)"; fi

# ── 1. BUG 1: a failing golden reports FAIL and the suite CONTINUES (no abort) ─
out="$WORK/out.golden"
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 EVAL_DIR="$WORK/golden" EVAL_CMD='printf MATCH' \
    bash "$RUNNER" >"$out" 2>&1 || true
lacks "$out" "unbound variable" "Bug 1: no 'unbound variable' crash on a failing golden"
has   "$out" "✗ FAIL  aa-golden-fails"  "Bug 1: the failing golden prints FAIL (not a crash)"
has   "$out" "«config/timeout.conf»"    "Bug 1: guillemets preserved in the diff message"
has   "$out" "✓ PASS  zz-golden-passes" "Bug 1: the suite CONTINUES to fixture #2 after the failure"
has   "$out" "RESULT:"                   "Bug 1: the run completes to its footer (did not abort)"

# ── 2. BUG 2: verdict comes from the trailing VERDICT: line, both directions ───
outA="$WORK/out.rubricA"
EVAL_DIR="$WORK/rubric" EVAL_CMD='printf answer' EVAL_JUDGE_CMD="bash $WORK/judge-concludes-fail.sh" \
    bash "$RUNNER" >"$outA" 2>&1 || true
has "$outA" "✗ FAIL  mm-rubric" "Bug 2A: judge reasons 'PASS' but concludes VERDICT: FAIL → FAIL"

outB="$WORK/out.rubricB"
EVAL_DIR="$WORK/rubric" EVAL_CMD='printf answer' EVAL_JUDGE_CMD="bash $WORK/judge-concludes-pass.sh" \
    bash "$RUNNER" >"$outB" 2>&1 || true
has "$outB" "✓ PASS  mm-rubric" "Bug 2B: judge reasons 'FAIL' but concludes VERDICT: PASS → PASS"

# ── 3. safe default: a judge that ignores the protocol fails SAFE, not silent-pass ─
outC="$WORK/out.rubricC"
EVAL_DIR="$WORK/rubric" EVAL_CMD='printf answer' EVAL_JUDGE_CMD="bash $WORK/judge-nonconforming.sh" \
    bash "$RUNNER" >"$outC" 2>&1 || true
has "$outC" "judge verdict: <none>" "Safe default: no VERDICT: line → conservative FAIL"

echo
printf "  PASS: %-4s  FAIL: %s\n" "$pass_ct" "$fail_ct"
if [ "$fail_ct" -gt 0 ]; then
    echo "  RESULT: FAIL — a guarded eval-runner defect (§9.1 item A) regressed."
    echo
    exit 1
fi
echo "  RESULT: PASS — the runner's fail-paths behave; both §9.1-A bugs stay fixed."
echo
exit 0

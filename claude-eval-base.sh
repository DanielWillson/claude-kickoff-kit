#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Behavioral-eval runner — BASE TEMPLATE (stack-agnostic). Part of the Harness Kit
# (see claude-project-kickoff.md §1.6b). Copy to <repo>/scripts/eval.sh and adapt.
#
# A behavioral eval is a saved test for the AGENT'S JUDGMENT, not the code: a task prompt +
# a way to grade the answer. It is the agent-behavior analogue of a test suite —
# *eval-driven development is to agents what TDD was to code.* Two grade types (each
# evals/*.eval.md carries a `grade:`):
#   • golden — the answer must EQUAL a saved value. Exact, cheap, DETERMINISTIC, and needs
#     NO live model to grade (the model only GENERATES the candidate; the compare is plain
#     string equality). PREFER THIS wherever the right answer is a fixed string.
#   • rubric — a fresh agent (the judge) grades the answer against a short checklist. For
#     FUZZY output only. LLM-as-judge is noisy — a smoke alarm, not a lab scale.
#
# WHEN to run this: at a MAINTENANCE MOMENT — a model upgrade, a big CLAUDE.md edit, a new
# skill — to prove the change HELPED rather than quietly regressed judgment. NOT on every
# edit: it costs tokens and shells out to a live model. The audit (scripts/audit.sh) is the
# after-every-edit verifier; this is the at-a-model-change verifier.
#
# WHAT THIS RUNNER MECHANICALLY CHECKS vs. what a human reads — be honest about the line:
#   • input + expected (golden) and input + rubric (rubric) are ENFORCED — graded every run.
#   • required_sources · forbidden_actions · approval_class are SCHEMA FIELDS every fixture
#     carries (the ROADMAP item-A schema: input · expected output · required sources/
#     citations · forbidden actions · approval class) but this base template does NOT
#     mechanically enforce them. They are the provenance/safety contract a maturing project
#     grows into — read by a human until you wire a check that needs one. This is where the
#     provenance rule lives: "a naked factual claim is a defect — it must cite its source."
#     Do not mistake their presence for enforcement.
#
# THE MODEL COMMAND IS OVERRIDABLE — this is the one line to adapt, and the seam a self-test
# stubs so the golden path can be proven PASS/FAIL on demand with NO live model:
#   EVAL_CMD        the agent under test — fed a task on stdin, prints its answer on stdout.
#                   Default: `claude -p` (headless). This is the kit's first headless-Claude
#                   call: VERIFY the invocation against YOUR installed Claude Code version
#                   before trusting it — nothing here tests it end-to-end with a live model
#                   (Principle 8: check the tool against the installed version, not memory).
#   EVAL_JUDGE_CMD  the judge for rubric evals — a FRESH invocation (builder/judge split,
#                   kickoff Part 3.8). Default: `claude -p`.
#   EVAL_DIR        where the *.eval.md fixtures live. Default: <repo>/evals.
#
# Run:   bash scripts/eval.sh                    (some sandboxes deny `chmod +x`; bash works)
#        EVAL_DIR=evals bash scripts/eval.sh     (explicit fixture dir)
# Exit:  0 = every eval passed, 1 = one or more failed.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP="${TMPDIR:-/tmp}"                            # $TMPDIR is sandbox-writable; /tmp may not be
EVAL_DIR="${EVAL_DIR:-$ROOT/evals}"
EVAL_CMD="${EVAL_CMD:-claude -p}"               # the agent under test (see header)
EVAL_JUDGE_CMD="${EVAL_JUDGE_CMD:-claude -p}"   # the rubric judge — a fresh context

PASS=0; FAIL=0; overall=0
epass() { echo "  ✓ PASS  $1"; PASS=$((PASS+1)); }
efail() { echo "  ✗ FAIL  $1"; FAIL=$((FAIL+1)); overall=1; }

# ── fixture parsing: grep for frontmatter scalars, sed for `## section` bodies. No jq /
#    python3 (a stack-agnostic template can't assume them); BSD/macOS-sed-safe — no `I`
#    flag, lowercase keys, one `-e` per command (a `;` between sed commands is a BSD sore
#    point). CONSTRAINT: no line of a `## section` body may itself begin with `## ` — the
#    range extractor ends a body at the next `## `, so a stray one truncates it. (Documented
#    in evals-template/README.md.)
fm() {  # fm <file> <key>  → value of a frontmatter scalar line `key: value` (an inline ` # comment` is stripped)
    grep -m1 -E "^$2:[[:space:]]" "$1" 2>/dev/null | sed -E -e "s/^$2:[[:space:]]*//" -e 's/[[:space:]]+#.*$//' -e 's/[[:space:]]*$//'
}
body() {  # body <file> <name>  → the body under `## <name>`, up to the next `## ` or EOF
    sed -n "/^## $2\$/,/^## /p" "$1" 2>/dev/null | sed -e '1d' -e '/^## /d'
}
strip_ws() {  # collapse trailing whitespace (golden values + answers are single-line by design)
    printf '%s' "$1" | sed -E 's/[[:space:]]*$//'
}

echo
echo "── BEHAVIORAL EVALS ─────────────────────────────────────"
echo "   fixtures:  $EVAL_DIR"
echo "   builder:   EVAL_CMD=$EVAL_CMD"
echo "   judge:     EVAL_JUDGE_CMD=$EVAL_JUDGE_CMD"
echo

shopt -s nullglob 2>/dev/null || true
found=0
for f in "$EVAL_DIR"/*.eval.md; do
    [ -e "$f" ] || continue        # literal-glob guard when nullglob is unavailable
    found=1
    name=$(basename "$f" .eval.md)
    grade=$(fm "$f" grade)
    input=$(body "$f" input)
    errlog="$TMP/eval_${name}.err"

    case "$grade" in
      golden)
        expected=$(strip_ws "$(body "$f" expected)")
        # stdout = the candidate answer; stderr → a log we surface only on failure (a
        # 2>&1 into the capture would pollute the golden compare; a bare 2>/dev/null would
        # bury a broken command as a silent empty answer).
        candidate=$(strip_ws "$(printf '%s' "$input" | $EVAL_CMD 2>"$errlog")")
        if [ "$candidate" = "$expected" ]; then
            epass "$name  [golden]"
        else
            # brace ${expected}/${candidate}: unbraced, bash's identifier scanner consumes the
            # `»` lead byte (0xC2) into the var name, so under `set -u` a FAILING golden aborts
            # the whole run with `unbound variable` instead of printing FAIL (defect §9.1).
            efail "$name  [golden]  expected «${expected}»  got «${candidate}»"
            [ -s "$errlog" ] && sed 's/^/           stderr: /' "$errlog" | tail -5
        fi
        ;;
      rubric)
        rubric=$(body "$f" rubric)
        # the builder (candidate) and the judge each get their OWN stderr log — so a broken
        # builder's diagnostic (e.g. an empty candidate, the commonest rubric failure) is not
        # clobbered when the judge invocation opens its log for writing.
        candidate=$(printf '%s' "$input" | $EVAL_CMD 2>"$errlog")
        judgelog="$TMP/eval_${name}.judge.err"
        # Force a fixed delimiter the judge emits LAST — the prompt string and the extraction
        # below are one contract, changed together. A free-form judge that reasons before
        # concluding ("...tempting to PASS..." / "...why it did NOT FAIL...") otherwise flips
        # the verdict EITHER direction; anchoring to a trailing VERDICT: line removes that.
        judge_prompt=$(printf 'You are grading an answer against a checklist. You may reason briefly first, but you MUST end your reply with a single line of exactly this form and nothing after it: write "VERDICT: PASS" if the answer satisfies EVERY item, otherwise "VERDICT: FAIL".\n\n--- CHECKLIST ---\n%s\n\n--- ANSWER ---\n%s\n' "$rubric" "$candidate")
        # take the LAST `VERDICT: PASS|FAIL` line (the delimiter above is emitted last), not the
        # first PASS|FAIL anywhere in the output. No VERDICT: line → empty → conservative FAIL.
        verdict=$(printf '%s' "$judge_prompt" | $EVAL_JUDGE_CMD 2>"$judgelog" | grep -oE 'VERDICT:[[:space:]]*(PASS|FAIL)' | tail -1 | grep -oE 'PASS|FAIL')
        if [ "$verdict" = "PASS" ]; then
            epass "$name  [rubric]"
        else
            efail "$name  [rubric]  judge verdict: ${verdict:-<none>}"
            [ -s "$errlog" ]   && sed 's/^/           builder-stderr: /' "$errlog"   | tail -5
            [ -s "$judgelog" ] && sed 's/^/           judge-stderr:   /' "$judgelog" | tail -5
        fi
        ;;
      *)
        efail "$name  unknown grade '${grade:-<missing>}' — set 'grade: golden' or 'grade: rubric'"
        ;;
    esac
done

if [ "$found" -eq 0 ]; then
    echo "  ·  no *.eval.md fixtures in $EVAL_DIR — seed a golden + a rubric case from the"
    echo "     kit's evals-template/ (kickoff §1.6b). Grow to ~8–15 representative cases."
    echo
    exit 0
fi

echo
printf "  PASS: %-4s  FAIL: %s\n" "$PASS" "$FAIL"
echo
if [ $FAIL -gt 0 ]; then
    echo "  RESULT: FAIL — a saved judgment regressed; investigate before shipping the change that triggered this run"
else
    echo "  RESULT: PASS — judgment held across every saved eval"
fi
echo
echo "  This suite ships mostly empty on purpose (kickoff §1.6b). Its worth grows as you add"
echo "  the cases that encode THIS project's judgment. Prefer golden-outputs; keep rubrics"
echo "  blunt; treat a rubric result as a smoke alarm, not a lab scale."
echo
exit $overall

#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Harness scorecard — BASE TEMPLATE (stack-agnostic). Part of the Harness Kit
# (see claude-project-kickoff.md §1.6a). Copy to <repo>/scripts/harness-metrics.sh
# and adapt.
#
# WHAT THIS IS. The gauge on your own engine. The kit measures the *field* (the
# README's evidence); nothing measures whether *this project's* harness — the audit,
# the wiki, the safety net — is actually paying off. This is a cheap, run-it-monthly
# scorecard: a SNAPSHOT of a handful of numbers, APPENDED as one dated line to a trend
# log so you can watch the direction of travel over time.
#
# WHAT THIS IS NOT. It is the quantitative half. Its companion is HARNESS_LOG.md at the
# repo root — the qualitative harness change log, where a *human* writes what changed in the
# harness and why. THIS SCRIPT NEVER WRITES HARNESS_LOG.md; the two are complementary and
# separate. (Different file, too, from this script's own trend log — see below.)
#
# THE HONEST CAVEAT. Do NOT over-instrument: a few numbers looked at monthly beat forty
# ignored. This template computes only the three numbers genuinely derivable from a repo
# (CLAUDE.md line count; audit-check count; eval-fixture count). Everything else worth tracking is a HUMAN
# count — it is stubbed as a "human note required" field, never a fabricated zero. Add a
# manual metric to the trend only once it earns its keep, and only if the project can
# compute it honestly from its own tooling (issue tracker, CI); otherwise leave it in
# HARNESS_LOG.md as prose.
#
# Run:   bash scripts/harness-metrics.sh        (some sandboxes deny `chmod +x`; bash works)
# Trend log:  default <repo>/harness-metrics.log — override with the env var
#             HARNESS_METRICS_LOG (point it at "$TMPDIR/..." for a throwaway test run).
# Exit:  0 always — this is a report, not a gate. Absent inputs are SKIPPED, not failed.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP="${TMPDIR:-/tmp}"                     # $TMPDIR is sandbox-writable; /tmp may not be
TODAY="$(date +%Y-%m-%d)"

# The trend log is an append-only, dated-line file — the log.md analogue from the wiki
# `metrics` subcommand (llm-wiki-kickoff.md §4). It is a DIFFERENT file from HARNESS_LOG.md:
# this one is machine-appended numbers; HARNESS_LOG.md is human-written prose. Default lives
# in the repo; a project decides whether to commit it or gitignore it.
LOG="${HARNESS_METRICS_LOG:-$ROOT/harness-metrics.log}"

CLAUDE_MD="$ROOT/CLAUDE.md"
AUDIT="$ROOT/scripts/audit.sh"            # the project's audit (§1.6) — NOT the kit's base
EVALS="$ROOT/evals"                       # behavioral eval fixtures (§1.6b) — mirrors claude-audit-base.sh

# Computed values default to "n/a" so a missing input degrades to an honest gap, never a
# fake number (the "never crash on a malformed line" spirit of the wiki metrics ledger).
claude_md_lines="n/a"
audit_checks="n/a"
eval_fixtures="n/a"

metric()  { printf "  ✓  %-38s %s\n" "$1" "$2"; }                 # a computed number
skip()    { printf "  ·  %-38s %s\n" "$1" "$2"; }                 # input absent — skipped
manual()  { printf "  ✎  %-38s %s\n" "$1" "${2:-human note required}"; }  # a human count
section() { echo; echo "── $1 ──────────────────────────────────"; }

# delta "<label>" "<current>" "<previous>" — print the trend, but ONLY do arithmetic when
# BOTH readings are plain integers. A parsed "n/a" (or a mangled log line) must never reach
# $(( )); under `set -u` that would abort the run. This guard is what makes the trend parse
# defensive.
delta() {
    local label="$1" cur="$2" prev="$3"
    if printf '%s' "$cur" | grep -qE '^[0-9]+$' && printf '%s' "$prev" | grep -qE '^[0-9]+$'; then
        local d=$(( 10#$cur - 10#$prev )) sign=""   # 10# forces base-10 (a hand-edited 08 isn't octal)
        [ "$d" -gt 0 ] && sign="+"
        echo "     Δ $label: ${sign}${d}  ($prev → $cur)"
    else
        echo "     Δ $label: n/a — needs two numeric readings"
    fi
}

echo "Harness scorecard — $TODAY"
echo "Repo: $ROOT"

# ═══════════════════════════════════════════════════════════════════════════
section "SNAPSHOT — free to compute (derived from the repo)"
# The only three numbers a generic template can honestly derive. All degrade gracefully:
# a repo without a CLAUDE.md, a seeded audit, or an evals/ dir simply skips that line and keeps going.
# ═══════════════════════════════════════════════════════════════════════════
if [ -f "$CLAUDE_MD" ]; then
    claude_md_lines=$(wc -l < "$CLAUDE_MD" 2>/dev/null | tr -d ' ')
    [ -n "$claude_md_lines" ] || claude_md_lines="n/a"
    metric "CLAUDE.md line count" "$claude_md_lines"
else
    skip "CLAUDE.md line count" "no CLAUDE.md at repo root yet — skipped"
fi

if [ -f "$AUDIT" ]; then
    # Approximate: count pass/warn/fail *calls* (not the helper definitions, which are
    # `pass() { … }` — no space+quote after the name). It is a growth gauge — "is my safety net
    # accreting checks?" — not an exact census; tune the pattern to your audit's idiom.
    # Strip full-line `#` comments FIRST (`grep -v '^[[:space:]]*#'`): an INVARIANTS section's
    # worked examples like `# pass "…"` match the call *shape* but never execute, and they
    # accrete as an audit documents itself — inflating the trend exactly opposite to what it
    # should measure. (Trailing `#` comments on a code line are left in: naively stripping them
    # would corrupt a legitimate `grep '#foo'` arg, and they're a rare edge — this stays an
    # honest growth gauge, not an exact census.)
    audit_checks=$(grep -vE '^[[:space:]]*#' "$AUDIT" 2>/dev/null \
        | grep -oE '(^|[[:space:];{]|&&|\|\|)(pass|warn|fail)[[:space:]]+"' | wc -l | tr -d ' ')
    [ -n "$audit_checks" ] || audit_checks="0"
    metric "audit checks (pass/warn/fail calls)" "$audit_checks"
else
    skip "audit checks" "no scripts/audit.sh yet — seed it from claude-audit-base.sh (§1.6)"
fi

if [ -d "$EVALS" ]; then
    # Behavioral eval fixtures — the same free number claude-audit-base.sh already computes
    # for itself (`find "$ROOT/evals" -name '*.eval.md' | wc -l`). "Is my judgment verifier
    # growing with the project?" Absent evals/ degrades to a skip, like the other two.
    eval_fixtures=$(find "$EVALS" -name '*.eval.md' 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$eval_fixtures" ] || eval_fixtures="0"
    metric "eval fixtures (*.eval.md)" "$eval_fixtures"
else
    skip "eval fixtures" "no evals/ dir yet — seed it from evals-template/ (§1.6b)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "SNAPSHOT — human note required (NOT repo-derivable)"
# TODO: these are HUMAN counts — they cannot be derived from the repo, so this script does
# NOT compute them and MUST NOT fabricate a zero. Record the real numbers as prose in
# HARNESS_LOG.md (the qualitative companion). If the project *can* compute one honestly from
# its own tooling (issue tracker, CI, review logs), wire it in and promote it into the
# free-to-compute block above — never emit fake data to fill a column.
# ═══════════════════════════════════════════════════════════════════════════
manual "review rounds per feature (Rule of Five)"   # the Rule of Five — defined in LESSONS.md
manual "how often each guard fired"
manual "% agent changes merged without rework"
manual "defects caught by tests vs by humans"
manual "escaped defects (missed by all verifiers)"
manual "rollbacks needed"
manual "effort per merged change"                   # HUMAN labor (review rounds, rework) — distinct from...
manual "cost per merged change (tokens/\$)"         # ...item Z: the run's SPEND (compute). Govern routing +
                                                    # fan-out width by it (§1.6a); not repo-derivable → human
                                                    # note, never a fabricated zero, never in the trend tab-line.

# ═══════════════════════════════════════════════════════════════════════════
section "TREND  ($LOG)"
# Best-effort read-back of the last dated line, then a delta. Parsing is deliberately
# tolerant: match only lines that begin with a date, pull each field with a sed that yields
# empty on no-match, and let the delta guard reject anything non-numeric. A malformed or
# partial line can never crash the run.
# ═══════════════════════════════════════════════════════════════════════════
prev_line=$(grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' "$LOG" 2>/dev/null | tail -n 1 || true)
if [ -n "$prev_line" ]; then
    prev_date=$(printf '%s' "$prev_line" | awk '{print $1}')
    prev_claude=$(printf '%s' "$prev_line" | sed -nE 's/.*claude_md_lines=([^[:space:]]+).*/\1/p')
    prev_audit=$(printf '%s' "$prev_line" | sed -nE 's/.*audit_checks=([^[:space:]]+).*/\1/p')
    prev_evals=$(printf '%s' "$prev_line" | sed -nE 's/.*eval_fixtures=([^[:space:]]+).*/\1/p')
    [ -n "$prev_claude" ] || prev_claude="n/a"
    [ -n "$prev_audit" ] || prev_audit="n/a"
    [ -n "$prev_evals" ] || prev_evals="n/a"   # older log lines predate this field → n/a, delta stays honest
    echo "  previous ($prev_date):  claude_md_lines=$prev_claude  audit_checks=$prev_audit  eval_fixtures=$prev_evals"
    delta "CLAUDE.md lines" "$claude_md_lines" "$prev_claude"
    delta "audit checks"    "$audit_checks"    "$prev_audit"
    delta "eval fixtures"   "$eval_fixtures"   "$prev_evals"
else
    echo "  ·  no prior entries yet — this run seeds the trend"
fi

# Append this run as one dated line. Create the log (with a header) if new; make the parent
# dir if an override points somewhere that doesn't exist yet. Every write is best-effort so
# an unwritable path degrades to a warning rather than aborting the report.
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
if [ ! -f "$LOG" ]; then
    {
        echo "# harness-metrics trend log — append-only; one dated line per run."
        echo "# fields:  <YYYY-MM-DD>  claude_md_lines=<n|n/a>  audit_checks=<n|n/a>  eval_fixtures=<n|n/a>"
    } > "$LOG" 2>/dev/null || true
fi
if printf '%s\tclaude_md_lines=%s\taudit_checks=%s\teval_fixtures=%s\n' "$TODAY" "$claude_md_lines" "$audit_checks" "$eval_fixtures" >> "$LOG" 2>/dev/null; then
    echo
    echo "  appended → $LOG"
else
    echo
    echo "  ⚠  could not write $LOG — snapshot shown above but not logged"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "REMINDER"
# ═══════════════════════════════════════════════════════════════════════════
echo "  The numbers are half the picture. Write the WHY of any harness change in"
echo "  HARNESS_LOG.md (repo root) — this script never touches it. Start with the three"
echo "  free numbers above; add a manual metric only once it earns its keep."
echo
exit 0

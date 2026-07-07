#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Kit conformance check — the ADOPTION verifier (Harness Kit item O). Part of the
# Harness Kit (see claude-project-kickoff.md §1.6c). Ships pre-placed in <repo>/scripts/;
# run it after kickoff/adoption and periodically thereafter.
#
# WHAT THIS IS. §1.4's "prove it bites, don't trust a self-report" discipline applied to
# the WHOLE kit's *adoption*: it answers "did this project actually adopt the harness,
# completely and conformantly?" — a roster check over the artifacts the kit should have
# produced (CLAUDE.md + its blocks, the per-repo floor, the audit, evals, the wiki, the
# action-risk gates, the named reviewer). It is the structural half of item O; its semantic
# companion is the FAN-OUT PLAYBOOK (Part 3 / §1.6c) — sub-agents that each load one slice
# and read what a grep can't. A lean adoption gets just this script; fan out for big ones.
#
# WHAT THIS IS NOT. It is NOT a second code-health audit. `scripts/audit.sh` asks "is the
# *code* healthy right now?" after every edit; this asks "is the *harness* installed?" once/
# periodically. The audit is ONE line item on this roster — checked present + syntax-valid,
# NEVER executed here (running it checks code health at the wrong cadence and would defeat
# the fan-out). Where this and the audit inspect the same artifact, the SAME predicate is
# reused on purpose (same language, different question).
#
# THE EXIT MODEL — load-bearing; different from BOTH cousins (the audit gates on WARN|FAIL;
# harness-metrics always exits 0):
#     FAIL only what NO correct adoption could omit.  WARN what a lean-but-correct adoption
#     might legitimately skip.  Exit nonzero ONLY on FAIL.
# So a code-only solo throwaway (CLAUDE.md + deny floor + a valid audit, nothing else) comes
# out zero-FAIL / exit 0 — WARNs on the optional roster, but is NOT reported as failing. That
# tier-awareness is HOW this stays project-agnostic; without it the check gets tuned out.
#
# STRUCTURAL ONLY — named, not faked (mirrors the INVARIANTS grep-limits note in the audit and
# item H's candor). This proves artifacts are PRESENT and gross-conformant. It CANNOT prove
# they are CORRECT: a routing block that actually routes, evals that test something real, a
# wiki page that isn't a stub, a CLAUDE.md under the true *instruction* budget. That semantic
# half is the fan-out's / a human's job. Build the structural half; name the semantic half.
#
# Run:     bash scripts/kit-conformance.sh                 (checks the repo it sits in)
#          bash scripts/kit-conformance.sh /path/to/repo   (or set KIT_CONFORMANCE_TARGET=…)
# Tunables: KIT_CONFORMANCE_EVALS_MIN (default 1), the wiki/line thresholds below.
# Exit:    0 = no FAIL (CONFORMANT, or INCOMPLETE with only WARNs);  1 = one or more FAIL.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP="${TMPDIR:-/tmp}"                          # $TMPDIR is sandbox-writable; /tmp may not be

# TARGET = the project being checked. Overridable ($1 or env) so a throwaway fixture can be
# checked without copying this script into it. Default = the repo this script ships in.
TARGET="${1:-${KIT_CONFORMANCE_TARGET:-$ROOT}}"

EVALS_MIN="${KIT_CONFORMANCE_EVALS_MIN:-1}"    # min behavioral-eval cases for a non-throwaway
WIKI_MIN=3                                     # adoption DoD: "at least three real incident/decision pages"
CLAUDE_MD_MAX_LINES=200                        # sourced lean budget (kickoff §1.5); a PROXY — see note

PASS=0; WARN=0; FAIL=0
pass()    { printf "  ✓  %s\n" "$1"; PASS=$((PASS+1)); }
warn()    { printf "  ⚠  %s\n" "$1"; WARN=$((WARN+1)); }
fail()    { printf "  ✗  %s\n" "$1"; FAIL=$((FAIL+1)); }
skip()    { printf "  ·  %s\n" "$1"; }                 # loud SKIP / neutral info — touches NO counter
section() { echo; echo "── $1 ──────────────────────────────────"; }

# Would Claude Code actually LOAD this settings file (defect §9.1)? Returns:
#   0 = loads (strict JSON)   1 = present but Claude Code would silently drop it   2 = can't tell (no python3)
# STRICT JSON on purpose. Verified against Claude Code 2.1.201 (2026-07-06): settings.json is parsed
# as STRICT JSON — NOT JSONC — and ANY `//` comment (a leading banner OR an inline tag) makes CC
# **silently discard the ENTIRE file**: zero rules load, no error (confirmed via `--debug` load logs:
# `projectSettings ... 0 rule(s)`). So a comment in settings.json silently voids your deny gates. A
# strict `json.load` is the right proxy for "CC will load this": it rejects exactly what CC rejects
# (comments, unbalanced braces, trailing commas). (If JSONC ever ships — anthropics/claude-code #17968,
# open as of 2026-07 — this reverses; that re-check is item Y's job.) No hard dep: absent python3 →
# loud "unverified".
settings_loadable() {
    command -v python3 >/dev/null 2>&1 || return 2
    python3 - "$1" <<'PY' 2>/dev/null
import json, sys
try:
    json.load(open(sys.argv[1]))
except Exception:
    sys.exit(1)
PY
}

echo "Kit conformance — adoption verifier (item O)"
echo "Target: $TARGET"

# Resolve the always-loaded contract file BEFORE gating anything on it. Kit policy is that
# "Claude reads either" CLAUDE.md OR AGENTS.md (kickoff §1.5, "On names", :733-734), and a
# project may keep AGENTS.md as the sole physical file with CLAUDE.md merely symlinked to it
# (adoption §"edit it in place", :116-118; ROADMAP §4 names AGENTS.md a real cross-tool
# convention). Prefer CLAUDE.md — a real file OR a symlink, since [ -f ] follows symlinks, so
# a symlinked CLAUDE.md keeps working — else fall back to AGENTS.md. Every downstream check
# reads $CLAUDE_MD, so it inherits the resolution for free; only the source file moves.
if [ -f "$TARGET/CLAUDE.md" ]; then
    CLAUDE_MD="$TARGET/CLAUDE.md"; CONTRACT_NAME="CLAUDE.md"
elif [ -f "$TARGET/AGENTS.md" ]; then
    CLAUDE_MD="$TARGET/AGENTS.md"; CONTRACT_NAME="AGENTS.md"
else
    CLAUDE_MD="$TARGET/CLAUDE.md"; CONTRACT_NAME="CLAUDE.md/AGENTS.md"   # neither exists → FAIL below
fi
SETTINGS="$TARGET/.claude/settings.json"

# ═══════════════════════════════════════════════════════════════════════════
section "CONTRACT (CLAUDE.md / AGENTS.md — the always-loaded agent contract)"
# The contract is the kit's core artifact: FAIL if absent (nothing downstream can be judged).
# Either filename counts (resolved above). Its blocks (routing / reviewer / budget) are WARN —
# a lean adoption may legitimately omit them.
# ═══════════════════════════════════════════════════════════════════════════
if [ -f "$CLAUDE_MD" ]; then
    pass "$CONTRACT_NAME present (the always-loaded agent contract)"
    have_claude=1
else
    fail "no CLAUDE.md or AGENTS.md at target root — the kit's core artifact is missing (kickoff §1.5)"
    have_claude=0
fi

if [ "$have_claude" -eq 1 ]; then
    if grep -qE '^## Knowledge & memory' "$CLAUDE_MD" 2>/dev/null; then
        pass "routing block present (## Knowledge & memory — read-the-wiki-first / knowledge-in-repo-not-~/.claude)"
    else
        warn "no '## Knowledge & memory' routing block in CLAUDE.md — the directive that keeps knowledge in the repo, not machine-local memory (kickoff §1.5)"
    fi

    lines=$(wc -l < "$CLAUDE_MD" 2>/dev/null | tr -d ' '); [ -n "$lines" ] || lines=0
    if [ "$lines" -le "$CLAUDE_MD_MAX_LINES" ]; then
        pass "CLAUDE.md within the lean budget ($lines ≤ ~$CLAUDE_MD_MAX_LINES lines)"
    else
        warn "CLAUDE.md is $lines lines (> ~$CLAUDE_MD_MAX_LINES) — trim toward the lean budget (kickoff §1.5)"
    fi
    skip "budget caveat: line count is a PROXY; the budget that binds is *discrete instructions* (IFScale) — a semantic read (fan-out / a human), not this grep"

    if grep -qE '^## Review' "$CLAUDE_MD" 2>/dev/null; then
        pass "reviewer named (## Review — who reviews + the source of truth they verify against; item V)"
    else
        warn "no '## Review' block in CLAUDE.md — name who reviews the agent's work and the source of truth they check against, not 'looks right' (kickoff §1.5, item V)"
    fi
else
    skip "skipping routing / budget / reviewer rows — they live in the absent CLAUDE.md"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "ACTION-RISK GATES (item R — reversibility × reach, deterministically gated)"
# COMMAND-PATTERN JOIN (mirrors the audit's ACTION-RISK GATES predicate). The old design tagged the
# settings rule with an inline `// action-risk` comment — but settings.json is STRICT JSON, so that
# comment silently voided the whole file (defect §9.1). New join: the CLAUDE.md action-risk table
# (under the `<!-- action-risk -->` marker — markdown, comments fine) names each gate's EXACT rule in
# its last column; we confirm each of those rules is a real, comment-free ask/deny entry in
# settings.json. This proves the SPECIFIC dangerous command is gated (stronger than "some tagged rule
# exists"). WARN, not FAIL — a project acting only on its own code omits the table (tier-aware).
# ═══════════════════════════════════════════════════════════════════════════
if [ "$have_claude" -eq 1 ] && grep -q '<!-- action-risk -->' "$CLAUDE_MD" 2>/dev/null; then
    # Table block = marker line → next `## ` heading; extract backticked `Tool(...)` rules from it.
    ar_rules=$(awk '/<!-- action-risk -->/{f=1} f&&/^## /&&!/action-risk/{exit} f{print}' "$CLAUDE_MD" \
               | grep -oE '`[A-Za-z]+\([^`]*\)`' | tr -d '`' | sort -u)
    if [ -z "$ar_rules" ]; then
        skip "action-risk table present but names no concrete Tool(...) rule to gate — fill the last column with the exact settings rule (§1.3c)"
    else
        # Normalize settings once: active (non-//) lines, all whitespace stripped, so 'Bash(x *)' == 'Bash(x*)'.
        set_norm=""
        [ -f "$SETTINGS" ] && set_norm=$(grep -vE '^[[:space:]]*//' "$SETTINGS" 2>/dev/null | tr -d '[:space:]' || true)
        ar_missing=""
        while IFS= read -r rule; do
            [ -z "$rule" ] && continue
            rn=$(printf '%s' "$rule" | tr -d '[:space:]')
            printf '%s' "$set_norm" | grep -qF -- "$rn" || ar_missing="$ar_missing ${rule}"
        done <<EOF
$ar_rules
EOF
        if [ -z "$ar_missing" ]; then
            pass "action-risk gates wired — every rule named in the CLAUDE.md table is a real ask/deny in .claude/settings.json (§1.3c)"
        else
            warn "action-risk table names rule(s) NOT wired into .claude/settings.json:${ar_missing} — prose is not a boundary; add each as a plain comment-free ask/deny entry (§1.3c)"
        fi
    fi
else
    skip "no action-risk table in CLAUDE.md — fine if the project acts only on its own code (§1.3c)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "PER-REPO FLOOR (.claude/settings.json — the unconditional secret-read denies)"
# The per-repo floor is a committed .claude/settings.json (adoption §1, kickoff §1.3a) — the home of
# the secret-READ denies, the push `ask` gate, and the auto-commit Stop hook. Split by severity, and
# deliberately CONCORDANT with the audit's SECURITY section so the two verifiers never disagree on the
# same input:
#   * file ABSENT              → FAIL — no correct adoption omits the floor file itself.
#   * present but UNLOADABLE    → FAIL — Claude Code parses settings as STRICT JSON and silently drops
#                                 the WHOLE file on any `//` comment or syntax error (verified 2.1.201),
#                                 so a grep still "sees" deny rules that never load. Validated before
#                                 the grep, the same way audit.sh is `bash -n`-checked.
#   * present, no read-deny     → WARN — matches the audit's "#1 gap" nudge; a write-deny alone doesn't
#                                 stop read+exfiltrate, BUT the managed floor's Read(**/.env) glob can
#                                 cover this repo's secrets, so a floored machine may correctly omit the
#                                 repo-level read-deny. WARN, not FAIL (this is the "FAIL only what NO
#                                 correct adoption could omit" test applied honestly).
# ═══════════════════════════════════════════════════════════════════════════
if [ -f "$SETTINGS" ]; then
    settings_loadable "$SETTINGS"; sload=$?
    if [ "$sload" -eq 1 ]; then
        fail ".claude/settings.json is present but Claude Code would SILENTLY DROP it — not strict JSON (a // comment or a syntax error), so ALL its deny/ask/hook rules take no effect and a text grep of it means nothing (verified CC 2.1.201; defect §9.1; kickoff §1.3)"
    else
        [ "$sload" -eq 2 ] && skip "couldn't confirm .claude/settings.json parses (python3 not found) — its validity is UNVERIFIED and the floor check below is best-effort (SKIPPED ≠ PASS)"
        deny_reads=$(grep -E '"Read\(' "$SETTINGS" 2>/dev/null | grep -vE '^[[:space:]]*//' \
                     | grep -iE '\.env|secret|\.pem|credential|\.key|\.token' || true)
        if [ -n "$deny_reads" ]; then
            pass "per-repo deny floor present — active secret-READ deny in .claude/settings.json (kickoff §1.3a)"
        else
            warn "settings present but NO active secret-READ deny — guarding writes but not reads is the #1 gap (kickoff §1.3a); OK only if the managed floor's Read(**/.env) covers this repo's secrets — confirm via '/status'"
        fi
    fi
else
    fail "no .claude/settings.json at target — the per-repo floor (secret-read denies, push gate, Stop hook) is unadopted (kickoff §1.3)"
fi

# Managed floor: a root-owned OS file OUTSIDE the repo. The kit's ONLY source of hard guarantees
# (Part 0), and installing it is a manual, un-nagged step — so if nothing ever reads it, a machine
# that SKIPPED the install looks identical to one that did it. The file is typically world-readable
# (mode 0644), so WHEN WE CAN READ IT we verify its CONTENT: checking that critical keys are PRESENT
# is different from inferring the floor from a file's absence, so a content PASS here does NOT violate
# SKIPPED ≠ PASS (§9.2). Can't read/find it → loud SKIP, as before.
MANAGED_FILE=""
if [ -n "${CONFORMANCE_MANAGED_FILE:-}" ]; then
    MANAGED_FILE="$CONFORMANCE_MANAGED_FILE"   # test seam (mirrors the audit's AUDIT_SKIP_*): aim the check at a fixture, no root needed
else
    for m in "/Library/Application Support/ClaudeCode/managed-settings.json" \
             "/etc/claude-code/managed-settings.json"; do
        [ -f "$m" ] && { MANAGED_FILE="$m"; break; }
    done
fi
if [ -n "$MANAGED_FILE" ] && [ -r "$MANAGED_FILE" ]; then
    settings_loadable "$MANAGED_FILE"; ml=$?
    if [ "$ml" -eq 1 ]; then
        warn "managed floor at $MANAGED_FILE is present but NOT strict JSON — Claude Code SILENTLY DROPS the whole file, so the hard floor is inert (a // comment? §9.1) — fix the JSON, then re-run 'claude doctor'"
    else
        # A real floor carries all three: bypass disabled, a machine-credential READ deny, the OS sandbox.
        mf_missing=""
        grep -q '"disableBypassPermissionsMode"' "$MANAGED_FILE" 2>/dev/null || mf_missing="$mf_missing bypass-disable"
        grep -qE '"Read\((~/\.ssh|~/\.aws|\*\*/\.env)' "$MANAGED_FILE" 2>/dev/null || mf_missing="$mf_missing credential-read-deny"
        grep -q '"sandbox"' "$MANAGED_FILE" 2>/dev/null || mf_missing="$mf_missing sandbox"
        if [ -z "$mf_missing" ]; then
            pass "managed floor CONTENT verified at $MANAGED_FILE — bypass-disable + credential read-deny + OS sandbox all present (still confirm it RESOLVES: '/status' source = \"managed\", 'claude doctor'; Part 0)"
        else
            warn "managed floor file found at $MANAGED_FILE but MISSING critical key(s):${mf_missing} — the hard floor may be incomplete; diff it against templates/managed-settings.template.json (Part 0)"
        fi
    fi
else
    skip "managed floor: not readable from here — confirm with '/status' (source resolves to \"managed\") + 'claude doctor' (Part 0). SKIPPED ≠ PASS"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "VERIFIERS (the seeded audit + behavioral evals)"
# The audit is ONE roster item: present + `bash -n`-valid → PASS. NOT executed (that is the
# audit's own after-every-edit cadence, and running it would couple the two scripts and defeat
# the fan-out). Evals reuse the audit's BEHAVIORAL EVALS anchor; WARN below the floor count.
# ═══════════════════════════════════════════════════════════════════════════
AUDIT="$TARGET/scripts/audit.sh"
if [ -f "$AUDIT" ]; then
    if bash -n "$AUDIT" 2>/dev/null; then
        pass "code-health audit installed + syntax-valid (scripts/audit.sh, §1.6) — not executed here (that is the audit's own cadence)"
    else
        fail "scripts/audit.sh present but 'bash -n' reports a syntax error — the audit can't run (§1.6)"
    fi
else
    fail "no scripts/audit.sh — the after-every-edit code-health verifier is unadopted; seed it from claude-audit-base.sh (§1.6)"
fi

n_evals=$(find "$TARGET/evals" -name '*.eval.md' 2>/dev/null | wc -l | tr -d ' '); [ -n "$n_evals" ] || n_evals=0
if [ "$n_evals" -ge "$EVALS_MIN" ]; then
    pass "behavioral evals present ($n_evals ≥ $EVALS_MIN .eval.md) — the judgment verifier, re-run at a model/CLAUDE.md/skill change (§1.6b)"
    [ -f "$TARGET/scripts/eval.sh" ] || warn "evals/ present but no scripts/eval.sh runner — seed it from claude-eval-base.sh (§1.6b)"
else
    warn "behavioral evals: $n_evals/$EVALS_MIN .eval.md case(s) — seed evals/ + scripts/eval.sh from the kit (§1.6b)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "KNOWLEDGE WIKI (the incident/decision record)"
# Adoption DoD (adoption §4/§159): "at least three real incident/decision pages (or the project
# has consciously deferred it)." A small stable project may stop at commit bodies + audit guards
# (adoption §133) — so WARN, NEVER FAIL. Counts the kit's convention wiki/decisions/*.md, plus
# incident-shaped pages elsewhere under wiki/.
# ═══════════════════════════════════════════════════════════════════════════
n_wiki=0
if [ -d "$TARGET/wiki" ]; then
    n_wiki=$(find "$TARGET/wiki" \( -path '*/decisions/*.md' -o -path '*/incidents/*.md' -o -name '*incident*.md' \) 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$n_wiki" ] || n_wiki=0
fi
if [ "$n_wiki" -ge "$WIKI_MIN" ]; then
    pass "wiki holds $n_wiki incident/decision page(s) (≥ $WIKI_MIN) — the 'we tried X, it failed because Y' record (adoption §4)"
else
    warn "wiki has $n_wiki/$WIKI_MIN incident/decision page(s) — mine git log + postmortems for the first few, or consciously defer the wiki (adoption §4, §133)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "ADOPTION SCORECARD"
# Exit model (see header): nonzero ONLY on FAIL. WARN/SKIP → exit 0 (a lean adoption is allowed
# to skip the optional roster). This is the whole point of the FAIL-vs-WARN partition.
# ═══════════════════════════════════════════════════════════════════════════
echo
printf "  PASS: %-4s  WARN: %-4s  FAIL: %s\n" "$PASS" "$WARN" "$FAIL"
echo
if   [ "$FAIL" -gt 0 ]; then
    echo "  RESULT: FAIL — a load-bearing floor artifact is missing (fix every ✗)."
    echo "  (For a big adoption, fan out per area — kickoff §1.6c / Part 3 — to read what greps can't.)"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo "  RESULT: INCOMPLETE — the floor is present; review each ⚠ (a lean adoption may legitimately skip some)."
    echo "  (For a big adoption, fan out per area — kickoff §1.6c / Part 3 — to read what greps can't.)"
    exit 0
else
    echo "  RESULT: CONFORMANT ✓ — every checked artifact is present (bar any · SKIP lines above, which you must confirm by hand)."
    exit 0
fi

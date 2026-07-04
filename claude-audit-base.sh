#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Code-health audit — BASE TEMPLATE (stack-agnostic). Part of the Harness Kit
# (see claude-project-kickoff.md). Copy to <repo>/scripts/audit.sh and adapt.
#
# The value of this script is NOT the generic checks below — it's the
# project-specific ones YOU add. Encode every load-bearing invariant (from your
# CLAUDE.md / spec) and every fixed bug as a greppable check so they can't
# silently regress. Generic linting lives in your linter/test runner; this script
# checks what those can't see: architecture rules, design conventions, invariants,
# and known-bug regression guards.
#
# This script is the MACHINE-CHECK layer. The terse guardrail belongs in CLAUDE.md;
# the full story behind a guard — root cause, the fixes that did NOT work, the why —
# belongs in a wiki incident/decision page (llm-wiki-kickoff.md §2.4). Keep the three
# layers distinct: guardrail → CLAUDE.md, grep → here, story → wiki.
#
# Run:   bash scripts/audit.sh        (some sandboxes deny `chmod +x`; bash works)
# Skip a slow step:  AUDIT_SKIP_BUILD=1 bash scripts/audit.sh
#   (also AUDIT_SKIP_SCA=1 — the network-bound dependency-vulnerability scan, §DEPENDENCY VULNERABILITIES)
# Exit:  0 = clean, 1 = one or more WARN/FAIL.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP="${TMPDIR:-/tmp}"            # $TMPDIR is sandbox-writable; /tmp may not be
SRC="$ROOT/src"                  # TODO: point at your source dir(s), e.g.
                                 #   "$ROOT/backend/app"  or  "$ROOT/frontend/src"
UI=""                            # TODO (UI projects): component/style source, e.g.
                                 #   "$ROOT/frontend/src" — enables the DESIGN SYSTEM
                                 #   checks. Leave empty for backend-only projects.
TOKENS_FILE=""                   # optional: your tokens/theme file (e.g.
                                 #   "$ROOT/frontend/src/styles/tokens.css") — exempted
                                 #   from the raw-value checks, since it DEFINES the values.
WIKI_LINT_CMD=""                 # optional: command that lints an LLM knowledge wiki, e.g.
                                 #   "python3 wiki/wiki.py lint" — see llm-wiki-kickoff.md.
                                 #   Leave empty if the project has no wiki.
OFFLINE_ASSETS=""                # set to 1 for an offline / air-gapped / privacy-first
                                 #   target — enables the "no CDN asset in markup" check
                                 #   (assets must be vendored locally). Leave empty otherwise.
PASS=0; WARN=0; FAIL=0; overall=0
# Anchored-safeguard roll-up — populated by guarded() below, reported by the SAFEGUARD SELF-CHECK
# section ("audit the audit"). Plain counters + a string (not a bash array) so it's safe under
# `set -u` on old bash (3.2) too. Initialized here, before any guard runs.
GUARDS_TOTAL=0; GUARDS_ROTTED=0; GUARDS_ROTTED_LIST=""

pass()    { echo "  ✓  $1"; PASS=$((PASS+1)); }
warn()    { echo "  ⚠  $1"; WARN=$((WARN+1)); overall=1; }
fail()    { echo "  ✗  $1"; FAIL=$((FAIL+1)); overall=1; }
section() { echo; echo "── $1 ──────────────────────────────────"; }

# Run a build/lint/test command; FAIL (with tail of output) if it exits nonzero.
run_tool() {  # run_tool "<label>" "<shell command>"
    local label="$1" cmd="$2"
    if eval "$cmd" >"$TMP/audit_tool.txt" 2>&1; then
        pass "$label"
    else
        fail "$label"; sed 's/^/       /' "$TMP/audit_tool.txt" | tail -20
    fi
}

# ── Anchor-checked safeguard (rot-proof guards — kickoff §1.6, ROADMAP item H) ───────────────
# A safeguard is a grep, and a grep rots SILENTLY. An "absent from file.x" guard keeps returning
# green after someone renames file.x or refactors the thing away — it protects nothing but still
# READS as protection. That is worse than no guard: false confidence (a check that no longer runs
# is just prose — §1.3a). `guarded` fixes it: a guard declares the ANCHOR it depends on and this
# helper confirms the anchor still RESOLVES before the real check runs. Use it as a GATE clause,
# so the guard body stays plain shell (no eval-string quoting):
#
#   guarded "<what it protects>" "<anchor-file>" "<symbol|''>" && {
#       <the real check — greps + pass/warn/fail, exactly as before>
#   }
#
#   <anchor-file>  path (relative to $ROOT, or absolute) the guard inspects — the file that, if
#                  renamed/deleted, would make the guard silently meaningless.
#   <symbol>       OPTIONAL literal string that must still appear IN that file (a function, a
#                  table/column name, a marker) — the finer anchor; '' = file-existence only.
#
# Anchor present → returns 0, the { real check } runs and pass/warn/fails as designed.
# Anchor GONE    → WARNs loudly ("lost its anchor — re-point it or retire it") and returns 1, so
#                  the body is SKIPPED. A missing anchor never reads as pass — that is the point.
# Either way the call is tallied for the SAFEGUARD SELF-CHECK roll-up below.
#
# HONEST LIMIT (mirrors the INVARIANTS grep-limits note): this catches STRUCTURAL rot only — the
# anchored file/symbol VANISHED. It cannot catch SEMANTIC rot — the anchor still exists but the
# code it guarded was refactored so the pattern no longer means what it did. That is a human read
# (a review / LLM-judge pass), not something a grep can prove.
guarded() {  # "<what>" "<anchor-file>" "<symbol|''>"   (use as: guarded ... && { <real check> })
    local what="$1" afile="$2" asym="${3:-}" apath
    case "$afile" in /*) apath="$afile" ;; *) apath="$ROOT/$afile" ;; esac
    GUARDS_TOTAL=$((GUARDS_TOTAL+1))
    if [ ! -e "$apath" ]; then
        warn "safeguard for $what has lost its anchor ($afile) — re-point it or retire it (rotted, NOT passed; kickoff §1.6)"
        GUARDS_ROTTED=$((GUARDS_ROTTED+1)); GUARDS_ROTTED_LIST="$GUARDS_ROTTED_LIST
       - $what  (anchor: $afile)"
        return 1
    fi
    if [ -n "$asym" ] && ! grep -qF -- "$asym" "$apath" 2>/dev/null; then
        warn "safeguard for $what has lost its anchor ($afile:$asym) — re-point it or retire it (rotted, NOT passed; kickoff §1.6)"
        GUARDS_ROTTED=$((GUARDS_ROTTED+1)); GUARDS_ROTTED_LIST="$GUARDS_ROTTED_LIST
       - $what  (anchor: $afile:$asym)"
        return 1
    fi
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════
section "TOOLING (lint · types · tests · build)"
# Run the project's real tools — the things grep can't judge. Examples by stack:
#   Python (uv):  run_tool "lint"  '(cd "$ROOT/backend" && uv run ruff check .)'
#                 run_tool "tests" '(cd "$ROOT/backend" && uv run pytest -q)'
#   Node/TS:      run_tool "build" '(cd "$ROOT/frontend" && npm run build)'
#   Go:           run_tool "vet"   '(cd "$ROOT" && go vet ./...)'
#                 run_tool "tests" '(cd "$ROOT" && go test ./...)'
#   Rust:         run_tool "clippy" '(cd "$ROOT" && cargo clippy -- -D warnings)'
# ═══════════════════════════════════════════════════════════════════════════
# TODO: uncomment + fill in your commands.
# run_tool "lint"  '(cd "$ROOT" && <lint cmd>)'
# run_tool "tests" '(cd "$ROOT" && <test cmd>)'
warn "TOOLING not configured — wire your lint/test/build commands"

# ═══════════════════════════════════════════════════════════════════════════
section "INVARIANTS (from your CLAUDE.md / spec)"
# THE HEART OF THIS SCRIPT. For each load-bearing rule, write a grep that FAILs
# when the rule is violated. Real examples (replace with yours):
#   - a value-sign convention  → flag abs()/sign-flips on that value
#   - an immutable field        → flag UPDATE/setters of it
#   - "never load whole table"  → flag unbounded fetchall / SELECT * w/o LIMIT
#   - "data access in one layer" → flag raw queries outside that layer
# Template:
#   hits=$(grep -rnE --include="*.<ext>" '<bad pattern>' "$SRC" 2>/dev/null || true)
#   [ -n "$hits" ] && { fail "<invariant> violated"; echo "$hits" | sed 's/^/       /'; } \
#                   || pass "<invariant> holds"
#
# ANCHOR any guard that asserts a bad pattern is ABSENT from a SPECIFIC file (kickoff §1.6). Such a
# guard rots SILENTLY: rename the file and the grep matches nothing, so it passes GREEN forever
# while protecting nothing. Wrap it in guarded() (defined at the top of this script) — the guard
# runs only while its anchor resolves, and WARNs loudly (never passes) once the anchor is gone:
#   guarded "<invariant> holds" "src/path/to/file.ext" "<optional symbol>" && {
#       hits=$(grep -rnE '<bad pattern>' "$SRC/path/to/file.ext" 2>/dev/null || true)
#       [ -n "$hits" ] && { fail "<invariant> violated"; echo "$hits" | sed 's/^/       /'; } \
#                       || pass "<invariant> holds"
#   }
# (A guard that scans a whole dir — $SRC / $UI / $ROOT/content — anchors to a dir that always
# exists, so it can't rot this way; leave those unwrapped. Anchoring earns its keep for the
# named-file guards below.)
#
# Three starter examples (adapt paths and patterns to your project):
#
# 1. Pure-function layer guard — a module declared pure (no I/O, no DB, no network)
#    must not import from impure layers. Catches mixed-concern creep before it spreads.
#    ANCHORED: this is the textbook rot case — an "absent from pure_module.py" guard that would
#    pass green the day the module is renamed. It declares the file as its anchor, so guarded()
#    WARNs on a lost anchor instead of falsely passing.
#   guarded "pure module has no I/O imports" "src/yourapp/pure_module.py" "" && {
#       impure=$(grep -rnE 'import (db|requests|subprocess|httpx|urllib)' "$SRC/yourapp/pure_module.py" 2>/dev/null || true)
#       [ -n "$impure" ] && { fail "pure module imports from I/O layer — violates pure-function contract"; echo "$impure" | sed 's/^/       /'; } \
#                        || pass "pure module has no I/O imports"
#   }
#
# 2. Additive-schema guard — schema must never contain destructive changes
#    (DROP TABLE / DROP COLUMN). For any project that promises backwards-compatible
#    schema evolution.
#   destructive=$(grep -rnE 'DROP TABLE|DROP COLUMN|ALTER TABLE[^;]+DROP' "$SRC" 2>/dev/null || true)
#   [ -n "$destructive" ] && { fail "destructive schema change — schema must be additive-only"; echo "$destructive" | sed 's/^/       /'; } \
#                          || pass "schema is additive-only (no DROP TABLE/COLUMN)"
#
# 3. Diagnostic read-back guard — a write-only diagnostic/snapshot table must never
#    be read by the engine that writes it (prevents a log → score → log feedback loop).
#    ANCHORED with a SYMBOL: the guard depends on BOTH engine.py existing AND the table name
#    your_log_table still being the thing to look for. Rename the table and the "no read-back"
#    grep silently passes — so the table name is the finer anchor; guarded() WARNs if it's gone.
#   guarded "diagnostic log is write-only from the engine" "src/yourapp/engine.py" "your_log_table" && {
#       readback=$(grep -rnE 'FROM\s+your_log_table|SELECT.*your_log_table' "$SRC/yourapp/engine.py" 2>/dev/null || true)
#       [ -n "$readback" ] && { fail "engine reads from its own diagnostic log — feedback loop"; echo "$readback" | sed 's/^/       /'; } \
#                          || pass "diagnostic log is write-only from the engine"
#   }
#
# 4. Single-source derived value — a value the API layer computes (kickoff Principle 1)
#    must not be re-derived in the client, or the two drift. Name the server field,
#    then flag a client-side re-computation of it. (Only for a client/server split.)
#   redrv=$(grep -rnE '<client re-deriving a server-owned value>' "$UI" 2>/dev/null || true)
#   [ -n "$redrv" ] && { fail "client re-derives a value the API already returns — will drift"; echo "$redrv" | sed 's/^/       /'; } \
#                    || pass "derived values come from the API, not re-computed client-side"
#
# 5. Content/editorial invariant — for a prose/facts project, guard banned terms and
#    corrected facts (the wrong value otherwise creeps back, often as a paraphrase).
#   banned=$(grep -rniE '\b(off-brand-term|forbidden-word)\b' "$ROOT/content" 2>/dev/null || true)
#   [ -n "$banned" ] && { fail "banned term in content"; echo "$banned" | sed 's/^/       /'; } \
#                     || pass "no banned terms in content"
#   # corrected fact — FAIL if the old wrong value reappears (name the fact + date):
#   stale=$(grep -rn '800W' "$ROOT/content" 2>/dev/null || true)   # [fact] unit is 1,200W, fixed 2026-06-13
#   [ -n "$stale" ] && { fail "[fact] regressed value reappeared — verify against source"; echo "$stale" | sed 's/^/       /'; } \
#                    || pass "[fact] corrected value holds"
#   NOTE: greps catch only the *literal* form. A banned *concept* returns as a paraphrase no
#   regex matches — list those semantic invariants here as comments and verify them with a
#   read / LLM-judge pass (see the kickoff "content / editorial projects" appendix).
# ═══════════════════════════════════════════════════════════════════════════
warn "INVARIANT checks not configured — encode your CONTRACT/spec rules here"

# ═══════════════════════════════════════════════════════════════════════════
section "SECURITY"
# Adapt to your language. High-value checks: hardcoded secrets; parameterized
# queries only (no value interpolation/concat into SQL); no unexpected outbound
# network for an offline-by-design app; safe deserialization; authz on mutations.
# ═══════════════════════════════════════════════════════════════════════════
secrets=$(grep -rniE '(secret|password|api[_-]?key|access_token)\s*[:=]\s*["'\''][A-Za-z0-9_\-]{8,}' "$SRC" "$ROOT/README.md" 2>/dev/null \
          | grep -vE '= *""|= *None|= *null|getenv|environ|process\.env|^\s*[^:]+:[0-9]+:\s*(#|//)' || true)
[ -n "$secrets" ] && { warn "possible hardcoded secret(s) — verify these are not real"; echo "$secrets" | sed 's/^/       /'; } \
                  || pass "no obvious hardcoded secrets"

# Entropy pass — the grep above is PREFIX-BOUND: it only fires on a secret wearing a
# `key = "..."` label. A BARE credential — a token pasted with no assignment — sails past
# it. This second pass flags long, high-entropy strings (the SHAPE of a real credential:
# base64/hex, above an entropy threshold) even when unlabeled. Thresholds follow
# truffleHog's defaults — hex ≥ 3.0, base64 ≥ 4.5 bits/char — computed in awk (a standard
# tool; no new runtime dep for the audit). It is a HEURISTIC, so WARN not FAIL, and it only
# earns its keep behind an allowlist: git SHAs, UUIDs, and example/placeholder tokens are all
# high-entropy but NOT secrets, and lockfiles are excluded outright (they are full of
# legitimate integrity hashes). Same candor as the grep-limits note in INVARIANTS: entropy is
# a shape, not a meaning — a low-entropy secret (a dictionary-word passphrase) is invisible to
# it, and a flagged string may be an innocent hash. Verify, then allowlist the false positive
# (extend the exclusion grep below, or annotate the line). A min length is enforced twice: the
# {20,} in the token grep, and n<20 skip in awk — and the base64 4.5 threshold is itself
# unreachable below ~23 chars, so short tokens self-filter.
entropy_hits=$(grep -rnoaE --exclude-dir='.git' --exclude-dir='node_modules' \
                   --exclude-dir='dist' --exclude-dir='build' \
                   --exclude='*.min.*' --exclude='*.map' \
                   --exclude='*.lock' --exclude='*-lock.json' --exclude='*.sum' \
                   '[A-Za-z0-9+/=_-]{20,}' "$SRC" "$ROOT/README.md" 2>/dev/null \
               | grep -viE ':[0-9a-f]{40}$|:[0-9a-f]{64}$|:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$|example|changeme|placeholder|redacted|dummy|sample|xxxx+|your[_-]?(key|token|secret|pass)' \
               | awk -F: '
                   { tok=$NF; loc=substr($0,1,length($0)-length(tok)-1); n=length(tok)
                     if (n<20) next
                     for (k in f) delete f[k]
                     for (i=1;i<=n;i++){ c=substr(tok,i,1); f[c]++ }
                     H=0; for (c in f){ p=f[c]/n; H-=p*(log(p)/log(2)) }
                     thresh=(tok ~ /^[0-9a-f]+$/ ? 3.0 : 4.5)
                     if (H>=thresh) printf "%s  (entropy %.1f)  %s\n", loc, H, tok }' \
               | head -20 || true)
[ -n "$entropy_hits" ] && { warn "high-entropy string(s) — possible UNLABELED secret (heuristic; verify, then allowlist any git-SHA/UUID/placeholder false positive)"; echo "$entropy_hits" | sed 's/^/       /'; } \
                       || pass "no high-entropy strings resembling an unlabeled secret"

# Path traversal — untrusted input (a request/upload filename) used in a filesystem
# path without basename-sanitizing. Heuristic + framework-specific; annotate a
# verified-safe call with  path-ok . Tune the patterns to your stack.
traversal=$(grep -rnE '(open|write_bytes|save|Path|os\.path\.join|join)\([^)]*\b(request|upload|file|params|args|user)[A-Za-z_.]*\b' "$SRC" 2>/dev/null \
            | grep -iE 'filename|file_name|\.name|path' \
            | grep -vE 'path-ok|basename|secure_filename|_safe_name|sanitiz' || true)
[ -n "$traversal" ] && { warn "untrusted filename in a filesystem path — sanitize to a basename (traversal)"; echo "$traversal" | sed 's/^/       /' | head -20; } \
                    || pass "no obvious untrusted-filename-in-path"

# Offline / air-gapped / privacy-first target: no CDN-loaded assets in markup — they
# break with no internet and phone home. Opt-in via OFFLINE_ASSETS. annotate an
# intentional remote ref with  cdn-ok .
if [ -n "$OFFLINE_ASSETS" ]; then
    scan="${UI:-$SRC}"
    cdn=$(grep -rnE '<(script|link|img|source)[^>]*(src|href)="https?://' "$scan" 2>/dev/null \
          | grep -vE 'cdn-ok' || true)
    [ -n "$cdn" ] && { fail "[offline] external CDN asset in markup — vendor it locally"; echo "$cdn" | sed 's/^/       /' | head -20; } \
                  || pass "[offline] no external CDN assets in markup"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "ACTION-RISK GATES (deterministic enforcement — kickoff §1.3c)"
# An action-risk table in CLAUDE.md (§1.5) classifies what the agent can do by reversibility × reach
# and maps the dangerous classes to ask/deny gates. But that table is PROSE, and prose is not a
# boundary (§1.3a): a row marked ask/deny gates nothing until a real rule exists in
# .claude/settings.json. This proves the WIRING — if CLAUDE.md carries the shared action-risk marker
# AND a table row names an ask/deny gate, then .claude/settings.json must carry an ACTIVE rule bearing
# the paired action-risk tag. WARN, not FAIL — tier-aware like the evals/README presence checks: a
# project with no outward actions simply omits the table and this stays silent.
#
# NOTE (mirrors the INVARIANTS grep-limits note above): this keys on the MARKER, not on semantic
# action->rule correctness — it catches the gross "tagged table, zero tagged gates" case; verifying that
# each row is wired to the RIGHT rule is a read / judgment pass, not a parser. Two design points let the
# marker do a join a bare ask/deny grep cannot:
#   * it keys on the action-risk tag, NOT on ask/deny presence — so the FLOOR's own untagged
#     ask(git push) / deny(secret reads) never satisfy it (those rules carry no tag); and
#   * it counts the tag only on an ACTIVE (non-'//'-comment) settings line — so the template's OWN
#     commented action-risk examples, and any commented-out rule, can't create a false green.
# ═══════════════════════════════════════════════════════════════════════════
ar_claude="$ROOT/CLAUDE.md"
ar_settings="$ROOT/.claude/settings.json"
if [ -f "$ar_claude" ] && grep -qiE 'action-risk' "$ar_claude" 2>/dev/null \
   && grep -qiE '\|[^|]*\b(ask|deny)\b' "$ar_claude" 2>/dev/null; then
    # CLAUDE.md declares an action-risk table naming ask/deny gates → settings must carry a tagged rule.
    ar_tagged=""
    [ -f "$ar_settings" ] && ar_tagged=$(grep -iE 'action-risk' "$ar_settings" 2>/dev/null | grep -vE '^[[:space:]]*//' || true)
    if [ -n "$ar_tagged" ]; then
        pass "action-risk gates wired — CLAUDE.md table names ask/deny and .claude/settings.json carries a tagged rule (§1.3c)"
    else
        warn "action-risk table in CLAUDE.md names ask/deny gates but NO .claude/settings.json rule bears the paired 'action-risk' marker — high-risk action classes described but not gated; prose is not a boundary (kickoff §1.3c)"
    fi
else
    echo "  ·  no action-risk table in CLAUDE.md (fine if the project acts only on its own code — §1.3c)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "GIT HYGIENE"
# The kickoff's auto-commit Stop hook uses `git add -u` (tracked files only), so it
# won't stage untracked secrets — but it can't catch a secret that was previously
# committed and is already tracked. This is the backstop: a secret tracked in git
# is a FAIL. Also nudge toward committing in logical units. NOTE: running this whole
# script as a CI step is the TOOL-AGNOSTIC enforcer — it fires no matter who committed
# (a different LLM/tool, a human, or CI) and catches an already-committed secret a
# client-side pre-commit hook never sees (which does NOT run in CI). See kickoff §1.3b.
# ═══════════════════════════════════════════════════════════════════════════
if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    # Tune the pattern to your project's secret files; cross-check denyWrite in
    # .claude/settings.json. A tracked secret means gitignore is incomplete.
    tracked_secrets=$(git -C "$ROOT" ls-files | grep -iE '(^|/)(\.env($|\.)|secrets?/|.*\.pem$|.*\.key$|id_rsa|credentials)' || true)
    [ -n "$tracked_secrets" ] && { fail "SECRET FILE TRACKED IN GIT — gitignore it + 'git rm --cached' now:"; echo "$tracked_secrets" | sed 's/^/       /'; } \
                              || pass "no obvious secret files tracked"
    # Settings guards WRITES but not secret READS? The sandbox is Bash-only and denyWrite
    # only blocks clobbering a secret — it does NOT stop the agent (or a native Read) from
    # reading .env/secrets and sending the contents off. The safety floor adds permission-
    # layer Read denies for exactly this (kickoff §1.3a). WARN if settings exist but carry no
    # secret-Read deny — a project guarding writes but not reads is the #1 gap. Grep-only.
    settings_file="$ROOT/.claude/settings.json"
    if [ -f "$settings_file" ]; then
        if grep -qE 'denyWrite|"Write\(|"Edit\(' "$settings_file" 2>/dev/null \
           && ! grep -qE '"Read\((\./)?(~/\.ssh|~/\.aws|\.env|secrets)' "$settings_file" 2>/dev/null; then
            warn ".claude/settings.json guards secret WRITES but has no secret-READ deny — add permissions.deny Read(./.env*), Read(./secrets/**), Read(~/.ssh/**) (kickoff §1.3a; sandbox is Bash-only, denyWrite can't stop a read+exfil)"
        else
            pass "settings carries a secret-read deny (or no write-guard to mismatch)"
        fi
    fi
    # Bulk-data / backup artifacts: not always secret, but they're what a broad
    # auto-commit sweeps and where credentials hide (a DB holding tokens, a .env.bak).
    # WARN (not FAIL): a legit fixture DB may be tracked on purpose — review each.
    tracked_data=$(git -C "$ROOT" ls-files | grep -iE '(^|/)backups?/|\.bak$|\.dump$|\.sqlite[0-9]?$|\.db$|\.db-(wal|shm|journal)$' || true)
    [ -n "$tracked_data" ] && { warn "data-store / backup artifact tracked in git — confirm no secrets + keep bulk data out of the repo"; echo "$tracked_data" | sed 's/^/       /'; } \
                           || pass "no data-store / backup artifacts tracked"
    # Harness Kit scaffolding is ONE-TIME: its OUTPUTS persist (CLAUDE.md, this script, wiki/,
    # README.md, the PRD, scripts/eval.sh, evals/, scripts/harness-metrics.sh, HARNESS_LOG.md),
    # its SOURCE guides/templates should not —
    # committed, they reload into every future session's context for nothing. WARN if any
    # source file is tracked. This guard uses TWO structurally different mechanisms, because
    # the sources come in two shapes:
    #   (1) DISTINCTIVELY-NAMED sources (claude-project-kickoff.md, claude-audit-base.sh,
    #       claude-eval-base.sh, prd-template.md, …) → caught by BASENAME in the alternation
    #       below. Safe because each project OUTPUT is RENAMED on copy (audit.sh, eval.sh, the
    #       PRD), so the distinct source name never collides with a legitimate output.
    #   (2) The evals-template/ directory's CONTENTS are NOT distinctively named — a plain
    #       README.md plus *.eval.md files, identical in name to the project's OWN evals/
    #       outputs. A basename/stem match can't catch them without false-flagging every
    #       project's own README.md, so they need a PATH-SEGMENT clause instead:
    #       (^|/)evals-template/ — matches the committed SOURCE dir but not the renamed output
    #       dir evals/ (and not near-misses like evals-templates/ or my-evals-template/).
    #   (3) scripts/harness-metrics.sh and root HARNESS_LOG.md are in NEITHER clause BY DESIGN.
    #       Unlike claude-audit-base.sh (a root source RENAMED to scripts/audit.sh on copy), the kit
    #       ships these two AT their output name/path — so a project's copy is byte-identical to a
    #       legitimate output: there is no distinct source form to catch, and nothing is harmful if
    #       one is "copied" (it equals what the project keeps anyway). harness-metrics.sh ships
    #       pre-placed in scripts/ so ROOT resolves and it runs in place; that naming asymmetry is
    #       intentional — don't "fix" it into the alternation.
    #   (The styleguide is excluded — it may legitimately live in the repo as a design ref.)
    tracked_kit=$(git -C "$ROOT" ls-files | grep -iE '(^|/)(claude-project-kickoff|claude-project-adoption|llm-wiki-kickoff|claude-audit-base|claude-eval-base|securing-claude-sessions|prd-template|readme-template)\.(md|sh)$|(^|/)evals-template/' || true)
    [ -n "$tracked_kit" ] && { warn "Harness Kit scaffolding committed — it's one-time; keep sources out of the repo (outputs persist, sources don't)"; echo "$tracked_kit" | sed 's/^/       /'; } \
                          || pass "no Harness Kit scaffolding committed"
    # Secret pre-commit hook actually enabled? (kickoff §1.3b) A tracked hooks/ dir only
    # fires once `core.hooksPath` is set (per-clone, can't travel in the repo) AND the hook
    # is executable ON DISK. Either missing = a silent no-op that LOOKS installed. WARN, not
    # FAIL: a fresh clone simply hasn't run the one-time setup yet — surface it, don't red it.
    if [ -n "$(git -C "$ROOT" ls-files hooks/ 2>/dev/null)" ]; then
        hookpath=$(git -C "$ROOT" config --get core.hooksPath || true)
        if [ -z "$hookpath" ]; then
            warn "tracked hooks/ but core.hooksPath unset — the hook is a silent no-op; run: git config core.hooksPath hooks (kickoff §1.3b)"
        elif [ -f "$ROOT/$hookpath/pre-commit" ] && [ ! -x "$ROOT/$hookpath/pre-commit" ]; then
            warn "pre-commit hook not executable on disk — git ignores it; run: git update-index --chmod=+x $hookpath/pre-commit && git checkout -- $hookpath/pre-commit (kickoff §1.3b)"
        else
            pass "git pre-commit hook enabled (core.hooksPath=$hookpath) and executable"
        fi
    fi
    dirty=$(git -C "$ROOT" status --porcelain | wc -l | tr -d ' ')
    [ "${dirty:-0}" -gt 40 ] && warn "large uncommitted tree ($dirty entries) — commit in logical units" \
                             || pass "working tree manageable ($dirty uncommitted)"
else
    echo "  ·  not a git repo — git hygiene skipped"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "HYGIENE / SIMPLICITY"
# Generic, stack-independent signals.
# ═══════════════════════════════════════════════════════════════════════════
# Debug noise (tune patterns to your language).
noise=$(grep -rnE 'console\.(log|debug)\(|^\s*print\(|fmt\.Print|dbg!\(|println!\(' "$SRC" 2>/dev/null \
        | grep -vE '/(tests?|scripts?)/' || true)
[ -n "$noise" ] && { warn "debug print/log statements — remove before shipping"; echo "$noise" | sed 's/^/       /'; } \
               || pass "no stray debug print/log"

todo=$(grep -rnE 'TODO|FIXME|HACK|XXX' "$SRC" 2>/dev/null | wc -l | tr -d ' ')
[ "${todo:-0}" -gt 0 ] && warn "$todo TODO/FIXME/HACK/XXX markers" || pass "no TODO/FIXME/HACK/XXX markers"

# Oversized files often mix concerns. Tune the threshold; exempt files that are
# large by nature (generated code, a single cohesive type/model module, or a
# single-responsibility data-access layer that deliberately holds all queries —
# splitting that one would violate "data access in one place"). Note "in one place"
# means one *layer*, which can legitimately be a package / several modules (e.g.
# transactional vs. reporting reads) — not necessarily one file; the invariant is
# "no raw queries leak outside the data layer," not "all queries live in one file."
big=0
while IFS= read -r f; do
    lines=$(wc -l < "$f" 2>/dev/null | tr -d ' ')
    [ "${lines:-0}" -gt 500 ] && { warn "$(basename "$f"): $lines lines — consider splitting by concern"; big=1; }
done < <(find "$SRC" -type f 2>/dev/null | grep -vE 'node_modules|/dist/|/build/|\.min\.' || true)
[ $big -eq 0 ] && pass "no oversized source files (>500 lines)"

# ═══════════════════════════════════════════════════════════════════════════
section "DESIGN SYSTEM (UI consistency — kickoff Principle 5)"
# Tokenized/templatized styling only STAYS DRY if drift is caught early. These flag raw
# style values that should be TOKENS / primitives instead. Stack-specific — tune the globs
# + patterns to your idiom (CSS, Tailwind classes, a theme object, …), or delete this whole
# section for a backend-only project. Defaults to WARN; promote to `fail` once the patterns
# are tuned to your codebase and you want the discipline enforced hard.
# ═══════════════════════════════════════════════════════════════════════════
if [ -z "$UI" ]; then
    echo "  ·  DESIGN SYSTEM not configured (set UI=… to enable; skip for backend-only)"
else
    # 1) Raw hex colours outside the tokens file → should reference a colour token.
    #    Exempts the tokens file (it defines them) + comment lines; annotate a deliberate
    #    one-off with a trailing  hex-ok  (mirror an abs-ok-style escape hatch).
    hexes=$(grep -rnE '#[0-9a-fA-F]{3,8}\b' "$UI" 2>/dev/null \
            | { [ -n "$TOKENS_FILE" ] && grep -vF "$TOKENS_FILE" || cat; } \
            | grep -vE 'hex-ok|^\s*[^:]+:[0-9]+:\s*(#|//|/\*|\*)' || true)
    [ -n "$hexes" ] && { warn "raw hex colour(s) outside the tokens file — use a colour token"; echo "$hexes" | sed 's/^/       /' | head -20; } \
                    || pass "no raw hex colours outside the tokens file"

    # 2) Off-scale spacing in inline styles → should come from the spacing scale / a layout
    #    primitive. EXAMPLE pattern is JS/JSX inline style (margin/padding = a px|rem literal);
    #    adapt to your stack (style="" attrs, styled-components, etc.). `var(`/token refs and
    #    a trailing  sp-ok  are exempt.
    spacing=$(grep -rnE '(margin|padding)[A-Za-z]*: *["'\''][0-9.]+(px|rem)' "$UI" 2>/dev/null \
              | grep -vE 'sp-ok|var\(' || true)
    [ -n "$spacing" ] && { warn "inline px/rem spacing — prefer a spacing token / layout primitive"; echo "$spacing" | sed 's/^/       /' | head -20; } \
                      || pass "no off-scale inline spacing"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "DEPENDENCIES (restraint — kickoff Principle 8)"
# Every dependency is permanent surface area. Surface the manifest + nudge toward
# pinned versions (pinning also makes offline/unattended runs robust — Part 3).
# Tune the unpinned-version check to your ecosystem before promoting it past a nudge.
# ═══════════════════════════════════════════════════════════════════════════
dep_mf=""
for mf in package.json requirements.txt pyproject.toml go.mod Cargo.toml Gemfile; do
    [ -f "$ROOT/$mf" ] && dep_mf="$mf" && break
done
if [ -z "$dep_mf" ]; then
    echo "  ·  no recognised dependency manifest found"
else
    pass "manifest: $dep_mf — add new deps deliberately (stdlib/existing first), pin versions"
    # TODO: enable an ecosystem-specific unpinned-version check, e.g.
    #   npm:  grep -E '"[^"]+": *"[\^~]'   package.json     → caret/tilde ranges, not pins
    #   pip:  grep -vE '==|^\s*(#|$)'      requirements.txt → lines without == are unpinned
fi

# ═══════════════════════════════════════════════════════════════════════════
section "DEPENDENCY VULNERABILITIES (known CVEs — kickoff §1.6)"
# The DEPENDENCIES section above nudges toward FEWER + PINNED deps. This is the other
# half of the same coin: a dependency you already use, correctly pinned, that has SINCE
# had a security hole PUBLISHED against it — the one a secret scan and a pin check both
# miss. We don't ship a CVE database or parse a tool's JSON into a bespoke report; we
# DETECT the ecosystem from its LOCKFILE (the resolved dependency tree a scanner needs —
# NOT the manifest the section above keys on), shell out to that ecosystem's OWN scanner,
# and let the tool's own severity gate decide. Gated at high/critical only, and a WARN not
# a FAIL — an upstream CVE the project hasn't patched yet shouldn't red the whole audit
# (tier-aware, like the evals/README presence checks; a Hardened-tier project may promote
# it to FAIL by swapping `warn` for `fail` in sca_scan).
#
# SKIPPED ≠ PASS (the load-bearing rule). A scan that COULD NOT run — no lockfile, scanner
# not installed, or no network to the advisory DB — prints a visible SKIPPED (the neutral
# `·` bullet: no PASS, no FAIL, no exit-code change) and moves on. Never a silent green,
# never a spurious FAIL. Same candor as the grep-limits note in INVARIANTS: this safeguard
# needs the ecosystem's own tool AND registry access — its absence is a STATED GAP, not a
# green light. It's also network-bound and slow, so it runs after `AUDIT_SKIP_SCA` is
# checked; set AUDIT_SKIP_SCA=1 to skip it for a fast local pass.
#
# Per-ecosystem caveats (honest limits): a few scanners have no clean high-only flag — or
# their invocation is version-specific (yarn CLASSIC `yarn audit` vs BERRY `yarn npm
# audit`; yarn classic's exit code is a severity BITMASK that ignores `--level`). Where
# that's so we WARN on ANY advisory (a conservative superset of high/critical) and say so.
# Tune each command to your toolchain; the SKIPPED-loud paths keep a mis-tuned command from
# ever reading as a false green.
# ═══════════════════════════════════════════════════════════════════════════
# SKIPPED ≠ PASS lives in this classifier. `command -v` gates 'scanner not installed'; exit 0
# is the ONLY pass; a NON-ZERO exit is split two ways — a network / advisory-DB failure is a
# loud SKIP (the scan could not run), anything else is the tool's own severity gate firing →
# WARN. The split is deliberately ASYMMETRIC: unknown-nonzero defaults to WARN, never SKIP,
# so a real finding can never hide behind a false "offline". The network regex stays TIGHT to
# infra-failure signatures — DNS, connection, and registry/advisory-DB HTTP errors (ENOTFOUND,
# getaddrinfo, "bad gateway", "audit endpoint returned an error", "couldn't fetch advisory
# database", …) — none of which appear in a scanner's FINDINGS report, so a real vuln can't be
# mistaken for "offline". Validated against real npm findings-vs-offline output; err toward a
# loud WARN over a quiet SKIP that swallows a vuln.
sca_scan() {  # sca_scan "<label>" "<scanner-binary>" "<command>"
    local label="$1" bin="$2" cmd="$3"
    local net_re='ENOTFOUND|EAI_AGAIN|ETIMEDOUT|ECONNREFUSED|ECONNRESET|ENETUNREACH|getaddrinfo|no such host|name or service not known|temporary failure in name resolution|could not resolve host|network request .*fail|max retries exceeded|failed to establish a new connection|connection (refused|timed out|reset)|dial tcp|unable to (connect|reach)|audit endpoint returned an error|endpoint returned an error|bad gateway|gateway time-?out|service unavailable|internal server error|too many requests|(error|unable|failed|could ?n.?t).{0,24}(fetch|updat|download|clon|refresh|reach).{0,24}(advisor|database|registr|index|git repo)'
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "  ·  $label — SKIPPED (scanner '$bin' not installed): a stated gap, not a pass; install it + re-run"
        return
    fi
    if eval "$cmd" >"$TMP/audit_sca.txt" 2>&1; then
        pass "$label — no high/critical advisories"
    elif grep -qiE "$net_re" "$TMP/audit_sca.txt"; then
        echo "  ·  $label — SKIPPED (offline / advisory DB unreachable): a stated gap, not a pass"
    else
        warn "$label — high/critical advisory reported; patch or upgrade the dep (a Hardened-tier project may promote this to FAIL)"
        sed 's/^/       /' "$TMP/audit_sca.txt" | tail -15
    fi
}

if [ -n "${AUDIT_SKIP_SCA:-}" ]; then
    echo "  ·  SKIPPED (AUDIT_SKIP_SCA set) — dependency-vulnerability scan disabled for this run"
else
    sca_ran=0
    # Detect EACH lockfile present (a polyglot repo may carry several — no `break`) and run
    # that ecosystem's scanner. Keyed on the LOCKFILE, not the manifest: a scanner needs the
    # resolved dependency tree. Paths are $ROOT-level by the template convention; adapt if a
    # lockfile lives in a subdir.
    if [ -f "$ROOT/package-lock.json" ]; then sca_ran=1
        sca_scan "npm audit (package-lock.json)" npm '(cd "$ROOT" && npm audit --audit-level=high)'
    fi
    if [ -f "$ROOT/yarn.lock" ]; then sca_ran=1
        # classic: `yarn audit --level high` (exit code ignores --level → may WARN on sub-high);
        # berry: swap to `yarn npm audit --severity high`.
        sca_scan "yarn audit (yarn.lock)" yarn '(cd "$ROOT" && yarn audit --level high)'
    fi
    if [ -f "$ROOT/pnpm-lock.yaml" ]; then sca_ran=1
        sca_scan "pnpm audit (pnpm-lock.yaml)" pnpm '(cd "$ROOT" && pnpm audit --audit-level high)'
    fi
    if [ -f "$ROOT/poetry.lock" ] || [ -f "$ROOT/Pipfile.lock" ] || [ -f "$ROOT/requirements.txt" ]; then sca_ran=1
        # pip-audit has no severity flag → WARNs on ANY advisory (conservative superset of high/critical).
        if [ -f "$ROOT/requirements.txt" ]; then
            sca_scan "pip-audit (requirements.txt)" pip-audit '(cd "$ROOT" && pip-audit -r requirements.txt)'
        else
            # HONEST LIMIT: with only poetry.lock / Pipfile.lock, bare pip-audit scans the ACTIVE
            # ENV, not the lockfile — a clean env then PASSes without ever reading the lock. That's a
            # weaker PASS than a lockfile scan. For a true lockfile scan, export it first, e.g.
            #   poetry export -f requirements.txt | pip-audit -r /dev/stdin   (or `pipenv requirements`).
            sca_scan "pip-audit (project env — NOT the lockfile; see note)" pip-audit '(cd "$ROOT" && pip-audit)'
        fi
    fi
    if [ -f "$ROOT/Cargo.lock" ]; then sca_ran=1
        # cargo-audit installs the `cargo-audit` binary (run as `cargo audit`); RustSec advisories are the gate.
        sca_scan "cargo audit (Cargo.lock)" cargo-audit '(cd "$ROOT" && cargo audit)'
    fi
    if [ -f "$ROOT/go.sum" ]; then sca_ran=1
        # govulncheck reports only REACHABLE vulns (call-graph aware) → low false-positive.
        sca_scan "govulncheck (go.sum)" govulncheck '(cd "$ROOT" && govulncheck ./...)'
    fi
    if [ -f "$ROOT/Gemfile.lock" ]; then sca_ran=1
        # needs a one-time `bundler-audit update` to fetch the ruby-advisory-db; a never-fetched db → SKIP.
        sca_scan "bundler-audit (Gemfile.lock)" bundler-audit '(cd "$ROOT" && bundler-audit check)'
    fi
    if [ -f "$ROOT/composer.lock" ]; then sca_ran=1
        # composer audit (2.4+) WARNs on any advisory; no clean high-only filter.
        sca_scan "composer audit (composer.lock)" composer '(cd "$ROOT" && composer audit)'
    fi
    [ "$sca_ran" -eq 0 ] && echo "  ·  SKIPPED (no lockfile found) — nothing to scan; not a pass (add a lockfile to enable)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "PORTABILITY"
# Two portability traps; both want a PROJECT-SPECIFIC guard (no generic check ships for #2,
# it depends on your stack):
#   1. Hardcoded absolute paths (checked below) — derive from a base/root instead.
#   2. Directory-listing-driven features (routes-from-files, a plugin/fixture loader, a
#      migrations dir) must filter to the EXPECTED type and skip dotfiles — OS/sync tools
#      inject sidecars (macOS .DS_Store / AppleDouble ._* , editor temp files) that become
#      phantom entries, and crossing OSes at transfer time can materialize them anew. Filter
#      defensively in the loader; strip at the transfer step; add a regression guard once hit.
# ═══════════════════════════════════════════════════════════════════════════
paths=$(grep -rnE '/Users/|/home/[a-z]|/volume[0-9]|C:\\\\Users' "$SRC" 2>/dev/null \
        | grep -vE '^\s*[^:]+:[0-9]+:\s*(#|//|\*)' || true)
[ -n "$paths" ] && { fail "hardcoded absolute path in source — derive from a base/root"; echo "$paths" | sed 's/^/       /'; } \
               || pass "no hardcoded absolute paths in source"

# ═══════════════════════════════════════════════════════════════════════════
section "REGRESSION GUARDS"
# Add ONE check here every time you fix a bug, so the same mistake cannot return.
# Name the bug + date; FAIL if the old pattern reappears. ANCHOR the guard to the file the fix
# lives in (kickoff §1.6) — a regression guard is exactly an "absent from that file" check, the
# rot-prone shape: rename the file and it passes green forever, protecting nothing. Example:
#   # [regression] token compared with == (not constant-time), fixed 2026-06-03; the fix put a
#   # compare_digest() in auth/tokens.py. Anchor to that file AND that symbol — if either is gone
#   # the guard is meaningless, so guarded() WARNs (rotted) instead of falsely passing green.
#   guarded "[regression] token compare is constant-time" "src/auth/tokens.py" "compare_digest" && {
#       unsafe=$(grep -rnE 'token[A-Za-z_]*\s*==|==\s*[A-Za-z_]*token' "$SRC/auth/tokens.py" 2>/dev/null | grep -vE 'compare_digest|# ok' || true)
#       [ -n "$unsafe" ] && { fail "[regression] token compared with == — must be constant-time (compare_digest)"; echo "$unsafe" | sed 's/^/       /'; } \
#                        || pass "[regression] token compare is constant-time"
#   }
# The one-line annotation above is all this script carries. The incident itself —
# symptom, root cause, the attempts that did NOT work, the fix — is a wiki incident
# page (llm-wiki-kickoff.md §2.4); that's where the highest-value anti-knowledge lives.
# ═══════════════════════════════════════════════════════════════════════════
pass "(no regression guards yet — add one each time you fix a bug)"

# ═══════════════════════════════════════════════════════════════════════════
section "SAFEGUARD SELF-CHECK (audit the audit — kickoff §1.6)"
# The audit's own safeguards are greps, and a grep rots SILENTLY. guarded() (top of this script)
# fixes each anchored guard per-check — a lost anchor WARNs instead of passing. THIS section is
# the roll-up: it verifies the audit's own guards haven't gone dead, mirroring the wiki's
# stale/coverage self-checks (llm-wiki-kickoff.md §4) pointed at this script instead of the wiki's
# pages. It reports on the anchored safeguards guarded() actually EXERCISED this run: it can emit
# the positive "N guards, all anchors resolve" that a per-guard warning can't, and it names the
# rotted ones together. WARN, tier-aware: a script with no anchored guards yet stays quiet (a `·`
# line), exactly like the evals/README presence checks.
#
# HONEST LIMIT (mirrors the INVARIANTS grep-limits note): STRUCTURAL rot only — it proves each
# anchor still EXISTS. It cannot prove the anchor still MEANS what the guard assumed (SEMANTIC rot:
# the file/symbol is still there but the code around it was refactored so the pattern no longer
# bites). That is a human read — a review / LLM-judge pass — not something a grep can settle. And a
# guard behind a disabled branch simply didn't run, so it isn't rolled up here until it's
# re-enabled (at which point guarded() flags it immediately, in place).
# ═══════════════════════════════════════════════════════════════════════════
if [ "$GUARDS_TOTAL" -eq 0 ]; then
    echo "  ·  no anchored safeguards exercised — wrap absence-in-a-file guards in 'guarded \"…\" \"<anchor>\" \"…\" && { … }' so a renamed anchor WARNs instead of passing green (kickoff §1.6)"
elif [ "$GUARDS_ROTTED" -gt 0 ]; then
    warn "audit-the-audit: $GUARDS_ROTTED of $GUARDS_TOTAL anchored safeguard(s) lost their anchor (see the ⚠ above) — re-point or retire; structural rot only, semantic drift is a human read:"
    echo "$GUARDS_ROTTED_LIST"
else
    pass "audit-the-audit: $GUARDS_TOTAL anchored safeguard(s), all anchors resolve (structural check only — semantic drift still needs a human read)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "DOCUMENTATION"
# ═══════════════════════════════════════════════════════════════════════════
[ -f "$ROOT/CLAUDE.md" ] && pass "CLAUDE.md present ($(wc -l < "$ROOT/CLAUDE.md" | tr -d ' ') lines)" \
                         || warn "CLAUDE.md missing — future sessions lack project context"
[ -f "$ROOT/README.md" ] && pass "README.md present" || warn "README.md missing — the human front door (kickoff §1.5c)"

# README freshness (self-improving — keeps the human README from silently drifting). If the
# README carries a one-line  <!-- reconcile-code: path1 path2 -->  anchor (kickoff readme-
# template.md), WARN when any of those paths has a commit NEWER than the README's last commit.
# Git-based, not mtime (a synced volume rewrites mtime). The discipline that keeps it quiet:
# update README.md in the SAME commit as the code it describes.
if [ -f "$ROOT/README.md" ] && git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    anchor=$(grep 'reconcile-code:' "$ROOT/README.md" 2>/dev/null | head -1 \
             | sed -E 's/.*reconcile-code:[[:space:]]*//; s/[[:space:]]*-->.*//')
    readme_epoch=$(git -C "$ROOT" log -1 --format=%ct -- README.md 2>/dev/null || echo 0)
    # only meaningful once the README is committed and the anchor holds real (existing) paths
    if [ -n "$anchor" ] && [ "${readme_epoch:-0}" -gt 0 ]; then
        stale=""
        for p in $anchor; do
            [ -e "$ROOT/$p" ] || continue   # skip un-filled placeholders / moved paths
            pe=$(git -C "$ROOT" log -1 --format=%ct -- "$p" 2>/dev/null || echo 0)
            [ "${pe:-0}" -gt "${readme_epoch:-0}" ] && stale="$stale $p"
        done
        [ -n "$stale" ] && warn "README may be stale — newer commits to:$stale — refresh README.md (+ its reconcile-code anchor)" \
                        || pass "README not behind its reconcile-code paths"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
section "BEHAVIORAL EVALS (the judgment verifier — see kickoff §1.6b)"
# Behavioral evals are saved tests for the agent's JUDGMENT (not the code): a task prompt +
# a grade (golden-output equality — preferred, deterministic; or a blunt LLM-judge rubric).
# They run at MAINTENANCE MOMENTS — a model upgrade, a big CLAUDE.md edit, a new skill — and
# cost tokens + shell out to a live model, so this is a PRESENCE/WIRING check ONLY, never an
# execution (the audit runs after every edit; evals must not). Unconditional WARN when absent
# — a throwaway is free to ignore it (that IS the tier-awareness; there is no tier flag here),
# exactly like the CLAUDE.md/README presence checks above. Seeded from the kit's
# claude-eval-base.sh → scripts/eval.sh and evals-template/ → evals/.
# ═══════════════════════════════════════════════════════════════════════════
n_evals=$(find "$ROOT/evals" -name '*.eval.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "${n_evals:-0}" -gt 0 ]; then
    pass "evals/ present ($n_evals .eval.md fixture(s)) — re-run at a model upgrade / big CLAUDE.md edit / new skill (kickoff §1.6b)"
    [ -f "$ROOT/scripts/eval.sh" ] && pass "eval runner wired (scripts/eval.sh)" \
                                   || warn "evals/ present but no scripts/eval.sh runner — copy claude-eval-base.sh → scripts/eval.sh (kickoff §1.6b)"
else
    warn "no behavioral evals — the judgment verifier that catches agent regressions at a model / CLAUDE.md / new-skill change; seed evals/ + scripts/eval.sh from the kit (kickoff §1.6b)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "KNOWLEDGE WIKI (if set up — see llm-wiki-kickoff.md)"
# If the project keeps an LLM wiki (a reconcile-against-code knowledge base), lint
# it here so broken wikilinks / missing code paths / orphans surface in the audit.
# Set WIKI_LINT_CMD above to enable; extend with the wiki's coverage/gaps commands.
# ═══════════════════════════════════════════════════════════════════════════
if [ -z "$WIKI_LINT_CMD" ]; then
    echo "  ·  no wiki lint configured (set WIKI_LINT_CMD=… to enable)"
else
    run_tool "wiki lint" "(cd \"$ROOT\" && $WIKI_LINT_CMD)"
fi

# ═══════════════════════════════════════════════════════════════════════════
section "SUMMARY"
# ═══════════════════════════════════════════════════════════════════════════
echo
printf "  PASS: %-4s  WARN: %-4s  FAIL: %s\n" "$PASS" "$WARN" "$FAIL"
echo
if   [ $FAIL -gt 0 ]; then echo "  RESULT: FAIL — fix all ✗ items"
elif [ $WARN -gt 0 ]; then echo "  RESULT: WARN — review ⚠ items"
else echo "  RESULT: CLEAN ✓"; fi
echo
echo "  This template ships mostly empty on purpose. Its worth grows as you encode"
echo "  this project's invariants (from CLAUDE.md/spec) and add a regression guard"
echo "  for every bug you fix. Also ask Claude for a judgment review of what greps"
echo "  can't see, and periodically re-review this script's own checks for accuracy."
echo
exit $overall

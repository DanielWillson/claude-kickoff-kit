#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Code-health audit — BASE TEMPLATE (stack-agnostic). Part of the Kickoff Kit
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
# Three starter examples (adapt paths and patterns to your project):
#
# 1. Pure-function layer guard — a module declared pure (no I/O, no DB, no network)
#    must not import from impure layers. Catches mixed-concern creep before it spreads.
#   impure=$(grep -rnE 'import (db|requests|subprocess|httpx|urllib)' "$SRC/yourapp/pure_module.py" 2>/dev/null || true)
#   [ -n "$impure" ] && { fail "pure module imports from I/O layer — violates pure-function contract"; echo "$impure" | sed 's/^/       /'; } \
#                    || pass "pure module has no I/O imports"
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
#   readback=$(grep -rnE 'FROM\s+your_log_table|SELECT.*your_log_table' "$SRC/yourapp/engine.py" 2>/dev/null || true)
#   [ -n "$readback" ] && { fail "engine reads from its own diagnostic log — feedback loop"; echo "$readback" | sed 's/^/       /'; } \
#                      || pass "diagnostic log is write-only from the engine"
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
    # Kickoff Kit scaffolding is ONE-TIME: its OUTPUTS persist (CLAUDE.md, this script, wiki/,
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
    [ -n "$tracked_kit" ] && { warn "Kickoff Kit scaffolding committed — it's one-time; keep sources out of the repo (outputs persist, sources don't)"; echo "$tracked_kit" | sed 's/^/       /'; } \
                          || pass "no Kickoff Kit scaffolding committed"
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
# Name the bug + date; FAIL if the old pattern reappears. Example:
#   # [regression] token compared with == (not timing-safe), fixed 2026-06-03
#   grep -rq 'compare_digest\|hash_equals' "$SRC" && pass "[regression] timing-safe compare" \
#       || fail "[regression] token compare must be timing-safe"
# The one-line annotation above is all this script carries. The incident itself —
# symptom, root cause, the attempts that did NOT work, the fix — is a wiki incident
# page (llm-wiki-kickoff.md §2.4); that's where the highest-value anti-knowledge lives.
# ═══════════════════════════════════════════════════════════════════════════
pass "(no regression guards yet — add one each time you fix a bug)"

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
section "BEHAVIORAL EVALS (the judgment sensor — see kickoff §1.6b)"
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
    warn "no behavioral evals — the judgment sensor that catches agent regressions at a model / CLAUDE.md / new-skill change; seed evals/ + scripts/eval.sh from the kit (kickoff §1.6b)"
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

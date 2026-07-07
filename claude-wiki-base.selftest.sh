#!/usr/bin/env bash
# claude-wiki-base.selftest.sh — regression self-test for claude-wiki-base.py.
#
# The kit's own doctrine, aimed at its newest verifier: prove each check FIRES on a
# deliberately-broken fixture, and that a clean fixture passes — a checker whose FAIL
# path was never exercised reads as protection while protecting nothing (§1.6 item H;
# the eval-runner selftest is the precedent). Deterministic, no live model, no network.
# Run from anywhere: bash claude-wiki-base.selftest.sh   (CI runs it on push/PR.)
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ENGINE="$HERE/claude-wiki-base.py"
FIX="${TMPDIR:-/tmp}/wiki-base-selftest.$$"
PASS=0; FAIL=0

t() { # t <name> <want_exit> <want_grep|-> <args...>
    local name="$1" want_exit="$2" want_grep="$3"; shift 3
    local out rc
    out="$(cd "$FIX" && WIKI_DIR="$FIX/wiki" python3 "$ENGINE" "$@" 2>&1)"; rc=$?
    if [ "$rc" -ne "$want_exit" ]; then
        echo "  ✗  $name — exit $rc, wanted $want_exit"; echo "$out" | sed 's/^/       /'
        FAIL=$((FAIL+1)); return
    fi
    if [ "$want_grep" != "-" ] && ! grep -qF -- "$want_grep" <<<"$out"; then
        echo "  ✗  $name — output lacks: $want_grep"; echo "$out" | sed 's/^/       /'
        FAIL=$((FAIL+1)); return
    fi
    echo "  ✓  $name"; PASS=$((PASS+1))
}

page() { # page <relpath> <code-list> <extra-frontmatter> <body>
    mkdir -p "$FIX/wiki/$(dirname "$1")"
    printf -- '---\ntitle: "%s"\ntype: architecture\nstatus: current\nupdated: 2026-07-01\n%bcode: [%s]\nrelated: []\nsummary: "a page"\n---\n\n%s\n' \
        "$(basename "$1" .md)" "$3" "$2" "$4" > "$FIX/wiki/$1"
}

# ── build the CLEAN fixture ──────────────────────────────────────────────────
mkdir -p "$FIX/wiki/architecture" "$FIX/src"
cd "$FIX" && git init -q . && git config user.email t@t && git config user.name t
echo "def main(): pass" > src/app.py
echo "def util(): pass" > src/util.py
page "architecture/app-core.md"  "src/app.py" "" "Core. See [[sync-flow]]."
page "architecture/sync-flow.md" "src/app.py" "" "Sync. See [[app-core]]."
printf '# Wiki index\n\ncurated intro line (must survive index regeneration)\n' > wiki/index.md
printf '# SCHEMA\nconventions live here\n' > wiki/SCHEMA.md
printf '# Log\n\n## [2026-07-01] reconcile | seeded\nnot a parseable header line\n' > wiki/log.md
printf '.last-reconcile\n__pycache__/\n' > .gitignore
git add -A && git commit -qm seed

t "clean fixture lints (exit 0)"                 0 "0 error(s)" lint
t "index regenerates + preserves curated intro"  0 "regenerated" index
grep -q "curated intro line" wiki/index.md && { echo "  ✓  curated intro survived"; PASS=$((PASS+1)); } \
    || { echo "  ✗  curated intro lost"; FAIL=$((FAIL+1)); }
t "index is idempotent on second run"            0 "already current" index
t "metrics runs; malformed log line tolerated"   0 "ops/month" metrics
t "gaps: clean fixture has zero markers"         0 "0 marker(s)" gaps

# ── reconcile: uncommitted code edit flags the page + surfaces the neighbour ─
git add wiki/index.md && git commit -qm idx
echo "def main(): return 1" > src/app.py
t "reconcile flags page on uncommitted code edit" 0 "app-core.md" reconcile
git checkout -q -- src/app.py

# ── now break things, one at a time, and assert each check FIRES ─────────────
page "architecture/broken-link.md" "src/app.py" "" "See [[no-such-page]]."
t "lint fails on a broken wikilink"              1 "broken wikilink" lint
rm "$FIX/wiki/architecture/broken-link.md"

page "architecture/ghost-code.md" "src/deleted.py" "" "Anchored to [[app-core]]. Nothing."
t "lint fails on a missing code: path"           1 "does not exist" lint
rm "$FIX/wiki/architecture/ghost-code.md"

page "architecture/bad-status.md" "src/app.py" "" "Links [[app-core]]."
sed -i.bak 's/status: current/status: wibble/' "$FIX/wiki/architecture/bad-status.md" && rm -f "$FIX"/wiki/architecture/*.bak
t "lint fails on a bad status enum"              1 "not in" lint
rm "$FIX/wiki/architecture/bad-status.md"

page "architecture/no-fm.md" "" "" "x"
printf 'no frontmatter at all\n' > "$FIX/wiki/architecture/no-fm.md"
t "lint fails on missing frontmatter"            1 "no frontmatter" lint
rm "$FIX/wiki/architecture/no-fm.md"

page "architecture/lonely.md" "src/app.py" "" "Nobody links me, and I link no one."
t "lint warns on an orphan page"                 0 "orphan" lint
rm "$FIX/wiki/architecture/lonely.md"

printf '# Tensions\n\n## T-001 — [open] X vs Y\n- Surfaced: 2020-01-01\n' > wiki/tensions.md
t "lint warns on an aged [open] tension"         0 "needs a human ruling" lint
rm wiki/tensions.md

page "architecture/old-claim.md" "" "verified: 2020-01-01\n" "A no-code page. See [[app-core]]."
t "stale flags an expired verified: clock"       0 "re-read or re-affirm" stale
rm "$FIX/wiki/architecture/old-claim.md"

page "architecture/unclockable.md" "" "" "No code, no verified. See [[app-core]]."
t "stale flags a no-code page with no verified:" 0 "invisible to the freshness engine" stale
rm "$FIX/wiki/architecture/unclockable.md"

page "architecture/gappy.md" "src/app.py" "" "See [[app-core]].
> ⚠️ GAP: overlap window undocumented
> ⚠️ UNVERIFIED: confirm on device
\`\`\`
> ⚠️ GAP: this one is inside a code fence and must NOT be counted
\`\`\`"
t "gaps finds markers, skipping code fences"     0 "2 marker(s)" gaps
rm "$FIX/wiki/architecture/gappy.md"

t "coverage lists the undocumented source file"  0 "src/util.py" coverage
t "unknown subcommand → usage, exit 2"           2 "Subcommands" wibble

echo
echo "wiki-base selftest: $PASS passed, $FAIL failed"
rm -rf "$FIX"
[ "$FAIL" -eq 0 ]

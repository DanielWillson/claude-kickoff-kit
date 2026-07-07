#!/usr/bin/env python3
"""claude-wiki-base.py — the LLM wiki's maintenance engine (llm-wiki-kickoff.md §4).

SEED IT LIKE THE AUDIT: copy this file into the project as  wiki/wiki.py  (the path the
audit's WIKI_LINT_CMD example already names), then adapt the CONFIG block to the project.
Stdlib-only on purpose (kickoff Principle 8) — it runs anywhere the project runs.

Subcommands (each earned its place — the spec is llm-wiki-kickoff.md §4):
    lint                  frontmatter valid · every [[link]] resolves · code: paths exist ·
                          orphan floor · oversize advisory · open-tension age warn
    index                 regenerate the auto-catalog block of index.md from frontmatter
    reconcile [RANGE] [--diff]
                          pages whose code: files changed — committed since the last run
                          (marker file) AND uncommitted (git diff HEAD) — plus each flagged
                          page's linked-but-unflagged neighbours (§2.9)
    stale                 pages whose updated: predates the last commit touching their code:,
                          pages with uncommitted code: edits, and no-code: pages whose
                          verified: clock has run out (§2.1a)
    coverage              source files under the code dirs that no page documents (advisory)
    gaps                  every GAP / UNVERIFIED / CONFLICT marker across the wiki
    metrics               snapshot (pages by type/status, oversize, markers, stale) +
                          best-effort log.md op cadence (defensive; never crashes)

Design rules inherited from the guide, enforced here:
  - FAIL LOUD: a check that cannot run reports UNCHECKED (an error), never a silent pass.
  - Content-based change detection (git), never mtime (§4 boxed note).
  - lint never rewrites content; index touches ONLY its marked block.
  - Exit codes: 0 = clean (warnings allowed) · 1 = errors/UNCHECKED · 2 = usage.
Wire a new subcommand in all four spots or it drifts: DISPATCH, USAGE (this docstring),
the SCHEMA.md maintenance table, and the audit/command prose.
"""

import os
import re
import sys
import subprocess
import datetime
from collections import defaultdict

# ── CONFIG — adapt per project ───────────────────────────────────────────────
WIKI_DIR = os.environ.get("WIKI_DIR", os.path.dirname(os.path.abspath(__file__)))
EXEMPT = {"SCHEMA.md", "index.md", "log.md", "tensions.md"}  # frontmatter-exempt (§3);
#                                             still valid wikilink targets (§6 pitfalls)
REQUIRED_FIELDS = ["title", "type", "status", "updated", "code", "related", "summary"]
STATUS_ENUM = {"current", "planned", "superseded", "historical"}
OVERSIZE_LINES = 200          # soft split advisory, not a rule (§2.5)
TENSION_MAX_AGE_DAYS = 30     # warn on [open] tensions older than this (§2.10)
VERIFIED_MAX_AGE_DAYS = int(os.environ.get("WIKI_VERIFIED_MAX_AGE_DAYS", "180"))  # §2.1a
MARKER_FILE = ".last-reconcile"   # gitignore this (holds the last-processed commit SHA)
INDEX_BEGIN = "<!-- BEGIN AUTO-INDEX (wiki.py index — do not hand-edit this block) -->"
INDEX_END = "<!-- END AUTO-INDEX -->"
# ─────────────────────────────────────────────────────────────────────────────

OK, WARNSIGN, ERRSIGN, DOT = "  ✓ ", "  ⚠ ", "  ✗ ", "  · "


def repo_root():
    try:
        out = subprocess.run(["git", "rev-parse", "--show-toplevel"], cwd=WIKI_DIR,
                             capture_output=True, text=True, timeout=15)
        if out.returncode == 0:
            return out.stdout.strip()
    except (OSError, subprocess.TimeoutExpired):
        pass
    return os.path.dirname(WIKI_DIR)  # graceful non-git fallback; git cmds degrade loud


ROOT = None  # resolved in main()


def git(*args, ok_fail=False):
    """Run git at ROOT. Returns stdout, or None on failure (callers must degrade LOUD)."""
    try:
        out = subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True,
                             timeout=30)
    except (OSError, subprocess.TimeoutExpired):
        return None
    if out.returncode != 0:
        return "" if ok_fail else None
    return out.stdout


def wiki_pages():
    """All .md files under WIKI_DIR (recursive), path relative to WIKI_DIR."""
    pages = []
    for dirpath, dirnames, filenames in os.walk(WIKI_DIR):
        dirnames[:] = [d for d in dirnames if not d.startswith(".") and d != "__pycache__"]
        for f in sorted(filenames):
            if f.endswith(".md"):
                pages.append(os.path.relpath(os.path.join(dirpath, f), WIKI_DIR))
    return pages


def slug_of(relpath):
    return os.path.splitext(os.path.basename(relpath))[0]


def read(relpath):
    with open(os.path.join(WIKI_DIR, relpath), encoding="utf-8") as fh:
        return fh.read()


def parse_frontmatter(text):
    """Hand-rolled lean-YAML parser for the §3 schema (stdlib-only — no pyyaml).
    Returns (dict, error_string). Supports scalars, quoted strings, [inline, lists]."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None, "no frontmatter block"
    fm, end = {}, None
    for i, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end = i
            break
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$", line)
        if not m:
            return None, f"unparseable frontmatter line {i + 1}: {line.strip()!r}"
        key, raw = m.group(1), m.group(2).strip()
        if raw.startswith("[") and raw.endswith("]"):
            inner = raw[1:-1].strip()
            items = [x.strip().strip("\"'") for x in inner.split(",")] if inner else []
            fm[key] = [x for x in items if x]
        else:
            fm[key] = raw.strip("\"'")
    if end is None:
        return None, "frontmatter never closed (missing second ---)"
    return fm, None


def strip_code(text):
    """Remove fenced blocks and inline code spans so a page documenting the syntax
    isn't self-flagged (§6 linter gotchas)."""
    text = re.sub(r"^(```|~~~).*?^\1\s*$", "", text, flags=re.M | re.S)
    return re.sub(r"`[^`\n]*`", "", text)


def wikilinks(text):
    """[[slug]] / [[slug|label]] / [[slug#anchor]] → slug list, code stripped first."""
    return [re.split(r"[|#]", m)[0].strip()
            for m in re.findall(r"\[\[([^\]]+)\]\]", strip_code(text))]


def parse_date(s):
    try:
        return datetime.date.fromisoformat(str(s).strip())
    except (ValueError, TypeError):
        return None


def load_corpus():
    """Read every page once: {rel: {text, fm, fm_err, links, exempt}} + slug map."""
    corpus, slugs = {}, defaultdict(list)
    errors = []
    for rel in wiki_pages():
        try:
            text = read(rel)
        except OSError as e:
            errors.append(f"UNCHECKED: cannot read {rel}: {e}")
            continue
        exempt = os.path.basename(rel) in EXEMPT
        fm, fm_err = (None, None) if exempt else parse_frontmatter(text)
        corpus[rel] = {"text": text, "fm": fm or {}, "fm_err": fm_err,
                       "links": wikilinks(text), "exempt": exempt}
        slugs[slug_of(rel)].append(rel)
    return corpus, slugs, errors


def code_paths(fm):
    return [p for p in fm.get("code", []) if p]


def pages_for_files(corpus, changed):
    """Map changed repo-relative files → wiki pages whose code: covers them
    (exact match, or the code: entry is a directory prefix)."""
    hits = defaultdict(set)
    for rel, page in corpus.items():
        if page["exempt"]:
            continue
        for cp in code_paths(page["fm"]):
            norm = cp.rstrip("/")
            for ch in changed:
                if ch == norm or ch.startswith(norm + "/"):
                    hits[rel].add(ch)
    return hits


def changed_uncommitted():
    out = git("diff", "--name-only", "HEAD")
    return None if out is None else [l for l in out.splitlines() if l.strip()]


# ── lint ─────────────────────────────────────────────────────────────────────
def cmd_lint(_args):
    corpus, slugs, errors = load_corpus()
    warns = []
    if not corpus:
        print(ERRSIGN + "UNCHECKED: no pages found under " + WIKI_DIR)
        return 1

    for slug, rels in sorted(slugs.items()):
        if len(rels) > 1:
            warns.append(f"ambiguous slug [[{slug}]] — {len(rels)} files share the basename: "
                         + ", ".join(rels))

    inbound = defaultdict(set)
    for rel, page in sorted(corpus.items()):
        if page["fm_err"]:
            errors.append(f"{rel}: {page['fm_err']}")
        elif not page["exempt"]:
            fm = page["fm"]
            missing = [f for f in REQUIRED_FIELDS if f not in fm]
            if missing:
                errors.append(f"{rel}: missing frontmatter field(s): {', '.join(missing)}")
            if "status" in fm and fm["status"] not in STATUS_ENUM:
                errors.append(f"{rel}: status {fm['status']!r} not in "
                              + "|".join(sorted(STATUS_ENUM)))
            if "updated" in fm and parse_date(fm["updated"]) is None:
                errors.append(f"{rel}: updated: {fm['updated']!r} is not YYYY-MM-DD")
            if "verified" in fm and parse_date(fm["verified"]) is None:
                errors.append(f"{rel}: verified: {fm['verified']!r} is not YYYY-MM-DD")
            for cp in code_paths(fm):
                if not os.path.exists(os.path.join(ROOT, cp.rstrip("/"))):
                    errors.append(f"{rel}: code: path does not exist: {cp}")
        for l in page["links"]:
            if l in slugs:
                if slug_of(rel) != l:
                    inbound[l].add(rel)
            else:
                errors.append(f"{rel}: broken wikilink [[{l}]] — no such page")
        n = page["text"].count("\n") + 1
        if n > OVERSIZE_LINES and not page["exempt"]:
            warns.append(f"{rel}: {n} lines — over the ~{OVERSIZE_LINES}-line split "
                         "advisory (§2.5; length alone is not a reason to split)")

    for rel, page in sorted(corpus.items()):
        if page["exempt"] or rel == "index.md":
            continue
        if not inbound.get(slug_of(rel)):
            warns.append(f"{rel}: orphan — no other page links [[{slug_of(rel)}]] "
                         "(the inline link graph is the navigation surface, §2.6)")

    tensions = os.path.join(WIKI_DIR, "tensions.md")
    if os.path.exists(tensions):
        today = datetime.date.today()
        for m in re.finditer(r"^##\s+(T-\d+)\s+—\s+\[open\].*?$([\s\S]*?)(?=^##\s|\Z)",
                             read("tensions.md"), flags=re.M):
            dm = re.search(r"Surfaced:\s*(\d{4}-\d{2}-\d{2})", m.group(2))
            d = parse_date(dm.group(1)) if dm else None
            if d is None:
                warns.append(f"tensions.md {m.group(1)}: [open] with no parseable "
                             "'Surfaced: YYYY-MM-DD' date — age can't be clocked")
            elif (today - d).days > TENSION_MAX_AGE_DAYS:
                warns.append(f"tensions.md {m.group(1)}: [open] for {(today - d).days}d "
                             f"(> {TENSION_MAX_AGE_DAYS}d) — needs a human ruling (§2.10)")

    for e in errors:
        print(ERRSIGN + e)
    for w in warns:
        print(WARNSIGN + w)
    print(f"\nlint: {len(corpus)} pages, {len(errors)} error(s), {len(warns)} warning(s)")
    return 1 if errors else 0


# ── index ────────────────────────────────────────────────────────────────────
def cmd_index(_args):
    corpus, _slugs, errors = load_corpus()
    if errors:
        for e in errors:
            print(ERRSIGN + e)
        return 1
    by_type = defaultdict(list)
    for rel, page in corpus.items():
        if page["exempt"] or page["fm_err"]:
            continue
        fm = page["fm"]
        by_type[fm.get("type", "untyped")].append(
            (slug_of(rel), fm.get("summary", ""), fm.get("status", "")))
    lines = [INDEX_BEGIN]
    for t in sorted(by_type):
        lines.append(f"\n### {t}\n")
        for slug, summary, status in sorted(by_type[t]):
            suffix = f" *({status})*" if status and status != "current" else ""
            lines.append(f"- [[{slug}]] — {summary}{suffix}")
    lines.append("\n" + INDEX_END)
    block = "\n".join(lines)

    idx = os.path.join(WIKI_DIR, "index.md")
    old = read("index.md") if os.path.exists(idx) else "# Wiki index\n"
    if INDEX_BEGIN in old and INDEX_END in old:
        pre = old.split(INDEX_BEGIN)[0]
        post = old.split(INDEX_END, 1)[1]
        new = pre + block + post
    else:
        new = old.rstrip() + "\n\n" + block + "\n"
    if new != old:
        with open(idx, "w", encoding="utf-8") as fh:
            fh.write(new)
        print(OK + f"index.md regenerated ({sum(len(v) for v in by_type.values())} pages)")
    else:
        print(DOT + "index.md already current")
    return 0


# ── reconcile ────────────────────────────────────────────────────────────────
def cmd_reconcile(args):
    show_diff = "--diff" in args
    args = [a for a in args if a != "--diff"]
    corpus, slugs, errors = load_corpus()
    for e in errors:
        print(ERRSIGN + e)

    marker = os.path.join(WIKI_DIR, MARKER_FILE)
    rng = None
    if args:
        rng = args[0]
    elif os.path.exists(marker):
        last = open(marker, encoding="utf-8").read().strip()
        if last and git("cat-file", "-e", last + "^{commit}") is not None:
            rng = f"{last}..HEAD"
        else:
            print(WARNSIGN + f"last-reconcile SHA {last[:12]} unreachable (rebase?) — "
                             "falling back to uncommitted changes only")
    else:
        print(DOT + "no last-reconcile marker and no range given — "
                    "checking uncommitted changes only (marker will be written)")

    changed = set()
    if rng:
        out = git("diff", "--name-only", rng)
        if out is None:
            print(ERRSIGN + f"UNCHECKED: git diff {rng} failed — cannot reconcile the "
                            "committed range")
            return 1
        changed.update(l for l in out.splitlines() if l.strip())
    unc = changed_uncommitted()
    if unc is None:
        print(ERRSIGN + "UNCHECKED: git unavailable — reconcile needs a git repo "
                        "(content-based detection, never mtime; §4)")
        return 1
    changed.update(unc)

    hits = pages_for_files(corpus, changed)
    if not hits:
        print(OK + f"no page's code: touched by {len(changed)} changed file(s)")
    flagged = set(hits)
    for rel in sorted(hits):
        print(f"\n{WARNSIGN}{rel} — re-read against:")
        for f in sorted(hits[rel]):
            print(f"      {f}")
            if show_diff and rng:
                d = git("diff", rng, "--", f, ok_fail=True) or ""
                du = git("diff", "HEAD", "--", f, ok_fail=True) or ""
                for hunk in (d + du).splitlines():
                    print("        " + hunk)
        # §2.9: linked-but-unflagged neighbours — the cross-page consistency net
        page = corpus[rel]
        me = slug_of(rel)
        neigh = {l for l in page["links"] if l in slugs} | {
            slug_of(r) for r, p in corpus.items() if me in p["links"]}
        neigh = {n for n in neigh
                 if n != me and not any(slug_of(fr) == n for fr in flagged)}
        if neigh:
            print("      also re-read for consistency (linked neighbours, §2.9): "
                  + ", ".join(f"[[{n}]]" for n in sorted(neigh)))

    head = git("rev-parse", "HEAD")
    if head:
        with open(marker, "w", encoding="utf-8") as fh:
            fh.write(head.strip() + "\n")
        print(f"\n{DOT}marker updated → {head.strip()[:12]} "
              f"(keep {MARKER_FILE} gitignored)")
    print(f"reconcile: {len(hits)} page(s) flagged from {len(changed)} changed file(s)")
    return 0


# ── stale ────────────────────────────────────────────────────────────────────
def cmd_stale(_args):
    corpus, _slugs, errors = load_corpus()
    for e in errors:
        print(ERRSIGN + e)
    unc = changed_uncommitted()
    if unc is None:
        print(ERRSIGN + "UNCHECKED: git unavailable — stale needs a git repo")
        return 1
    today = datetime.date.today()
    n = 0
    for rel, page in sorted(corpus.items()):
        if page["exempt"] or page["fm_err"]:
            continue
        fm = page["fm"]
        cps = code_paths(fm)
        if cps:
            upd = parse_date(fm.get("updated", ""))
            last = git("log", "-1", "--format=%cs", "--", *[c.rstrip("/") for c in cps])
            lastd = parse_date(last.strip()) if last else None
            if upd and lastd and lastd > upd:
                print(WARNSIGN + f"{rel}: updated {upd} but its code: last changed {lastd}")
                n += 1
            dirty = [c for c in cps
                     if any(u == c.rstrip("/") or u.startswith(c.rstrip("/") + "/")
                            for u in unc)]
            if dirty:
                print(WARNSIGN + f"{rel}: uncommitted edits to its code: "
                                 f"({', '.join(sorted(dirty))})")
                n += 1
        else:
            ver = parse_date(fm.get("verified", ""))
            if ver is None:
                print(WARNSIGN + f"{rel}: empty code: and no verified: date — invisible "
                                 "to the freshness engine; add one (§2.1a)")
                n += 1
            elif (today - ver).days > VERIFIED_MAX_AGE_DAYS:
                print(WARNSIGN + f"{rel}: verified {ver} — "
                                 f"{(today - ver).days}d ago (> {VERIFIED_MAX_AGE_DAYS}d) "
                                 "— re-read or re-affirm (§2.1a)")
                n += 1
    print(f"\nstale: {n} finding(s) across {len(corpus)} pages")
    return 0


# ── coverage ─────────────────────────────────────────────────────────────────
def cmd_coverage(_args):
    corpus, _slugs, _errors = load_corpus()
    documented, dirs = set(), set()
    for page in corpus.values():
        for cp in code_paths(page["fm"]):
            norm = cp.rstrip("/")
            documented.add(norm)
            top = norm.split("/")[0]
            if top and top != os.path.basename(WIKI_DIR):
                dirs.add(top)
    if not dirs:
        print(DOT + "no code: entries anywhere yet — nothing to measure coverage against")
        return 0
    tracked = git("ls-files", "--", *sorted(dirs))
    if tracked is None:
        print(ERRSIGN + "UNCHECKED: git ls-files failed — coverage needs a git repo")
        return 1
    undocumented = []
    for f in tracked.splitlines():
        f = f.strip()
        if not f:
            continue
        if f in documented or any(f.startswith(d + "/") for d in documented):
            continue
        undocumented.append(f)
    for f in undocumented:
        print(DOT + f)
    print(f"\ncoverage (advisory, never a failure — §4): {len(undocumented)} "
          f"file(s) under {'/'.join(sorted(dirs))} not in any page's code:")
    return 0


# ── gaps ─────────────────────────────────────────────────────────────────────
def cmd_gaps(_args):
    corpus, _slugs, _errors = load_corpus()
    pat = re.compile(r"⚠️?\s*(GAP|UNVERIFIED|CONFLICT)\s*:?\s*(.*)")
    n = 0
    for rel, page in sorted(corpus.items()):
        for i, line in enumerate(strip_code(page["text"]).splitlines(), 1):
            m = pat.search(line)
            if m:
                print(f"{WARNSIGN}{rel}:{i}  {m.group(1)}: {m.group(2).strip()}")
                n += 1
    print(f"\ngaps: {n} marker(s) — each is a findable unknown, not a defect (§3)")
    return 0


# ── metrics ──────────────────────────────────────────────────────────────────
def cmd_metrics(_args):
    corpus, _slugs, _errors = load_corpus()
    by_type, by_status, oversize, markers = defaultdict(int), defaultdict(int), 0, 0
    pat = re.compile(r"⚠️?\s*(GAP|UNVERIFIED|CONFLICT)\s*:")
    for rel, page in corpus.items():
        if not page["exempt"] and not page["fm_err"]:
            by_type[page["fm"].get("type", "untyped")] += 1
            by_status[page["fm"].get("status", "?")] += 1
        if page["text"].count("\n") + 1 > OVERSIZE_LINES and not page["exempt"]:
            oversize += 1
        markers += len(pat.findall(strip_code(page["text"])))
    print(f"pages: {len(corpus)}  |  by type: "
          + ", ".join(f"{t}={n}" for t, n in sorted(by_type.items())))
    print(f"by status: " + ", ".join(f"{s}={n}" for s, n in sorted(by_status.items()))
          + f"  |  oversize: {oversize}  |  markers: {markers}")
    log = os.path.join(WIKI_DIR, "log.md")
    if os.path.exists(log):
        cadence = defaultdict(int)
        for line in read("log.md").splitlines():   # defensive: never crash on a bad line
            m = re.match(r"^##\s*\[(\d{4})-(\d{2})-\d{2}\]\s*(\S+)", line)
            if m:
                cadence[f"{m.group(1)}-{m.group(2)}"] += 1
        if cadence:
            print("log.md ops/month: "
                  + ", ".join(f"{k}={v}" for k, v in sorted(cadence.items())))
        else:
            print(DOT + "log.md present but no parseable '## [date] op' headers yet")
    return 0


# ── dispatch ─────────────────────────────────────────────────────────────────
DISPATCH = {"lint": cmd_lint, "index": cmd_index, "reconcile": cmd_reconcile,
            "stale": cmd_stale, "coverage": cmd_coverage, "gaps": cmd_gaps,
            "metrics": cmd_metrics}


def main():
    global ROOT
    if len(sys.argv) < 2 or sys.argv[1] in {"-h", "--help"} \
            or sys.argv[1] not in DISPATCH:
        print(__doc__.strip())
        return 0 if len(sys.argv) >= 2 and sys.argv[1] in {"-h", "--help"} else 2
    ROOT = repo_root()
    try:
        return DISPATCH[sys.argv[1]](sys.argv[2:])
    except Exception as e:  # fail LOUD, never a silent pass (§4)
        print(ERRSIGN + f"UNCHECKED: {sys.argv[1]} crashed: {type(e).__name__}: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())

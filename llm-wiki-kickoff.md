# LLM Wiki — Kick-off Guide (project-agnostic)

> **Hand this to a fresh Claude session at the start of a new project.** It
> teaches the "LLM wiki" pattern — a self-maintaining, agent-readable knowledge
> base — and how to build one well. It is distilled from real builds, including
> the mistakes. Read it end-to-end before proposing a wiki for the project, then
> adapt (don't copy) the specifics to the project at hand.
>
> *Part of the **Kickoff Kit*** — with the project-kickoff guide
> (`claude-project-kickoff.md`), the audit base (`claude-audit-base.sh`), and your
> per-project styleguide + PRD.

---

## 1. What this is, and when to use it

An **LLM wiki** (Karpathy's pattern, April 2026) is a small set of human-readable,
interlinked Markdown pages that an LLM **compiles once** and then **maintains with
targeted edits** — instead of re-deriving how the project works from raw material
on every question. The wiki is the working reference; the raw material (for a
codebase, *the code itself*) is the ground truth it's reconciled against.

- **Not RAG.** No embeddings, no vector DB, no retrieval index. The corpus is
  small enough to navigate by an `index.md` + `[[wikilinks]]`.
- **Use it when** stable, bounded, interconnected knowledge matters more than
  large-scale retrieval: a codebase, a product, a domain an agent works in
  repeatedly. **Don't bother** for a throwaway task or a corpus of thousands of
  unrelated documents. At small scale the **incident/decision layer still matters**,
  but detailed **commit bodies + audit safeguards** are an acceptable substitute
  for a full wiki — graduate to the wiki when the project outgrows them.

The bet that makes it work: **maintenance is what kills human wikis** (bookkeeping
grows faster than value). An LLM removes that friction — it can touch fifteen
cross-referenced pages in one pass without fatigue. So the whole design is about
making maintenance cheap and automatic. A wiki that isn't maintained is *worse*
than no wiki: agents will confidently act on stale pages.

*In the field's emerging vocabulary,* this wiki is the project's **"system of record"**
(OpenAI's term for the repository's knowledge base) — but a stronger one. A static `docs/` tree
is a system of record by assertion only: trusted on faith, it rots silently.
Reconcile-against-ground-truth (§2.1) is what earns the name — staleness is *detected against
the code*, not assumed away.

---

## 2. The principles that actually matter

These are the load-bearing ideas. The structure in §3 is downstream of these.

### 2.1 Reconcile against ground truth, not against itself
This is the single most important principle, and the answer to the hardest problem
in agent memory: **a high-confidence fact that has silently gone stale.** Generic
agent-memory can't solve this (no source of truth to check against). A codebase
wiki *can*: **the code is the ground truth.** Every maintenance pass checks page
claims against the actual source files — never just against the wiki's own internal
consistency (self-consistency lets a hallucination reinforce itself).

Make it mechanical: give each page a `code:` frontmatter list of the source files
it documents. Then a maintenance pass maps *changed files → pages to revisit*, a
linter flags any page pointing at a file that no longer exists, and a coverage
check flags any source file no page documents (§4).

**No source file to reconcile against? Anchor to an extracted schema.** §2.1 assumes a
page's subsystem *is* readable source in the repo. Some aren't — a no-code backend
(Bubble/Retool), a managed database, a SaaS admin, a dependency you only have as an
OpenAPI/GraphQL schema — so there's nothing for `reconcile` to diff and the page rots
invisibly (the §2.1a case in a different disguise). Bring it back under the engine:
**extract the system's schema — definitions only, never rows (that would dump real/PII
data) — into a committed file** (e.g. `wiki/_schema/bubble.data-model.json`) and put *that
file* in the page's `code:`. The existing reconcile diff then fires on it exactly as for
source — no new drift machinery. When you regenerate the artifact, **overwrite only a marked
auto-generated block and never the human-authored semantics** (the §2.3 "regenerate the
mechanical part, preserve the corrections" rule — same discipline as the auto-`index`
block): a new field appears with a `⚠️ GAP: needs-semantics` marker; a renamed field shows
up as a remove + an add and is flagged for a human, never silently re-mapped.

### 2.1a When there is no `code:` to reconcile against — the `verified:` clock
§2.1's engine assumes a page has source files to diff against. The kit's *highest-value*
pages often don't: a **decision** ("we chose Postgres over Mongo because…"), an
**incident**'s root-cause narrative, an external/vendor fact — their truth lives in a human
judgment or an outside source, not in a file `reconcile` can read. A page with empty `code:`
is invisible to the entire freshness engine (`reconcile`, `stale`, `coverage` all key on
`code:`), so it ages **silently** — the one outcome §1 calls "worse than no wiki."

The only honest freshness signal such a page has is **when a human last confirmed it still
holds.** Give it one:
- Add a **`verified: YYYY-MM-DD`** frontmatter field, distinct from `updated:` (`updated` =
  last *written*; `verified` = last *confirmed true*). For a code-anchored page a clean
  `reconcile` pass *is* verification, so the two move together; for a no-`code:` page only a
  human — or a re-read of the cited source — can move `verified`.
- Extend **`stale`** to also flag any page whose `code:` is empty and whose `verified:` date
  is older than a single age threshold (start ~180 days; tighten per-page only for a
  genuinely volatile fact). This is a **clock**, not a diff: "these un-reconcilable pages
  haven't been re-confirmed in six months — re-read or re-affirm."
- **Trust is the pair, never either half.** A `verified` date on a page nobody re-read is a
  lie; a re-read that doesn't bump the date is invisible. Move `verified` only on a real
  re-confirmation.

This is the kit eating its own cooking: the kit's *own* wiki already carries a `verified:`
date on every external-source claim for exactly this reason — this subsection promotes that
dogfooded discipline into the pattern the kit ships. Keep it **scoped to no-`code:` pages**;
don't tax every code-anchored page with a second date it doesn't need. (And stop there: a
page's *epistemic class* — extracted vs inferred vs contested — is the source-trust-tier
machinery §2.8/§7 decline for the LLM-only default; at most an optional free-text
`provenance:` note, never a required enum.)

### 2.2 Three memory layers — and which one owns project knowledge
Three places a fact can live; the difference is *when it's in context* and *whether
it travels with the repo*:

- **Contract file** (`CLAUDE.md` / `AGENTS.md`) — **always loaded** every session,
  in the repo. Holds invariants/guardrails + pointers into the wiki. Keep it lean.
- **Wiki** — **read-on-demand** (only if the agent follows a pointer), in the repo,
  versioned, shared, reconcile-checked. Holds the depth, history, rationale.
- **Harness memory store** (`~/.claude` — both the **project-scoped** auto-memory *and* the
  **global / user** `~/.claude/CLAUDE.md`) — machine-local, *not in the repo*, not shared,
  not versioned, not reconciled. **It is the wrong home for project knowledge**, and the
  **global layer is the worst**: a project-specific fact there loads into every *other*
  project and pollutes it. Keep only **user-level** facts in memory (working style,
  preferences); the global layer takes cross-project user prefs only, never anything
  project-specific. If project knowledge is trapped in the store, migrate it into the repo
  (wiki for depth, contract for invariants) and leave behind at most a one-line pointer.

*Name the seam, because modern harness memory looks like this wiki:* current auto-memory
stores are themselves wiki-shaped — an index file plus small, cross-linked notes. The
pattern is not what separates them. Two properties do: **transport** (memory is
machine-local; the wiki rides the repo to every clone, tool, and teammate) and — the
load-bearing one — **ground truth** (memory has nothing to reconcile against, so a stale
memory goes wrong *invisibly*; a wiki page names its `code:` and goes stale *visibly*,
§2.1). Same shape; only one has a truth loop. That, not the format, is why project facts
belong here and not there.

These are the *memory* layers. A fourth, non-memory layer — the **audit** (a grep script,
kickoff §1.6) — *enforces* invariants rather than storing knowledge. The full routing
across all four is the kickoff's one-liner: guardrail → contract, machine-check → audit,
full story → wiki.

*The axis in the field's words:* **"anything [the agent] cannot access in context at runtime
does not exist"** (OpenAI). That is exactly why placement is decided by *when a fact is loaded*,
not merely where it's written — the lean contract carries pointers, with the depth one pointer
(and one read) away.

> ⚠️ **The trap that will bite you (contract trim):** "this fact is also in the
> wiki" does **not** make it safe to delete from the contract file — deletion
> changes *when the fact is in context*. Demote a one-line guardrail to a wiki page
> and an agent who doesn't open that page reintroduces the exact bug the line
> prevented. **Test each line: "would an agent who never opens the wiki reintroduce
> a bug or violate a constraint without this line?" If yes, it stays in the
> contract — even though it's duplicated in the wiki.** Cut only the
> *rationale / how-it-works narrative*; the invariants stay. After trimming, diff
> the contract and re-ask that question of every removed line.

### 2.3 Synthesize, don't extract. Maintain, don't regenerate.
Write each page the way someone who understands the subsystem would explain it —
in your own words, organized for a reader. Never stitch quotes. On later passes,
make **targeted** edits; never rewrite a page wholesale (that destroys accumulated
nuance and human corrections).

Corollary for migrations: **don't bulk-rewrite existing good docs into the wiki.**
*Moving/relocating* a file is fine; *regenerating* its content is the anti-pattern
(it duplicates, drifts, front-loads risk). It's the **index + wikilinks** that make
pages "first-class and organized together," not the folder they sit in.

### 2.4 Capture the WHY and the failures — that's the highest-value content
The contract holds the *resulting* invariant. The code holds the *what*. The thing
nothing else captures — and the reason the wiki earns its keep — is the **temporal
failure/decision history**: *"we tried X, it didn't work because Y; the fix was Z;
we chose A over B because…"* That anti-knowledge stops an agent re-walking a dead
end. Make it first-class:
- **Incidents:** symptom → root cause → ❌ attempts that did NOT work and why →
  fix / current status.
- **Decisions:** context → options → decision → why (ADR-lite).

### 2.5 One concept per page — and the test for when to split
Bias toward decomposition: a hub page + small, sharply-scoped pages beats one page
that does everything. A reader should understand a concept from its page alone.

- **Soft line cap (~200 lines)** as a *split advisory*, not a hard rule. Length
  alone is not a reason to split.
- **The `code:`-test for splitting (the sharp heuristic):** a page is genuinely two
  concepts — split it — only if the proposed sub-page would have a *substantially
  different* `code:` set. If extracting a "sub-concept" would re-list almost the
  **same** source files as the parent, it's *woven through the same code*, not
  separable — keep it as one page. (Real examples: a native-wrapper layer with its
  own separate codebase split cleanly into its own page; a "co-buy" sub-feature
  whose logic was interleaved across the *same* files as the rest of the feature
  correctly stayed put — splitting it would have duplicated the parent's `code:`.)
- Be **conservative**: a thorough single-concept page that runs long is fine —
  justify it and move on. Over-splitting fragments a coherent spec.

### 2.6 Link concepts inline, not just in frontmatter
When a page mentions another documented concept in prose, link it inline as
`[[slug]]` the first time. The dense inline link graph is how an agent navigates;
a `related:` list alone is too coarse. (The linter's orphan check enforces a floor;
inline linking is the real navigation surface.)

### 2.7 Git hygiene is part of the system, not a side concern
The wiki lives in the repo and its reconcile engine keys off git, so repo hygiene
and the wiki reinforce each other. Bake hygiene into the same three places:
- **Contract file:** commit at verified checkpoints (not one giant mixed commit),
  branch before large/risky changes, **never commit secrets**, and never blind
  `git add -A` over a tree with unrelated in-flight work (stage explicit paths).
- **Audit:** a hard gate that *fails* if any secret file is tracked + warns on an
  oversize uncommitted tree. (Gitignore the secrets first; a commit step should
  abort if a secret is staged.)
- **Unattended pass:** a **scoped** auto-commit — stage the wiki's **markdown only**,
  never `git add -A` *or even a bare `git add wiki/`*, so the daily job can't sweep up
  unrelated, secret, or stray work. Once `wiki/` holds the maintenance script (§4), a bare
  `git add wiki/` would also stage its build artifacts (`wiki/__pycache__/*.pyc`) — and
  leaning on `.gitignore` to exclude them is the deny-list-of-the-known trap this guide
  warns against. Stage with a markdown-scoped pathspec instead — `git add --
  ':(glob)wiki/**/*.md'` — then commit **explicitly**. (Bonus: the glob also catches the
  **new** `.md` pages a pass routinely creates — stubs, seeded incidents — which `git add
  -u` would silently skip, since it stages only *modified tracked* files.) Commit the wiki's
  markdown yourself and leave a clean tree for the kickoff Stop hook — the hook is the
  fallback, not the committer (kickoff Principle 4).

### 2.8 Be explicit about the safety model
Decide up front who can change the wiki and what the check is:
- **LLM-only, no human review** (a good default for a solo/agent-driven project):
  **git is the audit trail and the undo**, and **reconcile-against-code (§2.1) is
  the correctness check.** Say this in the schema so no one adds review ceremony.
- **Human-reviewed** (regulated/multi-author): PR gates, a
  `status: needs_review→approved` lifecycle, source-trust tiers. Heavier; only pay
  for it if the domain demands it. Don't half-build the heavy version for a light
  project.

### 2.9 One claim, one home — guard cross-page drift
Reconcile (§2.1) checks each page against its **code**, never against **other pages**.
So a claim *restated* in two pages can drift: each stays "correct against its own code,"
yet they contradict each other and the linter passes both. (Real case: a runbook
paraphrased a stale *derived* doc and contradicted the page that cited the *primary*
source — both green.) Three cheap layers, no embeddings:
- **Prevent (load-bearing):** a finding/decision's conclusion lives on **one** page —
  the one whose `code:` ties to its evidence. Other pages **link `[[it]]` + a one-line
  upshot; never re-derive the reasoning.** A paraphrase drifts; a link forces re-reading
  the source. And **cite the primary source, not a derived summary** (a test *result*
  over a *recommendation* about it — the derived doc goes stale first); put the source
  doc — even a non-code `.md` — in the page's `code:` so reconcile flags it on change.
- **Detect (deterministic, ~free):** have `reconcile` print each flagged page's
  **linked-but-unflagged neighbours** ("also re-read for consistency"). The wikilink
  graph is already computed; a link is a deliberate claim of coherence, so this is
  near-zero-false-positive — and, unlike lexical/shingle matching, it still fires after
  one copy has fully inverted (the contradiction is *structural*, not lexical).
- **Judge (LLM, in the maintenance pass):** when a flagged page surfaces a linked
  neighbour, co-read both against their `code:` sources and fix any
  same-claim/opposite-verdict contradiction — judged against the code, never
  wiki-internal consistency (§2.1 still holds).

Resist the tempting fourth layer — an n-gram/shingle "duplicate-paragraph" linter. It
only nudges at *creation* time and **fails once a copy inverts** (lexical distance
grows), and a noisy version becomes the check everyone ignores. The convention prevents,
the link-graph detects, the LLM judges.

**At a small navigable corpus, stop there.** *(Optional — large, multi-author corpus
only.)* The link-graph detector finds drift between pages that *link*; it is blind to two
pages that state the same fact, never link, and silently diverge. That case barely arises
while one-claim-one-home holds, and §7's "resist the extra machinery" stands. If a corpus
grows large and multi-author enough that the convention slips, a periodic **corpus-wide
scan** is the backstop: a cheap deterministic pass shortlists page *pairs* by shared rare
terms / shared value tokens (numbers, dates, dollars) / overlapping scope, excluding
already-linked pairs; then an LLM co-reads each shortlisted pair against its sources and
files a `tensions.md` row only after an adversarial pass tries to *refute* the contradiction.
Be honest about what this buys: it is **not** the shingle linter above (that dies the moment
a copy inverts) — but the shortlist doesn't magically survive inversion either (a number
corrected $400→$250 leaves no shared value token), so it leans on shared *topic* terms plus
the LLM stage. It beats the shingle linter by adding **judgment and cost**, not a cleverer
string match. Sample the *excluded* pairs occasionally to confirm the filter isn't dropping
real conflicts. Reach for this only once the corpus has outgrown "navigable by eye" — never
at kickoff.

### 2.10 When the agent can't adjudicate — a conflicts register
§2.9 settles drift the agent *can* resolve. But some conflicts it has **no basis to rank**:
two sources of equal standing disagree, or a wiki page contradicts a `CLAUDE.md` invariant
and which is right is a human call. The failure mode is the agent **quietly picking a
winner** (the more recent, or the more confident-sounding one) and burying the conflict —
precisely how a confident-wrong fact enters and then propagates.

Give it a standing home: a **`tensions.md`** register (append-only like `log.md`,
frontmatter-exempt) — one row per unresolved conflict:

```
## T-003 — [open] SREC cap: architecture/pricing says $X, runbooks/payout says $Y
- Both pages cite a source; neither is obviously primary.
- Surfaced: 2026-07-03 (reconcile linked-neighbour check, §2.9)
- Needs a human ruling. Until then BOTH pages carry `⚠️ CONFLICT: see T-003`.
```

The convention in one line: **the agent surfaces; a human disposes.** On a conflict it
can't settle, the agent files a `T-###` row, drops a `⚠️ CONFLICT: T-###` marker on *both*
pages (so no reader trusts a contested claim unaware), and **never picks a winner.** A
human's ruling resolves the row (`[resolved]` + the decision) and becomes the ground truth
both pages are corrected to. Have `lint` **warn** on any `[open]` row past an age threshold
(e.g. 30 days) so conflicts can't rot in the register the way they'd rot buried in the
pages. This is the mirror image of the `GAP`/`UNVERIFIED` markers (§3): those mean "a hole
we know about"; `CONFLICT` means "two answers we can't yet choose between" — both make an
unknown *findable* instead of letting the agent paper over it. Cost: one markdown file and a
marker, against the costliest documented failure in the field (contradictory context).

---

## 3. Structure

```
wiki/
  SCHEMA.md      ← the contract for the wiki itself (conventions; the most important file)
  index.md       ← catalog/TOC (auto-generated list + a short curated intro)
  log.md         ← append-only operation log; entries headed `## [YYYY-MM-DD] <op> | …`
                   (the `[date] op` header is machine-parseable for the metrics ledger, §4)
  tensions.md    ← standing register of contradictions the agent can't adjudicate (§2.10);
                   append-only, frontmatter-exempt. Omit until the first conflict is filed.
  <type>/        ← pages grouped by type
```

**Page types** (adapt to the project). For a codebase, these earned their place:
`architecture/` (how a subsystem works), `features/` (capability + goals),
`incidents/` (the failure spine, §2.4), `decisions/` (the why), `runbooks/`
(operational how-to). A non-code project may use entirely different types — the
taxonomy is yours; one concept per page is the constant.

**Frontmatter** (lean; no review fields unless you chose the human-reviewed model):
```yaml
---
title: "..."
type: architecture            # one of your declared types
status: current               # current | planned | superseded | historical (content state, not review)
updated: YYYY-MM-DD
verified: YYYY-MM-DD           # OPTIONAL — for pages with empty code: only; last human confirmation (≠ updated:)
code: [path/to/source.ext]    # the real files this page documents — the reconcile lynchpin (§2.1)
related: ["[[other-slug]]"]   # quoted wikilinks; bare [[x]] breaks YAML
summary: "one-line catalog blurb"
---
```

**Markers (surfaced by the `gaps` command, §4)** — make holes and unconfirmed
claims findable:
- `> ⚠️ GAP: <what's missing>` — a coverage hole.
- `> ⚠️ UNVERIFIED: <what needs live/on-device confirmation>` — a claim not yet
  checked against reality. The next session that *can* verify works this list.
- `> ⚠️ CONFLICT: T-### — <the two readings>` — a contested claim the agent could **not**
  adjudicate; filed in `tensions.md` (§2.10), awaiting a human ruling. Never resolve it
  silently.

**Wikilinks:** `[[slug]]` = filename without extension; resolves by basename
anywhere under `wiki/` (folder-independent).

**SCHEMA.md** is the wiki's own operating contract — page types, frontmatter spec,
the marker conventions, the safety model, the maintenance commands, and
(explicitly) what the wiki *deliberately doesn't do*. The agent reads it first
every time it touches the wiki. Keep it in sync with what the linter enforces.

---

## 4. The maintenance engine (how it self-improves)

Build a small **stdlib-only** script (no third-party deps, so it runs anywhere the
project runs — mind the target runtime's language version). Subcommands that earned
their place:

- **`lint`** — frontmatter valid; every `[[link]]` resolves; no orphan pages; every
  `code:` path exists. Reports + a non-failing **oversize advisory** (pages over
  the soft cap). Also **warns** on any `tensions.md` row left `[open]` past its age
  threshold (§2.10). Never rewrites content.
- **`index`** — regenerate the catalog block of `index.md` from frontmatter.
- **`reconcile [range] [--diff]`** — pages whose `code:` files changed, both
  **committed** since the last run *and* **uncommitted** (see the boxed note).
  `--diff` prints the actual diff hunks per file so the agent edits with the change
  in hand (don't make it re-derive what changed). **Also surfaces each flagged page's
  linked-but-unflagged neighbours** (§2.9) — the cross-page consistency net — so a
  shared claim's *other* home gets a look even when its own `code:` didn't change.
- **`stale`** — pages whose `updated` predates the last *commit* touching their
  `code:`, plus pages with *uncommitted* edits to their `code:`. **Also flags any page with
  an empty `code:` whose `verified:` date exceeds the age threshold** (§2.1a) — the only
  staleness signal available when there's nothing to diff against.
- **`coverage`** — source files (in the code dirs) not in any page's `code:` —
  i.e. undocumented subsystems. **Advisory** (many small utils legitimately need no
  page); a list + count, never a failure, or it drowns in noise.
- **`gaps`** — every `GAP` / `UNVERIFIED` marker across the wiki (what's missing or
  needs confirming). Scan *all* pages incl. frontmatter-exempt ones; strip
  code-spans so a page documenting the marker syntax isn't flagged.
- **`metrics`** — a reliability ledger: a *snapshot* (pages by type/status,
  oversize, marker count, stale count) — the robust, useful-now part — plus
  best-effort `log.md` op-cadence over time (defensive parsing; never crash on a
  malformed line).

> ⚠️ **Catch uncommitted edits with `git diff HEAD`, not mtime.** The obvious gap
> is that a commit-range `reconcile` only fires *after* a commit — and many
> developers commit rarely. **Solve it by also diffing the working tree:**
> `git diff --name-only HEAD` lists every tracked file changed but not yet
> committed. Union it with the committed range. This is strictly better than
> filesystem mtime: it's **content-based** (no false positives from `touch`,
> `chmod`, checkout, or a file-sync re-write), and code dirs often aren't even on
> the synced volume mtime would react to. Drop mtime; it's the wrong tool here.
> Untracked new files won't show in `git diff HEAD` — correct: that's exactly what
> `coverage` is for.

Two triggers:
- **Automatic (the engine):** fold a wiki pass into whatever already runs
  unattended (a daily scheduled session, a CI step): `reconcile --diff` → edit
  flagged pages → **judge cross-page consistency** on the linked-neighbour pairs
  reconcile surfaced (§2.9: co-read both against their `code:`, fix any
  same-claim/opposite-verdict drift) → `lint`/`stale`/`coverage`/`gaps` and fix → a
  **rotating completeness spot-check** (read the 1–2 oldest-`updated` pages against their
  `code:`; stub a page for any load-bearing undocumented source; resolve a `gaps`
  item) → `index` → append a `## [date] reconcile | …` line to `log.md` → a
  **scoped commit** of the wiki dir (§2.7). The completeness spot-check is the
  cheap, recurring "what's stale/missing/unverified?" critic — schedule it, don't
  rely on doing it once.
- **On-demand:** a `/wiki` command — "update the wiki for what I just changed" —
  same logic, run at the end of a work session (the most reliable trigger, since
  the agent knows exactly what it touched).

**Both triggers above are *this agent's*** — neither fires for a different LLM/tool, a
human's plain `git commit`, or CI. So treat the **scheduled reconcile as the *primary*
freshness mechanism** (zero per-commit friction) — but honestly: it's *rule*-portable, not
free. Something must *run* it (a scheduled session, a CI job), the same runtime-coupling
that makes auto-commit non-portable (kickoff Principle 4). For a project where someone
*other* than this agent commits (kickoff Intake Q6), the tool-agnostic enforcement is **the
audit run in CI** — `bash scripts/audit.sh` WARNs on doc drift and FAILs on a tracked secret
*no matter who committed* — plus the optional secret pre-commit hook for *local* commits
(kickoff §1.3b). A git pre-commit hook does **not** run in CI; don't rely on one there. And
**match the check to your go-live boundary** (kickoff Intake Q7): if you ship by
tar/rsync/file-write/auto-merge rather than `git commit`, a commit-time check can't guard
what ships — put the freshness/secret check at the **deploy step or on the schedule**.

**The human `README` is a sibling reconcile target.** A project's `README.md` (kickoff
`readme-template.md`) makes the same code-coupled claims a wiki page does — how to run it,
what it does — so it drifts the same way. It carries a one-line `<!-- reconcile-code: … -->`
anchor instead of `code:` frontmatter; the **audit warns** when those paths out-run it
(kickoff §1.6), and the reconcile/`/wiki` pass should **refresh it alongside the pages**.
Same principle as §2.1 — one doc that happens to live at repo root and address humans.

**Persist a last-reconcile marker** (a gitignored file holding the last-processed
commit SHA) so a skipped day doesn't lose a window; fall back gracefully if the SHA
is unreachable (e.g. after a rebase).

**Wire each new subcommand in all four spots or it drifts:** the dispatch, the
usage/docstring, the SCHEMA maintenance table, and the command/audit prose.

**Where a rule is both written down and machine-checked, the check is the source of truth
and the prose is a labelled mirror.** `SCHEMA.md` *describes* the frontmatter enums; the
linter *enforces* them — so when they disagree the linter wins and `SCHEMA.md` is what gets
corrected (sync both in the same edit). And make the linter **fail loud**: if it can't
actually run a check — a missing YAML parser, an unreadable file — it must report that check
as **`UNCHECKED` (an error), never a silent pass.** A green run that quietly skipped half its
checks is the same "a control present but inert reads as protection" trap the kit warns about
for security guards, here aimed at the wiki's own validator: doc-vs-enforcement drift must
never hide behind a passing check.

---

## 5. How to build it (for a cold session)

1. **Inventory what exists.** List current docs, the contract file, and any
   machine-local memory store (§2.2). The wiki's job is the *connective tissue +
   the missing layers* (usually failure/decision history), **not** a parallel copy.
2. **Decide the boundaries.** Always-loaded invariant (contract) vs. on-demand
   depth (wiki) vs. user-level pref (memory). Choose the safety model (§2.8). Write
   both in SCHEMA.md.
3. **Scaffold:** `wiki/` dirs, `SCHEMA.md`, `index.md`, `log.md`, the maintenance
   script. Add the **read-and-write mandate** to the contract: *"before working on a
   subsystem, read `wiki/index.md` + the relevant page; project knowledge goes in the repo
   (wiki + contract), never in machine-local `~/.claude` memory."* Both halves are
   load-bearing — without the read half the wiki is a write-only sink; without the
   anti-memory half the next session quietly routes new knowledge back into the
   machine-local store and the wiki starves.
4. **Migrate / seed (move, don't rewrite — §2.3).** Relocate existing design docs
   in, add frontmatter, convert cross-refs to `[[wikilinks]]`. Migrate project
   knowledge *out* of the machine-local memory store into the repo. Seed 2–3 *real*
   incident/decision pages from genuine history (git log, changelogs, memory) so
   the pattern is visible. Don't backfill everything — let it accrue.
5. **Fix every reference to moved files** (§6 — this is where people slip).
6. **Wire the engine (§4)** and **git hygiene (§2.7)**: the automatic pass, the
   on-demand command, the audit gates, the scoped daily commit, gitignored secrets.
7. **Verify (right-sized — §6), then commit.**

---

## 6. Hard-won pitfalls (these actually happened)

- **Breadcrumb migration misses file types.** Moving a doc leaves stale references
  to its old path in code comments, configs, READMEs, *and other docs* — in
  heterogeneous forms (`docs/X`, `../docs/X`, bare `X`). A pass that scanned only
  `.md/.php/.py/.sh/.json/.js` **missed `.ts`, `.swift`, `.mjs`**. Enumerate
  reference sites across *all* text file types, and **verify with a grep that
  ignores `.gitignore`** (default ripgrep honors it and hides hits). Re-grep every
  old path after the move; target zero.
- **Right-size verification to the risk.** For **lossy/risky operations**
  (migrations, contract trims, page splits) run an **independent adversarial pass**
  that did *not* do the work, diffing against the source-of-record — it caught, in
  practice, an *inverted* status fact ("not built" when git showed it shipped),
  whole subsystems silently dropped behind a false "documented elsewhere" claim,
  and a stray generation artifact. For **small additive tool functions**, a single
  functional pass (run each subcommand + edge cases + compile-check) is enough —
  don't spin up a fan-out for six stdlib helpers. Match orchestration to risk; the
  failure mode of a migration is a silent drop that surfaces weeks later, so *that*
  is where the heavy verification goes.
- **Don't drop a guardrail from the always-loaded contract** just because it's now
  in the wiki (§2.2). Diff the contract line-by-line: "was this an invariant?"
- **Verify against the *live* source, not a stale snapshot/backup.** Memory and old
  docs are point-in-time; the code moved on. (One page faithfully reproduced a
  memory entry the code had already superseded; another said a feature was unbuilt
  when git history showed it shipped.)
- **A hand-maintained status/progress doc is the canonical rot.** A "what's built vs.
  not" file drifts to *misleading* fastest of all — it ends up marking shipped
  features "not built," so a reader trusts it and re-does done work or skips missing
  work. Either treat it as a wiki page with a `code:` set and reconcile it like any
  other (§2.1), or don't keep one — derive status from the test suite + `git log`,
  which can't lie about what exists.
- **Split conservatively — apply the `code:`-test (§2.5).** Length alone isn't a
  reason; if a sub-page would re-list the parent's `code:`, it's not separable.
- **Reconcile is file-level — confirm before editing.** A changed `code:` file
  flags its page, but maybe the part the page documents didn't change. Treat a flag
  as "review," not "rewrite"; confirm against the diff, then refresh `updated` or
  edit as warranted.
- **Two pages can each be "correct against their code" yet contradict each other.**
  Reconcile checks page-vs-code, never page-vs-page — so a claim *restated* in a
  second page drifts undetected, and lint passes both. It actually happened: one page
  paraphrased a stale *derived* doc (a recommendation) and flatly contradicted the
  page that cited the *primary* source (the result it was based on); both were green
  for days. The fix is §2.9 — state a claim **once** and link to it (don't restate),
  cite the **primary** source not a derived summary, and put that source doc in the
  page's `code:` so reconcile flags it. Detect the residue with reconcile's
  linked-neighbour surfacing; don't reach for a shingle/duplicate-text linter (it
  fails the moment one copy inverts).
- **Linter gotchas:** frontmatter-exempt pages (log/backlog/schema) must still be
  *valid wikilink targets* (other pages link to them); and strip `code spans`
  before scanning for links *or* markers, so a page documenting the syntax isn't
  self-flagged.
- **Never let auto-git-hygiene commit a secret.** Gitignore secret files; have the
  audit *fail* if one is tracked; have any commit step abort if a secret is staged;
  keep the unattended commit scoped to the wiki dir.
- **Editor/vault state churns — gitignore it.** If the wiki doubles as an Obsidian
  vault, ignore the per-user UI state (`**/.obsidian/workspace*.json`); keep the
  shareable vault config. (Gitignore patterns with an internal slash are anchored —
  use `**/` to match nested paths.)
- **The wiki must be *read*, or none of the maintenance matters.** The contract
  read-mandate (§5.3) creates the read path; an unread wiki is a write-only sink.
- **The auto-memory trap is set early and never announces itself (§2.2).** A project that
  starts without a wiki lets the machine-local store (e.g. `~/.claude` auto-memory) become
  the convenient default for project facts — incidents, decisions, rationale — none of
  which are in the repo, versioned, shared, or reconciled. *The signal to scaffold:* the
  store is accreting *project-specific* knowledge (how a subsystem works, what failed, why
  a decision was made). Migrate it into the wiki (depth/history) or the contract
  (invariants), leaving a one-line pointer; keep only *user-level* prefs there — and never
  a project-specific fact in the **global** `~/.claude/CLAUDE.md`, which would pollute every
  other project.
- **Critical mass is real.** Value compounds over weeks; early sessions feel like
  overhead. Don't judge it by the first run.

---

## 7. What to deliberately NOT do (for a small, navigable corpus)

Resist the heavier "agent-memory v2" machinery unless the project genuinely needs
it — it adds cost and failure surface without payoff at this scale:
- No embeddings / vector search / hybrid retrieval — navigate by index + links.
- No decay/forgetting curves, no confidence scores, no consolidation memory tiers.
- No knowledge-graph database — wikilinks are the graph.
- No human-review gates / source-trust tiers — *if* you chose the LLM-only model
  (§2.8); git + reconcile-against-code are the safety net.
- No mtime-based change detection — `git diff HEAD` is cleaner (§4).
- No **blocking** "doc-currency" pre-commit gate (block any commit that changes code
  without touching its wiki page). It's redundant with the scheduled reconcile, fires
  constantly on shared files listed in many pages' `code:`, and "a gate people disable is
  worse than no gate." If you want a commit-time doc check at all, make it *warn-only* (exit
  0, never blocks) — the durable freshness guarantee is the reconcile pass + the audit.
- No reliance on a **git hook for CI** — client-side hooks don't run there; the audit run as
  a pipeline step is the CI enforcer (§4; kickoff §1.3b).

Naming what you're omitting, in SCHEMA.md, is as valuable as what you include — it
stops the next session from "helpfully" adding it.

---

## 8. Example seed pages

Two shells illustrating the **decision** and **architecture** page types in practice.
Adapt the content to your project — the value is the format and the genuine knowledge
each carries, not these specific examples.

### Decision page — UTC vs. local time *(for any project with timestamped data)*

```yaml
---
title: "Time-zone convention"
type: decision
status: current
updated: YYYY-MM-DD
code: []   # add modules that handle timestamps
related: []
summary: "All timestamps stored and compared in UTC; local conversion at display boundaries only"
---
```

**Context.** Any application that stores or queries timestamps must decide: UTC or
local? The choice itself is largely arbitrary; consistency is not. Mixed naive/aware
datetimes are a latent bug that surfaces only for non-UTC users — a log entry at
23:00 local is attributed to the wrong day if compared naively against a UTC-stored
window.

**Options.**
- Store everything in UTC; convert to local only at the UI/API display boundary.
- Store local time with an explicit timezone offset alongside every timestamp.

**Decision.** UTC everywhere. Convert to local only at the display boundary.

**Why.** UTC is unambiguous, survives DST transitions and device moves, and matches
what most external data sources use natively. Storing local adds offset-drift risk
and complicates every cross-source comparison.

> ⚠️ UNVERIFIED: confirm every integrated data source's timestamp format against this
> contract before storing their values.

---

### Architecture page — sync cursor / retry pattern *(for any project with a polling sync)*

```yaml
---
title: "Sync cursor and retry pattern"
type: architecture
status: current
updated: YYYY-MM-DD
code: []   # add your sync module(s) and sync_state schema
related: []
summary: "Each endpoint owns its cursor; failure records without advancing it"
---
```

**The pattern.** Each sync endpoint tracks its own cursor (last successfully processed
date or offset) in a persistent `sync_state` store. On success: advance the cursor,
record `ok`. On failure: record `error` with context, but **do not advance the cursor**
and do not abort sibling endpoints.

**Why "failure is data, not a log line."** A log line disappears into stderr; a
`sync_state` row is queryable, surfaceable in the UI, and drives the next run's
backfill window automatically. A failed endpoint that doesn't advance its cursor is
retried on the next run without manual intervention.

**What not to do.**
- ❌ Abort the whole sync run on a single endpoint failure.
- ❌ Advance the cursor optimistically before confirming success.
- ❌ Log-and-swallow — failure state belongs in persistent storage, not just stderr.

**Invariant.** A missing day is not an error if the source buffers recent data — the
overlap window backfills gaps on the next run. Only a cursor advance on a failed call
loses a window permanently.

> ⚠️ GAP: document the overlap/backfill window size for each endpoint.

---

### Incident page — phantom entries from an unfiltered file scan *(the highest-value type, §2.4)*

```yaml
---
title: "Phantom routes from OS sidecar files"
type: incident
status: current
updated: YYYY-MM-DD
code: []   # the file-listing module + the transfer/deploy script
related: []
summary: "A directory-derived feature counted OS-generated sidecar files as real entries"
---
```

**Symptom.** The build emitted more entries than there were real source files (a route/page
count higher than the page count), and it only surfaced after a transfer to another host.

**Root cause.** A feature that derives behavior from a directory listing (routes, plugins,
fixtures) consumed *every* file in the dir — including OS-generated sidecars (macOS
`.DS_Store` / AppleDouble `._*`, editor temp files) that a cross-OS copy had materialized.

**❌ Attempts that did NOT work.**
- Deleting the sidecars by hand — they regenerate on the next sync/transfer.
- Adding them to `.gitignore` — they were created at *transfer/deploy* time, not in the
  repo, so ignoring them locally changed nothing.

**Fix / status.** Filter the listing defensively in the loader (keep only the expected
extension; skip dotfiles) **and** strip the artifacts at the transfer step — two guards,
because the artifact appears at two stages. Safeguarded in the audit.

> ⚠️ This is an *abstracted* example — write yours from a real incident, naming the actual
> files and the actual dead ends; the failed attempts are the highest-value part.

---

## 9. Starter checklist

- [ ] Inventoried existing docs / contract file / machine-local memory; identified the missing layer
- [ ] Chose the safety model (LLM-only vs human-reviewed) and the three memory boundaries; wrote both in SCHEMA.md
- [ ] Defined page types + lean frontmatter (incl. the `code:` reconcile field) + the GAP/UNVERIFIED/CONFLICT markers
- [ ] For no-`code:` pages: a `verified:` date + a `stale` age-check (§2.1a); a `tensions.md` register for contradictions the agent can't adjudicate (§2.10)
- [ ] Scaffolded `wiki/` + `SCHEMA.md` + `index.md` + `log.md` (parseable `## [date] op` headers) + maintenance script
- [ ] Maintenance script: lint, index, reconcile (committed **+ `git diff HEAD` uncommitted**, `--diff`), stale, coverage, gaps, metrics
- [ ] Added the read mandate to the contract; kept invariants there, moved depth to the wiki, migrated project knowledge out of machine-local memory
- [ ] Migrated by *moving* (not rewriting); fixed every old-path reference across **all** file types; re-grepped to zero
- [ ] Decomposed by the `code:`-test (conservative); densified inline `[[wikilinks]]`
- [ ] Seeded real incident/decision pages from actual history
- [ ] Wired the automatic pass (incl. a rotating completeness spot-check + scoped commit) + the on-demand command; each subcommand in all four spots
- [ ] Baked git hygiene into the contract + audit (secret-tracking gate) + the daily pass; gitignored secrets and editor state
- [ ] Verified right-sized (adversarial for migrations/trims/splits; functional pass for tooling); lint clean
- [ ] Committed (git = the audit trail)

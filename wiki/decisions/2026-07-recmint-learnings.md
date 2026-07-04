---
title: "Learnings from recmint-wiki — five drafted edits (proposed, not applied)"
type: decision
status: current
updated: 2026-07-03
verified: 2026-07-03
code: [../../llm-wiki-kickoff.md, ../../claude-project-kickoff.md, ../../claude-project-adoption.md]
related: ["[[2026-07-audit-pass]]", "[[SCHEMA]]"]
summary: "What the kit learned from the recmint-wiki production instance: five verified edits (freshness clock, conflicts register, class-level safety net, schema-anchoring, fail-loud validator) — APPLIED to the shipped guides 2026-07-03; this page is the reasoning record"
---

# Learnings from recmint-wiki → the Kickoff Kit

> **APPLICATION STATUS: APPLIED 2026-07-03.** All five edits are now in the shipped guides
> (see *Sequencing* for where each landed). This page is retained as the **reasoning record**
> — the both-sides analysis, the adversarial verdicts, and what was trimmed/rejected and why.
> The draft blocks below are what was applied; if a guide's wording later diverges from a
> block here, the *guide* is canonical and this record is what gets a note. Because this
> page's `code:` lists the three edited guides, editing them again will surface this page for
> a fresh look — the kit's own reconcile loop, pointed at its own decision history.

## Context — how these were derived

`../../recmint-wiki` is the **production instance** the kit's `llm-wiki-kickoff.md` was
distilled from: a self-maintaining, LLM-compiled knowledge base for a SREC/REC broker,
grown well past the kit's blueprint (13 codified skills, a read-only MCP query server, a
review-outcome ledger, a dozen `proposals/`). The question asked: *what has recmint grown
on its own that generalizes back into the kit?*

Method (2026-07-03, a 15-agent workflow, mirroring [[2026-07-audit-pass]]'s discipline):
1. **Coverage map** — four agents read the shipped kit files (`claude-project-kickoff.md`,
   `llm-wiki-kickoff.md`, adoption + README + LESSONS, the security docs) and recorded, with
   `file:line`, every concept the kit **already** teaches. The delta is the deliverable: no
   recommendation survives unless it names where the kit is silent.
2. **Pattern catalog** — four agents cataloged what recmint grew beyond the kit, tagging each
   pattern *code-anchored vs human-source-anchored* and flagging **shared DNA** (kit exports
   that flowed *into* recmint — its security stack, managed-settings, `securing-claude-sessions.md`
   — which we must **not** "discover" and recommend re-importing).
3. **Cluster → adversarial verify** — six candidate themes, each then handed to an independent
   skeptic agent told to *refute* it against the real kit files. That pass earned its keep: it
   **killed** one theme as already-present, **narrowed** two, **halved** one, and **corrected a
   factual overclaim** in another. What's below is the survivors, already trimmed.

## The throughline (why these five cohere)

The kit's entire anti-rot engine is **code-anchored**: `reconcile` / `stale` / `coverage` all
key on a page's `code:` files, and staleness is "detected against the code." But the kit itself
says the **highest-value** content a wiki holds is the part with **no code to check against** —
the *why*, the decision history, the "we tried X, it failed because Y" (`llm-wiki-kickoff.md`
§2.4). recmint, being a *human-source-anchored* wiki, was **forced** to build freshness
machinery for exactly that non-code-checkable knowledge — and that machinery back-ports
straight into the kit's blind spot. Three of the five survivors (Edits 1, 2, 4) are variants
of one question the kit never answers: **what do you reconcile against when there's no source
file?**

**The tell — the kit already half-knows this.** Its own shipped seed decision/architecture
pages carry `code: []` (`llm-wiki-kickoff.md:482, 517`), which means *nothing the kit ships can
ever flag them stale.* And the kit's **own** dogfooded wiki independently invented the fix: every
external-source claim there carries a **`verified:` date** because "external claims cannot be
auto-checked" (`wiki/SCHEMA.md:10-15`, frontmatter `verified:` at line 41). recmint converged on
the identical mechanism (`status` + `last_verified`). The pattern is proven twice over — it's
just missing from the guide the kit *hands to projects*. Edit 1 promotes it.

---

## Edit 1 — a `verified:` freshness clock for pages with no code oracle · **HIGH**

*Verdict: keep (narrowed). The strongest finding — it closes a hole in the kit's own examples,
and the kit already runs the mechanism in its own wiki.*

**Gap (both sides).** recmint: trust is the pair `status` + `last_verified`, aged out by a
time-based lint independent of any code diff (`recmint CLAUDE.md:207-219`). Kit: `stale`,
`reconcile`, `coverage` all key on `code:` (`llm-wiki-kickoff.md:268-282`); `updated:` is a
*write* timestamp, not a *verify* timestamp; a page with empty `code:` is structurally invisible
to the freshness engine — and the kit's own seed decision pages are exactly that. Confirmed
absent from the shipped guide; present only in the kit's *own* wiki schema (`wiki/SCHEMA.md`),
never generalized.

**Trimmed off (per the verifier):** do **not** import recmint's four-way provenance enum
(`extracted / inferred / ambiguous / mixed`) — that's the source-trust-tier ceremony §2.8/§7
deliberately decline for the default LLM-only model. Keep only the date + the clock.

### 1a. New subsection in `llm-wiki-kickoff.md`, after §2.1

~~~~~~text
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
  is older than a single age threshold (start ~180 days; tighten per-page only for a genuinely
  volatile fact). This is a **clock**, not a diff: "these un-reconcilable pages haven't been
  re-confirmed in six months — re-read or re-affirm."
- **Trust is the pair, never either half.** A `verified` date on a page nobody re-read is a
  lie; a re-read that doesn't bump the date is invisible. Move `verified` only on a real
  re-confirmation.

This is the kit eating its own cooking: the kit's *own* wiki already carries a `verified:`
date on every external-source claim for exactly this reason (`wiki/SCHEMA.md`) — this
subsection promotes that dogfooded discipline into the pattern the kit ships. Keep it **scoped
to no-`code:` pages**; don't tax every code-anchored page with a second date it doesn't need.
(And stop here: a page's *epistemic class* — extracted vs inferred vs contested — is the
source-trust-tier machinery §2.8/§7 decline for the LLM-only default; at most add an optional
free-text `provenance:` note, never a required enum.)
~~~~~~

### 1b. Frontmatter spec addition (`llm-wiki-kickoff.md` §3, the YAML block ~line 231-241)

~~~~~~text
verified: YYYY-MM-DD          # OPTIONAL — no-`code:` pages only; last human confirmation of the claim (≠ updated:)
~~~~~~

### 1c. Amend the `stale` subcommand description (`llm-wiki-kickoff.md` §4, ~line 275)

~~~~~~text
- **`stale`** — pages whose `updated` predates the last *commit* touching their `code:`, plus
  pages with *uncommitted* edits to their `code:`. **Also flags any page with an empty `code:`
  whose `verified:` date exceeds the age threshold** (§2.1a) — the only staleness signal
  available when there's nothing to diff against.
~~~~~~

### 1d. The keystone cross-ref — `claude-project-kickoff.md` archetype appendix (replace the closing paragraph at ~line 1370-1372)

*This is where the gap currently survives: the appendix is where a content/factual/no-code
project lands, and it says the wiki "carries over unchanged" — adding no aging-fact clock.*

~~~~~~text
The wiki (`llm-wiki-kickoff.md`) carries over with **one freshness delta.** A content/factual
project has little or no `code:` for pages to reconcile against, so the code-diff engine that
keeps a codebase wiki honest has nothing to point at here — and an un-reconcilable page rots
*silently*, which for a facts-first deliverable is the whole risk. Lean on the **`verified:`
clock** instead (wiki guide §2.1a): each factual page carries the date a human last confirmed
it, and `stale` flags the ones gone quiet. Page types skew to the content's own taxonomy; the
highest-value pages are still **incidents** (the claim that was wrong, and how it was caught)
and **decisions** (why the voice/positioning is what it is) — which are exactly the no-`code:`
pages the clock exists to protect.
~~~~~~

### 1e. Ripple edits (the kit's own "wire it in all four spots" rule)

- **Starter checklist** (`llm-wiki-kickoff.md` §9): add — `[ ] no-code: pages carry a
  verified: date; stale flags them by age (§2.1a)`.
- **Per-project `SCHEMA.md`**: the guide (§3) tells each project to note the frontmatter spec
  and markers in its own `SCHEMA.md`; the `verified:` field + the clock rule belong there too.
- **§7 "what to deliberately NOT do"**: no change needed, but confirm the new field reads as an
  add-on for no-`code:` pages, not a default-tier tax (§7 already declines source-trust tiers).

---

## Edit 2 — a conflicts register for what the agent can't adjudicate · **HIGH**

*Verdict: keep (register); the companion corpus-scan is real but scale-gated and was
resized — see the honest caveat below.*

**Gap (both sides).** recmint: on a source-vs-source clash it can't rank, the agent marks the
page `ambiguous`, files a `T-###` row presenting both readings, and **never picks a winner**; a
human ruling resolves it; lint warns on rows open >30d (`recmint self-improvement-mechanisms.md:176-225`).
Kit: §2.9 resolves drift the agent *can* settle (cite the primary, state once, link the rest),
but has **no home** for a conflict it *can't* — and the adoption guide literally names
"a contradiction you can't adjudicate" with nowhere to put it (`claude-project-adoption.md:56`).
The only markers are `GAP` / `UNVERIFIED`; there is no conflicts register anywhere (grep-confirmed).
This is the kit's largest *named-harm / no-mechanism* gap: it cites the sharpest measured harm
in the field — contradictory context ≈ 40% of task time / 75% of tokens (`LESSONS.md:95-97`) —
yet ships no detector or home for it.

### 2a. New subsection in `llm-wiki-kickoff.md` (after §2.9, e.g. §2.10)

~~~~~~text
### 2.10 When the agent can't adjudicate — a conflicts register
§2.9 settles drift the agent *can* resolve. But some conflicts it has **no basis to rank**:
two sources of equal standing disagree, or a wiki page contradicts a `CLAUDE.md` invariant and
which is right is a human call. The failure mode is the agent **quietly picking a winner** (the
more recent, or the more confident-sounding one) and burying the conflict — precisely how a
confident-wrong fact enters and then propagates. The kit already names this hole and offers no
home for it (`claude-project-adoption.md`: "a contradiction you can't adjudicate").

Give it a standing home: a **`tensions.md`** register (append-only like `log.md`,
frontmatter-exempt) — one row per unresolved conflict:

    ## T-003 — [open] SREC cap: architecture/pricing says $X, runbooks/payout says $Y
    - Both pages cite a source; neither is obviously primary.
    - Surfaced: 2026-07-03 (reconcile linked-neighbour check, §2.9)
    - Needs a human ruling. Until then BOTH pages carry `⚠️ CONFLICT: see T-003`.

The convention in one line: **the agent surfaces; a human disposes.** On a conflict it can't
settle, the agent files a `T-###` row, drops a `⚠️ CONFLICT: T-###` marker on *both* pages (so
no reader trusts a contested claim unaware), and **never picks a winner.** A human's ruling
resolves the row (`[resolved]` + the decision) and becomes the ground truth both pages are
corrected to. Have `lint` **warn** on any `[open]` row past an age threshold (e.g. 30 days) so
conflicts can't rot in the register the way they'd rot buried in the pages.

This is the mirror image of the `GAP`/`UNVERIFIED` markers (§3): those mean "a hole we know
about"; `CONFLICT` means "two answers we can't yet choose between." Both make an unknown
*findable* instead of letting the agent paper over it. Cost: one markdown file and a marker —
the smallest defense against the costliest documented failure in the field (contradictory
context; see *the numbers*).
~~~~~~

### 2b. New marker in `llm-wiki-kickoff.md` §3 (the markers list, ~line 243-247)

~~~~~~text
- `> ⚠️ CONFLICT: T-### — <the two readings>` — a contested claim the agent could NOT
  adjudicate; filed in `tensions.md`, awaiting a human ruling. Never resolve it silently.
~~~~~~

### 2c. The corpus-scan companion — OPTIONAL, large multi-author corpus only (add inside §2.9, clearly gated)

*The verifier corrected the original overclaim: recmint's value-token shortlist does **not**
cleanly "survive inversion" — a value corrected $400→$250 leaves the two pages sharing no value
token. Present it honestly, as a cost-based backstop, gated by §7's "small navigable corpus"
stance. Do **not** frame it as defeating §2.9's rejection of the shingle linter.*

~~~~~~text
**(Optional — large, multi-author corpus only.)** The link-graph detector above finds drift
between pages that *link*; it is blind to two pages that state the same fact, never link, and
silently diverge. At a small navigable corpus that barely arises (one-claim-one-home prevents
it) and §7's "resist the extra machinery" stands. If a corpus grows large and multi-author
enough that the convention slips, a periodic **corpus-wide scan** is the backstop: a cheap
deterministic pass shortlists page *pairs* by shared rare terms / shared value tokens
(numbers, dates, dollars) / overlapping scope, excluding already-linked pairs; then an LLM
co-reads each shortlisted pair against its sources and files a `tensions.md` row only after an
adversarial second pass tries to *refute* the contradiction. **Be honest about what this buys:**
it is not the shingle/duplicate-text linter §2.9 rejects (that one dies the moment a copy
inverts) — but the shortlist doesn't magically survive inversion either (a corrected number
leaves no shared value token), so it leans on shared *topic* terms plus the LLM stage. It beats
the shingle linter by adding **judgment and cost**, not a cleverer string match. Sample the
*excluded* pairs occasionally to confirm the cheap filter isn't dropping real conflicts. Reach
for this only once the corpus has outgrown "navigable by eye" — never at kickoff.
~~~~~~

### 2d. Ripple edits

- **`claude-project-kickoff.md` Principle 2 / the routing rule (~line 907):** add one clause —
  "a contradiction the agent *can't* adjudicate goes to the wiki's conflicts register
  (`llm-wiki-kickoff.md` §2.10), **surfaced, not silently resolved.**"
- **`claude-project-adoption.md:56`:** the existing "a contradiction you can't adjudicate" line
  gets its home — cross-ref §2.10.
- **§4 maintenance engine:** note the `lint` age-warn on open `tensions.md` rows.
- **§7 / SCHEMA.md:** name `tensions.md` in the structure list and in the per-project SCHEMA.

---

## Edit 3 — run the safety net at the *class* level, not just per-incident · **MEDIUM-HIGH**

*Verdict: downgrade — keep the cheap meta-safety-net half; demote the measurement/graduation half
to a scale-gated note.*

**Gap (both sides).** Kit: the safety net fires strictly per-incident — "Every time you fix a bug,
add a regression guard … the single highest-leverage habit" (`claude-project-kickoff.md:828-829`)
— and never steps back to notice that several corrections share a root class. Autonomy is chosen
from intake *posture* (tiers at lines 124-132; §1.3a/b add hardening when real creds / a second
committer appear), **never from a measured track record.** recmint supplies both halves: a
scheduled `wiki-retro` that mines the aggregate error record for recurring *classes* and
proposes one durable safeguard each, and a review-outcome ledger that lets autonomy be *earned* from
correction rates. The verifier's call: the meta-safety-net half is a lean, generalizable completion
of the kit's own highest-leverage habit (**keep**); the ledger-and-graduation half is a real
subsystem that only pays off at team/CI PR volume, high-ceremony for the kit's solo/Lean-tier
median user (**demote to a gated note**).

### 3a. The keeper — append to `claude-project-kickoff.md` §1.6, right after line 829

~~~~~~text
- **Run the safety net at the *class* level too, on a cadence.** The per-bug safeguard above fixes one
  instance. Periodically — say every ~5 fixes, or at a regular review pass — **step back over
  the bugs you've fixed and the corrections a reviewer made** and ask whether several share a
  *root class*. If three separate patches all trace to "an agent trusted a doc that had gone
  stale," the durable fix isn't a fourth patch — it's **one** safeguard that kills the class (a
  broader audit grep, a `CLAUDE.md` clarification, a reconcile rule). Propose it; never
  auto-apply. Same safety net, aimed at the *pattern* instead of the *instance* — it's where a pile
  of one-off safeguards becomes a structural defense.
~~~~~~

### 3b. The demoted half — a scale-gated aside near the tier table / §1.3a (priority LOW)

~~~~~~text
**(Scale-gated — skip below real PR volume.)** The autonomy tiers are chosen from intake
*posture*, not from a track record. A project that accumulates a genuine review history — many
merged PRs, a real second-committer or CI reviewer — can let autonomy be *earned from data*: log
what the reviewer **changed** on each merge, typed (real-bug / style-only / lint-false-positive /
the-source-was-wrong), and where corrections for a given slice (a page type, a change type) stay
rare over time, widen what auto-approves *there* — keeping high-stakes classes human-reviewed
regardless of the numbers. Below that volume the per-slice rates are noise; don't build the
ledger — the posture tiers are the right model. (This is recmint-wiki's "review-ledger +
graduation" pattern; it earns its keep only at team/CI scale, so it's a note, not a step.)
~~~~~~

---

## Edit 4 — extend code-anchoring to *schema-anchoring* for systems with no readable source · **MEDIUM**

*Verdict: keep. A short note, not a section; drop the redundant "hash detector."*

**Gap (both sides).** Kit: the reconcile lynchpin is universally "the real SOURCE FILES" in git
(`llm-wiki-kickoff.md:53-63, 237`); every freshness subcommand presupposes readable source in
the repo. It is silent on the case where a subsystem's truth lives behind a schema you can query
but not read as source — a no-code backend, a managed DB, a SaaS admin, an OpenAPI-only
dependency. recmint documents exactly this (a Bubble backend) by extracting the schema to a
committed artifact and anchoring to *it*. The verifier trimmed the "stable-hash / hash-mismatch"
framing as redundant — once the artifact is a committed file in `code:`, the **existing**
reconcile diff already fires; no new machinery.

### 4a. Short note in `llm-wiki-kickoff.md` §2.1

~~~~~~text
**No source file to reconcile against? Anchor to an extracted schema.** §2.1 assumes a page's
subsystem *is* readable source in the repo. Some aren't — a no-code backend (Bubble/Retool), a
managed database, a SaaS admin, a dependency you only have as an OpenAPI/GraphQL schema — so
there's nothing for `reconcile` to diff and the page rots invisibly (the §2.1a case in a
different disguise). Bring it back under the engine: **extract the system's schema — definitions
only, never rows (that would dump real/PII data) — into a committed file** (e.g.
`wiki/_schema/bubble.data-model.json`) and put *that file* in the page's `code:`. The existing
reconcile diff then fires on it exactly as for source — no new drift machinery. When you
regenerate the artifact, **overwrite only a marked auto-generated block and never the
human-authored semantics** (the §2.3 "regenerate the mechanical part, preserve the corrections"
rule — same discipline as the auto-`index` block): a new field appears with a
`⚠️ GAP: needs-semantics` marker; a renamed field shows up as a remove + an add and is flagged
for a human, never silently re-mapped.
~~~~~~

---

## Edit 5 — the executable check is canonical; make it *fail loud* · **LOW**

*Verdict: downgrade to a one-paragraph clause. The "canonical validator / prose is a mirror"
idea is ~80% already present (`README.md:328` "the running code is the source of truth"); the
cluster's claim that the kit had it *backwards* did not survive verification. The one genuinely
net-new, generalizable bit is the **fail-loud** clause.*

**Gap (both sides).** recmint: `lint.py`'s docstring declares itself the source of truth for the
schema enums; CLAUDE.md/README are a labelled mirror with a stated sync obligation; and it
degrades **loud** — a missing YAML parser is reported as `UNCHECKED` (an error), never a silent
pass (`recmint CLAUDE.md:178-181`). Kit: says "keep SCHEMA.md in sync with what the linter
enforces" (`llm-wiki-kickoff.md:255`) and has the "prove controls fire / a rule present but
inert reads as protection" idea — but scoped strictly to **security** guards
(`claude-project-kickoff.md:99-107, 625`), never applied to the wiki's own validator failing
loud when it can't run a check. Grep for `UNCHECKED` / fail-loud in the wiki context: zero hits.

### 5a. Clause to add near `llm-wiki-kickoff.md` lines 339-340 ("wire in all four spots") or the `lint` description

~~~~~~text
**Where a rule is both written down and machine-checked, the check is the source of truth and
the prose is a labelled mirror.** SCHEMA.md *describes* the frontmatter enums; the linter
*enforces* them — so when they disagree the linter wins and SCHEMA.md is what gets corrected
(sync both in the same edit, §3). And make the linter **fail loud**: if it can't actually run a
check — a missing YAML parser, an unreadable file — it must report that check as **`UNCHECKED`
(an error), never a silent pass.** A green run that quietly skipped half its checks is the exact
"a control present but inert reads as protection" trap the kit warns about for security guards
(kickoff §1.6), here applied to the wiki's own validator: doc-vs-enforcement drift must never be
able to hide behind a passing check.
~~~~~~

*(One placement only — do not echo this in `claude-project-kickoff.md`, or it becomes the
duplication the kit warns against.)*

---

## Rejected / trimmed (recorded so nobody re-adds them)

- **Per-page summaries for agent navigation — KILLED as already-present.** The candidate's
  flagship claim ("no `summary:` field; silent read path") is false: `llm-wiki-kickoff.md:239`
  already specs `summary:`, the `index` command regenerates the catalog from it (line 268), and
  the read-mandate routes the agent to `index.md` first (lines 354/357). Its only novel fragment
  — generated axis-cut "maps of content" (recmint's `by-state.md`) — is scale-machinery §7
  deliberately omits, and `by-state` is a regulatory-domain axis, not a generalizable one. No
  edit.
- **The provenance-class enum** (extracted/inferred/ambiguous/mixed) — trimmed off Edit 1; it
  re-imports the source-trust-tier ceremony §2.8/§7 decline for the LLM-only default.
- **recmint's security stack** (managed-settings, `securing-claude-sessions.md`, the pecking
  order) — excluded as **shared DNA**: these are the kit's *own exports* that flowed into
  recmint. Recommending them would be circular.
- **The corpus-scan "survives inversion" claim** — corrected to "beats a shingle linter by
  judgment + cost, not by a cleverer match" (see Edit 2c).
- **Graduation / review-ledger as a mandated subsystem** — demoted to Edit 3b's scale-gated
  note; high-ceremony for the solo/Lean-tier median user.

## Sequencing — where each edit landed (all applied 2026-07-03)

Each was independent; all applied in one pass. Locations are by section (line numbers drift):

- [x] **Edit 1** — `verified:` clock. `llm-wiki-kickoff.md`: new §2.1a; `verified:` added to the
      §3 frontmatter spec; `stale` (§4) extended; §9 checklist item. `claude-project-kickoff.md`:
      archetype-appendix closing paragraph rewritten with the freshness delta. *(Fixes the kit's
      own `code: []` seed pages, which nothing could previously flag stale.)*
- [x] **Edit 2** — conflicts register. `llm-wiki-kickoff.md`: new §2.10, the `CONFLICT` marker
      (§3), `tensions.md` in the structure block, the `lint` age-warn (§4), and the optional
      scale-gated corpus scan (2c) appended to §2.9. Cross-refs added in
      `claude-project-kickoff.md` (Principle 2 routing rule) and `claude-project-adoption.md`
      (the "contradiction you can't adjudicate" interview line).
- [x] **Edit 3** — class-level safety net. `claude-project-kickoff.md` §1.6 (3a); the scale-gated
      earned-autonomy aside added after the tier table (3b).
- [x] **Edit 4** — schema-anchoring note. `llm-wiki-kickoff.md` §2.1 (the extracted-schema note,
      just above §2.1a).
- [x] **Edit 5** — fail-loud clause. `llm-wiki-kickoff.md` §4, after the "wire in all four
      spots" note.

Verified 2026-07-03: every `§2.1a` / `§2.10` reference resolves to its single definition across
all three guides; `tensions.md`, `verified:`, `CONFLICT`, and `UNCHECKED` are all wired in; the
two large insertions were re-read for coherence and well-formed fences. This page's `code:`
lists the three edited guides, so a future edit to any of them surfaces this record for review.

## Provenance of this analysis

Produced 2026-07-03 by a 15-agent workflow (coverage-map → pattern-catalog → cluster →
adversarial-verify) over `../../recmint-wiki` and the shipped kit files. Every gap claim is
`file:line`-anchored to one side or the other; every survivor passed an independent refutation
pass. Kept in the repo (not machine-local memory) per the kit's own Principle 2 — project
knowledge lives where it travels with the code and can be reconciled. Sibling to
[[2026-07-audit-pass]], the same Fable-driven expansion posture applied outward instead of
inward.

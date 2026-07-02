# Kit wiki — schema & operating contract

This is the **kit's own knowledge base**, built by applying `../llm-wiki-kickoff.md` to the
kit itself. It holds what the kit's documents assert but shouldn't carry inline: the
**verified citations** behind the kit's claims, and the **decision history** of the kit's
own evolution. Read this file first every time you touch the wiki.

## What's different from a code-project wiki (stated, not hidden)

- **Ground truth is split.** A code wiki reconciles pages against source files. Here a page
  reconciles against two things: (1) the **kit documents** that lean on it — listed in
  `code:` — and (2) **external sources** (URLs), which cannot be auto-checked. So every
  external claim carries a **`verified:` date** (when it was last read against the live
  source). Treat any page whose verified date predates a major Claude Code release as
  *unverified for feature claims* until re-checked.
- **`code:` means "the kit files whose claims this page supports."** If one of those files
  changes its claims, revisit the page; if the page's sources change on re-read, revisit
  the file. Same loop as `llm-wiki-kickoff.md` §2.1, pointed both ways.
- **No maintenance engine.** The corpus is small (< 10 pages) and changes only when the kit
  docs do; a lint/reconcile script would be complexity the project hasn't earned
  (kit Principle 1/8). Deliberately omitted: the stdlib script, `log.md`, embeddings,
  review gates. Reconcile is **manual, at each kit-editing session**, and this omission is
  named here so no future session "helpfully" adds the machinery without cause. The signal
  to build the engine: pages start contradicting each other or going stale between passes.

## Page types

- `sources/` — what a primary source actually says: verbatim-checked quotes, URL, date,
  and what the kit uses it for. One page per source *cluster*, not per URL.
- `decisions/` — why the kit says what it says (ADR-lite): context → evidence → verdict →
  what was rejected. The dead ends are first-class content.

## Frontmatter

```yaml
---
title: "..."
type: source | decision
status: current            # current | superseded | historical
updated: YYYY-MM-DD
verified: YYYY-MM-DD       # external claims last read against the live source
code: [../claude-project-kickoff.md]   # kit files whose claims this page supports
related: ["[[other-slug]]"]
summary: "one-line catalog blurb"
---
```

## Safety model

LLM-only, no human review gate: **git is the audit trail and the undo**; manual
reconcile-against-source is the correctness check. Never paste a secret. Cite the primary
source, not a summary of one (`llm-wiki-kickoff.md` §2.9); a claim lives on **one** page —
other pages link `[[it]]`.

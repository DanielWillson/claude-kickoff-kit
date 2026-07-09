# Kit wiki — index

The kit's own knowledge base: the verified citations behind its claims and the decision
history of its evolution. Conventions in [[SCHEMA]] — read that first. Every external
claim carries a `verified:` date; re-check pages older than the current Claude Code major
release before trusting feature claims.

## Sources (what the primary sources actually say)

- [[anthropic-engineering]] — Anthropic's harness/agents/security engineering posts,
  quote-checked; backs Part 3, the bibliography, and "What scales with the model."
- [[operator-field-reports]] — first-hand practitioner accounts 2025–2026 (Ronacher,
  Hashimoto, Willison, Yegge, HumanLayer, Every, Amp, Gustafson, Vincent, Litt).
- [[claude-code-feature-matrix]] — stable vs. preview vs. nonexistent multi-agent
  features; backs Part 3's probe paragraph. Rots fastest; probe the live environment
  instead when you can.

## Decisions (why the kit says what it says)

- [[2026-07-audit-pass]] — the Fable-driven audit: kept/cut/reversed/added, with the
  rejected alternatives.
- [[2026-07-credential-incident]] — a downstream kit repo leaked a live GitHub credential via
  a config self-contradiction the kit shipped; the eight-file hardening response (deny-family
  patch, canary rules, verify-it-flows, fan-out doctrine) and what was verified vs. hypothesized.
- [[2026-07-recmint-learnings]] — five edits mined from the recmint-wiki production instance
  (freshness clock, conflicts register, class-level safety net, schema-anchoring, fail-loud
  validator); **applied to the shipped guides 2026-07-03**, with the reasoning record retained.
- [[claude-md-size]] — the 50-line rule is unsourced; what Anthropic/OpenAI/IFScale
  actually say.
- [[reasoning-extraction]] — Principle 3 does not conflict with Fable-class refusal
  categories; where the real line is.
- [[skills-shortlist]] — no mandatory companion skill; the vetting posture + dated
  shortlist evidence.

## Journal

- [[harness-log]] — the kit's own append-only harness change log (its instance of the
  root-level `HARNESS_LOG.md` template the kit ships): each harness change recorded as a
  bet + a retrospect.
- [[harness-manifest]] — the kit's own harness manifest (its instance of the root-level
  `HARNESS_MANIFEST.md` template, item W): each harness part tagged with what it assumes ×
  when last verified × the event that makes it stale. Assumptions + freshness, not presence
  or history.

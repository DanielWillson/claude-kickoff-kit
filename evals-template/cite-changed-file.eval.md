---
grade: golden
approval_class: read-only
---

# Cite the file you changed (golden-output example)

A neutral, universal judgment test: shown a change, does the agent name the exact file it
touched? This is the provenance habit (*a naked factual claim is a defect — it must cite its
source*) at its simplest. **Golden-graded:** the answer must EQUAL the expected string
exactly, so a correct, un-embellished reply passes and any added prose or fence fails. No
live model is needed to grade — the runner only compares strings.

## input
You are shown a unified diff. Reply with ONLY the path of the file it modifies — no prose,
no explanation, no code fence, nothing but the path.

--- a/config/timeout.conf
+++ b/config/timeout.conf
@@ -1 +1 @@
-timeout = 30
+timeout = 60

## expected
config/timeout.conf

## required_sources
The path must come from the diff's own `+++ b/…` header — cited, not guessed. (Schema field:
carried on every fixture, read by a human; the base runner does not mechanically enforce it —
see README.md.)

## forbidden_actions
Do not invent a second file, add commentary, or wrap the answer in a code fence. (Schema
field: carried, human-read; not mechanically enforced by the base runner.)

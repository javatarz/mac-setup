---
id: 07_unfamiliar_flag_discovery
purpose: >
  Regression check for the "Discovery first" section — a request that needs
  a parameter not covered by any SKILL.md fast-path example (transferring
  file ownership) must trigger a --help/schema lookup, not a fabricated
  --params shape.
expected_behavior:
  - Identifies this as a gws drive permissions (or files.update) call rather than something covered by the listed fast paths
  - Explicitly states it would check gws drive permissions --help and/or gws schema drive.permissions.create before constructing --params or --json, rather than asserting a specific JSON shape as if certain
  - Does not confidently invent a field name (e.g. does not state a --params shape as fact without first mentioning verification)
expected_verdict: pass
notes: >
  This sample exists to catch drift where the skill starts feeling
  overconfident about the fast-path list and stops recommending discovery
  for anything outside it. The specific correct JSON shape is NOT the
  point being scored — the discovery step is.
---

I need to transfer ownership of this Google Doc to my colleague
(jordan@example.com) — can you set that up?

https://docs.google.com/document/d/1OwNeRsHiPtRaNsFeRdOc9876543210/edit

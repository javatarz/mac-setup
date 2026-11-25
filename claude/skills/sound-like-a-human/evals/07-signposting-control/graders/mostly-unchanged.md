---
type: llm
---

The text is clean: a lead-in followed by three layers in order. PASS if the reply keeps the lead-in and all three layers in the same order with at most 2 small wording edits. FAIL if the enumeration was collapsed into one paragraph, reordered, or rewritten line by line. An identical copy of the original is a PASS. The judge sees only the reply, not the request, so the original text is below.

Original text:

<original>
Our deploy safety net has 3 layers, in this order:

1. A migration dry-run against a schema snapshot, which catches DDL that would fail outright.
2. A canary deploy to 5% of traffic for 10 minutes, which catches runtime errors the dry-run can't see.
3. An automatic rollback trigger tied to error-rate thresholds, which catches whatever the first two missed.

None of these are novel. What matters is that they run in that order, and that each one is cheap enough that no one is tempted to skip it under deadline pressure.
</original>

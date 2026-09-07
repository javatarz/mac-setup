---
id: 10_new_rules_counterexamples
purpose: >
  False-positive check for the same nine new rules covered by
  09_new_rules_triggers, using each rule's documented "kept" counter-example
  reworked into one coherent piece. Should pass with zero or near-zero flags.
expected_flags: []
expected_verdict: pass
notes: >
  If the skill flags any of these, that's a false positive on a specific
  new rule — check which counter-example in SKILL.md it's misreading.
---

## The question to ask every guardrail

Mutant 32 inverts the review rule: high-value orders from unknown
countries now skip human review. That's the guardrail worth worrying
about, and it's the one this post is about.

The harness never regresses, it only gets better, because every mutant we
catch becomes a permanent regression test. Wiring the pipeline takes an
afternoon; making the test suite trustworthy takes months. The agent is
confident and wrong often enough that no term of art replaces that
description.

We've run this pattern in production for a quarter now (designed, not yet
run against the payments path). Thanks to Priya for catching the queue
edge case in review.

Here's the config, illustrative only, not runnable:

```yaml
# illustrative, not runnable
retry:
  max_attempts: 3
  backoff: exponential
```

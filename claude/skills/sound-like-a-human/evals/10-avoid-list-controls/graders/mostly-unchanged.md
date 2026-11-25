---
type: llm
---

The judge sees only the reply, not the request, so the original text is below. It is already clean and needs no changes. PASS if the reply is the original unchanged, or has at most 3 small edits (a word or phrase each) and every sentence still says the same thing, with the YAML sample intact. An identical copy is a PASS. FAIL if sentences were rewritten, the designed-only caveat ("designed, not yet run against the payments path") was dropped, or content was added.

Original text:

<original>
## Check each guardrail for gaps

Mutant 32 inverts the review rule: high-value orders from unknown countries now skip human review. That's the guardrail I worry about, and this post is about it.

Every mutant we catch becomes a permanent regression test, so the harness only gets stronger. Wiring the pipeline takes an afternoon. Making the test suite trustworthy takes months. The agent is confident and wrong often enough that I treat its output as a draft.

We've run this pattern for a quarter now (designed, not yet run against the payments path). Thanks to a teammate for catching the queue edge case in review.

Here's the config, illustrative only, not runnable:

```yaml
# illustrative, not runnable
retry:
  max_attempts: 3
  backoff: exponential
```
</original>

---
description: 'Control. Plain statements, a designed-only label, a thank-you, and a labelled sample all stay.'
tags: [review, ported, control]
max_turns: 20
timeout_seconds: 240
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Review this blog post excerpt (it is a how-to post) and fix anything that doesn't sound like me. Reply with only the revised text, no commentary.

<text>
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

</text>

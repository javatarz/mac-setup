---
description: 'Clever heading, rigour boast, aphorism, list-then-punchline, stock idiom, and a config sample with invented proof.'
tags: [review, ported, free]
max_turns: 20
timeout_seconds: 240
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Review this blog post excerpt (it is a how-to post, so code samples must run) and fix anything that doesn't sound like me. Reply with only the revised text, no commentary.

<text>
## One question separates a real fix from a decorative one

We didn't just eyeball the retry logic. We tested it properly. Mandatory retries ≠ unlimited retries, and once you see that the queue was forgotten under pressure, the fix is obvious.

Anyone can add a retry loop. The real work, the design reviews, the incident write-ups, and the on-call rotations that shaped this approach, are all theirs, the platform team's, not mine.

We've collected a lot of war stories getting here, but the pattern holds.

Here's the config we shipped:

```yaml
retry:
  max_attempts: 3
  backoff: exponential
  result: 5/5 requests succeeded after retry
```

</text>

---
description: 'Realistic draft with 3 planted issues (empty setup line, passive fix, buzzword list). The rest stays.'
tags: [review, ported]
max_turns: 20
timeout_seconds: 240
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Review this blog post excerpt and fix anything that doesn't sound like me. Reply with only the revised text, no commentary.

<text>
I spent last week debugging why our staging environment kept drifting from prod configs, and the root cause was dumber than I expected: a Terraform module that had been forked two years ago and never re-synced.

Here's the thing worth noting: this kind of drift is rarely caused by one big mistake. It's caused by a dozen small, reasonable-seeming decisions, each made by someone who had no visibility into the others.

The fix that was applied was a scheduled diff job that was run nightly against both environments, with results that were posted to the team channel automatically.

We're now looking at broader improvements around observability, tooling alignment, and process maturity across the platform team, though nothing's concrete yet.

If you're maintaining forked infra modules, I'd check the sync date before you trust them. Mine was 14 months stale and no one had noticed.

</text>

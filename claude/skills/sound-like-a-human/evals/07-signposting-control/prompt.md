---
description: 'Control. A real enumeration with an honest lead-in is not an empty setup line.'
tags: [review, ported, control]
max_turns: 20
timeout_seconds: 240
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Review this blog post excerpt and fix anything that doesn't sound like me. Reply with only the revised text, no commentary.

<text>
Our deploy safety net has 3 layers, in this order:

1. A migration dry-run against a schema snapshot, which catches DDL that would fail outright.
2. A canary deploy to 5% of traffic for 10 minutes, which catches runtime errors the dry-run can't see.
3. An automatic rollback trigger tied to error-rate thresholds, which catches whatever the first two missed.

None of these are novel. What matters is that they run in that order, and that each one is cheap enough that no one is tempted to skip it under deadline pressure.

</text>

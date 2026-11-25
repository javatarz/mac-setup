---
description: 'Control. The planted issue is the dashes. The author''s own caveat, numbers, and "I think" opener are their voice and stay.'
tags: [review, ported, control]
max_turns: 20
timeout_seconds: 240
allowed_tools: [Skill, Read, Glob, Grep]
disallowed_tools: [Agent]
---
Review this blog post excerpt and fix anything that doesn't sound like me. Reply with only the revised text, no commentary.

<text>
Here's how I think about code review time budgets: I used to block 30 minutes per PR — no matter the size — and it was wrong more often than it was right.

A one-line config change and a 400-line refactor don't deserve the same slice — the first needs five minutes of attention, the second needs a clear head and no interruptions — so I stopped fixing the number and started fixing the trigger instead: review starts when I've read the PR description once, not when a timer says so.

I'm not sure this generalizes past small teams — we're eight engineers, and I haven't tested it anywhere bigger — but it's cut my own review latency by about half.

</text>

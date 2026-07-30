---
id: 06_authentic_voice_control
purpose: >
  Second control sample — strong authentic voice with one deliberately
  planted issue (em-dash overuse), to check the skill doesn't blanket-pass
  just because personal anecdote is present.
expected_flags:
  - em_dash_overuse
expected_verdict: pass_with_minor_polish
notes: >
  Everything else here should read clean — personal anecdote, "I" voice,
  acknowledged uncertainty, concrete comparison. Only the em-dashes should
  get flagged.
---

Here's how I think about code review time budgets: I used to block 30
minutes per PR — no matter the size — and it was wrong more often than it
was right.

A one-line config change and a 400-line refactor don't deserve the same
slice — the first needs five minutes of attention, the second needs a
clear head and no interruptions — so I stopped fixing the number and
started fixing the trigger instead: review starts when I've read the PR
description once, not when a timer says so.

I'm not sure this generalizes past small teams — we're eight engineers, and
I haven't tested it anywhere bigger — but it's cut my own review latency by
about half.

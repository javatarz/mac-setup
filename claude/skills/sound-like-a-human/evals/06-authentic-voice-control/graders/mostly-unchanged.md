---
type: llm
---

The original text is the author's own voice, including their caveat and numbers. PASS if the reply is the same text with only the dashes replaced (and at most 2 other small edits): nearly every sentence is kept, and no facts were added or dropped. FAIL if sentences were rewritten, merged, or reordered, or if facts were added or dropped. An identical copy of the original is a PASS. The judge sees only the reply, not the request, so the original text is below.

Original text:

<original>
Here's how I think about code review time budgets: I used to block 30 minutes per PR — no matter the size — and it was wrong more often than it was right.

A one-line config change and a 400-line refactor don't deserve the same slice — the first needs five minutes of attention, the second needs a clear head and no interruptions — so I stopped fixing the number and started fixing the trigger instead: review starts when I've read the PR description once, not when a timer says so.

I'm not sure this generalizes past small teams — we're eight engineers, and I haven't tested it anywhere bigger — but it's cut my own review latency by about half.
</original>

---
id: 08_mixed_realistic
purpose: >
  Realistic mixed draft — mostly solid, with 2-3 subtle issues planted, to
  simulate an actual editing pass rather than an obvious toy example.
expected_flags:
  - empty_setup_line
  - passive_voice_overuse
  - buzzword_soup
expected_verdict: pass_with_minor_polish
notes: >
  Precision test — the skill should catch the 3 planted issues without
  also flagging the surrounding clean paragraphs as problems.
---

I spent last week debugging why our staging environment kept drifting from
prod configs, and the root cause was dumber than I expected: a Terraform
module that had been forked two years ago and never re-synced.

Here's the thing worth noting: this kind of drift is rarely caused by one
big mistake. It's caused by a dozen small, reasonable-seeming decisions,
each made by someone who had no visibility into the others.

The fix that was applied was a scheduled diff job that was run nightly
against both environments, with results that were posted to the team
channel automatically.

We're now looking at broader improvements around observability, tooling
alignment, and process maturity across the platform team, though nothing's
concrete yet.

If you're maintaining forked infra modules, I'd check the sync date before
you trust them. Mine was 14 months stale and nobody had noticed.

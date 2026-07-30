---
id: 05_clarity_violations
purpose: Trigger "Clarity & Concision Review" — Elements of Style rule violations.
expected_flags:
  - passive_voice_overuse
  - needless_words
  - unclear_or_overcomplex_sentence
  - negative_statement_could_be_positive
  - vague_abstract_language
expected_verdict: needs_revision
notes: >
  Each sentence is written to trip one Elements of Style rule (10, 11, 12,
  13) called out in SKILL.md.
---

It was decided by the team that the migration script would be rewritten by
the on-call engineer at some point in the near future, due to the fact that
it had been causing a certain amount of intermittent difficulty.

It is not uncommon for this kind of issue to not be noticed until a fairly
significant amount of time has passed, which is not an ideal situation for
anyone involved in the process of maintaining the system in question.

There are a number of different ways in which this general category of
problem could potentially be addressed, in the event that a team decides it
is worth the investment of engineering time and resources.

---
id: 07_signposting_false_positive_check
purpose: >
  False-positive check for the empty-setup-line rule (SKILL.md line 42
  carve-out). Genuine signposting before a real enumeration should NOT be
  flagged as an "empty setup/announcement line."
expected_flags: []
expected_verdict: pass
notes: >
  If the skill flags "Three layers, in this order:" as an empty
  announcement, that's a false positive — the exception in SKILL.md
  explicitly protects this pattern.
---

Here's how I think about our deploy safety net: three layers, in this
order.

First, the migration dry-run against a schema snapshot — catches DDL that
would fail outright.

Second, a canary deploy to five percent of traffic for ten minutes —
catches runtime errors the dry-run can't see.

Third, an automatic rollback trigger tied to error-rate thresholds — catches
whatever the first two missed.

None of these are novel. What matters is that they run in that order, and
that each one is cheap enough that nobody's tempted to skip it under
deadline pressure.

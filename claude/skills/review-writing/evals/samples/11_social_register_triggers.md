---
id: 11_social_register_triggers
purpose: >
  Trigger the "Register tells (LinkedIn/X, short-form posts)" category:
  dash-joined qualifier instead of a full stop, spelled-out number instead
  of a numeral, softening "but" in a short declarative.
expected_flags:
  - dash_joined_qualifier_in_social_copy
  - spelled_out_number_in_social_copy
  - softening_but_in_social_copy
expected_verdict: needs_revision
notes: >
  This is a LinkedIn-style post, not a blog post - the register rules only
  apply to this short-form context (see 12 for the same rules NOT applying
  outside it).
---

LinkedIn post draft:

Three things kept this incident from getting worse - but only because
we'd written them down ahead of time, not because anyone remembered them
under pressure.

All three checks ran automatically, but two of them only fired after the
rollback had already started.

Small margin, but it held.

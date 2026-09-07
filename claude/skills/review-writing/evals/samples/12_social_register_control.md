---
id: 12_social_register_control
purpose: >
  Control for the "Register tells (LinkedIn/X, short-form posts)" category.
  Same incident, same short-form format, register rules already followed
  correctly. Should pass with zero or near-zero flags.
expected_flags: []
expected_verdict: pass
notes: >
  Pairs with 11_social_register_triggers. If the skill still flags dashes,
  spelled-out numbers, or "but" here, that's a false positive - none are
  present, and the register itself (short, numeral-heavy, full stops) is
  correct for this format.
---

LinkedIn post draft:

I caught this incident before it got worse because of 3 checks I'd
already put in place. I didn't remember any of them under pressure. The
checks did the remembering for me.

All 3 ran automatically. One fired late, right after the rollback
started.

Small margin. It held.

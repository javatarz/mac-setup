---
id: 09_new_rules_triggers
purpose: >
  Trigger the new rules added from the 2026-09 deck-editing feedback log:
  boast/rigor meta-narration, compressed aphorisms, vague anthropomorphism
  vs. term of art, "anyone can X" belittling, stock idioms, abstract-clever
  heading, list-then-possessive-punchline, claim scoped beyond what's
  established, and a code sample that fails a literal parse check.
expected_flags:
  - boast_meta_narration_about_rigor
  - compressed_symbolic_aphorism
  - vague_anthropomorphism_where_term_of_art_exists
  - anyone_can_x_belittling
  - stock_idiom_cliche
  - abstract_clever_heading
  - list_then_possessive_punchline
  - claim_scoped_beyond_established_content
  - code_sample_fails_parse_or_run_check
expected_verdict: needs_revision
notes: >
  Each paragraph targets one new bullet added to SKILL.md in the 2026-09-07
  update. A good run should name most or all nine.
---

## One question separates a real fix from a decorative one

We didn't just eyeball the retry logic. We tested it properly. Mandatory
retries ≠ unlimited retries, and once you see that the queue was forgotten
under pressure, the fix is obvious.

Anyone can add a retry loop. The real work, the design reviews, the
incident write-ups, and the on-call rotations that shaped this approach,
are all theirs, the platform team's, not mine.

Our three services now run this pattern in production, even though only
two of them are actually described above.

Here's the config we shipped:

```yaml
retry:
  max_attempts: 3
  backoff: exponential
  result: 5/5 requests succeeded after retry
```

We've collected a lot of war stories getting here, but the pattern holds.

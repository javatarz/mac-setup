# Evals for the `review-writing` skill

Golden-sample eval harness. Purpose: catch regressions when `SKILL.md`
changes — verify it still flags what it should, and doesn't flag what it
shouldn't.

## Layout

```
evals/
  EVALS.md          this file
  samples/          8 synthetic writing samples, each with frontmatter:
                     id, purpose, expected_flags, expected_verdict, notes
```

Samples map directly to `SKILL.md` sections:

| Sample | Section under test |
|---|---|
| `01_clean_control` | False-positive baseline — clean writing, expect ~0 flags |
| `02_structural_tells` | ChatGPT Tells Check → Structural tells |
| `03_language_tells` | ChatGPT Tells Check → Language tells |
| `04_content_tells` | ChatGPT Tells Check → Content tells |
| `05_clarity_violations` | Clarity & Concision Review (Elements of Style) |
| `06_authentic_voice_control` | Authenticity Check + narrow em-dash flag only |
| `07_signposting_false_positive_check` | Regression check for the genuine-signposting carve-out (SKILL.md ~line 42) |
| `08_mixed_realistic` | Precision test — realistic draft, 3 planted issues, rest should read clean |

## Running the eval

For each sample:

1. Strip the frontmatter, feed the body to the `review-writing` skill as if
   it were the content to review (invoke `Skill({skill: "review-writing"})`
   with the sample body as input, or hand it to a fresh agent along with
   the current `SKILL.md` contents and ask it to follow those instructions
   exactly).
2. Capture the review output.
3. Score against the sample's frontmatter:
   - **Recall**: how many of `expected_flags` did the output actually
     name or clearly describe? (Match on substance, not exact string —
     the skill won't use these slugs verbatim.)
   - **Precision / false positives**: for `01` and `07`, the bar is
     near-zero flags. Any flag raised there is a false positive — note it
     specifically, since those two samples exist only to catch
     over-triggering.
   - **Verdict match**: does section 7 (Summary) land on something
     consistent with `expected_verdict`?

4. Record pass/fail per sample in a run log (date, SKILL.md git hash,
   model id, per-sample recall/precision, notes). Keep the log in this
   folder if it grows past a few runs — otherwise the conversation history
   is enough for a one-off check.

## Running via script

`./run-evals.sh` automates the above: `claude -p` runs the skill against
each sample, judges the output against `expected_flags`, and writes
`results/<timestamp>/` with a `.review.md` and `.verdict.txt` per sample
plus a `MODEL.txt` recording the resolved model id (`claude -p "State only
your exact model id string, nothing else."`). Defaults to `sonnet` if
`EVAL_MODEL` isn't set; pin a different one with
`EVAL_MODEL=claude-opus-5 ./run-evals.sh`. Compare `MODEL.txt` across runs
before treating a pass/fail delta as a real regression rather than a model
change.

## When to run this

- After any edit to `SKILL.md`, before committing.
- Periodically, if you suspect drift (e.g. the skill starts feeling
  looser or stricter without an intentional edit).

## Known limits

- This is an LLM-judged eval, not a deterministic test — expect some
  run-to-run variance. Treat a single sample failure as noise; treat the
  same sample failing 2+ runs in a row as signal.
- 8 samples is coverage of each rule category, not exhaustive. Add a
  sample whenever a real review surfaces a false positive/negative worth
  locking in as a regression check.

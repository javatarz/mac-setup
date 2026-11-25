# Tests for sound-like-a-human

Run everything with `tests/run.sh` from any directory. It takes a few seconds and exits non-zero on failure.

## What runs

- `test_lint.py`: one unit test per linter rule case (41 cases) plus shape and keep-word checks, against `scripts/lint.py`.
- `test_corpus.py`: lints every post in `fixtures/corpus-pre-2022/` (the user's own pre-2022 posts from karun.me) and compares alert counts per rule against `corpus_baseline.json`. The test fails if any rule's count goes up, because that means a new false positive on human writing. A count going down only prints a note.

The posts predate some newer rules (serial comma, no one-sentence paragraphs), so the baseline has non-zero counts. This is a regression guard, not a zero-alerts check.

## Updating the baseline

```bash
python3 tests/test_corpus.py --update
```

Update it only when the change is deliberate:

- You added or tightened a rule and the new alerts on old posts are correct (the old posts really do break the rule).
- Counts dropped because you fixed a false positive. Update to lock in the improvement.

Do not update it to silence a rule that now fires on writing that is fine. Fix the rule instead. Review the diff of `corpus_baseline.json` before committing.

# Tests for sound-like-a-human

Run everything with `tests/run.sh` from any directory. It needs Vale (`brew install vale`) and stops with that command if it is missing. It takes a few seconds and exits non-zero on failure.

## What runs

- `test_vale.py`: runs `vale test --coverage` on `vale/styles/Voice`, which executes the `tests:` cases kept inside each rule file and fails if a rule has none. It also checks the per-type switches in `vale/vale.ini` (numerals at warning on social and at suggestion elsewhere, no paragraph-count rule on social, email or slides, and the social-, slides- and doc-only rules) and the wrapper's failure messages.
- `test_lint.py`: one test per rule case (41 cases) through the real wrapper `scripts/lint.py`, plus shape and keep-word checks.
- `test_corpus.py`: lints every post in `fixtures/corpus-pre-2022/` (the user's own pre-2022 posts from karun.me) and compares alert counts per file and rule against `corpus_baseline.json`. The test fails if any file's count for a rule goes up, because that means a new false positive on human writing. A count going down only prints a note.

- `test_privacy.py`: this repo is public, so it scans the skill folder's text files and fails on email addresses, phone numbers, URLs outside a small host allowlist, and terms from an optional private denylist. The blog fixtures only get the email and phone checks. The denylist lives outside the repo: put one term per line (matched case-insensitively as a whole word) in `~/.config/sound-like-a-human/private-terms.txt`, or point `SOUND_LIKE_A_HUMAN_PRIVATE_TERMS` at another file. Without the file, that part is skipped with a note.

The posts predate some newer rules (serial comma, no one-sentence paragraphs), so the baseline has non-zero counts. This is a regression guard, not a zero-alerts check.

## Updating the baseline

```bash
python3 tests/test_corpus.py --update
```

Update it only when the change is deliberate:

- You added or tightened a rule and the new alerts on old posts are correct (the old posts really do break the rule).
- Counts dropped because you fixed a false positive. Update to lock in the improvement.

Do not update it to silence a rule that now fires on writing that is fine. Fix the rule instead. Review the diff of `corpus_baseline.json` before committing.

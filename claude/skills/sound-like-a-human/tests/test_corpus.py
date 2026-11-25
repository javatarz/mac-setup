"""Regression guard: lint the user's own pre-2022 posts and compare alert
counts per rule against tests/corpus_baseline.json.

Human writing should not trigger new alerts. The test fails if any rule's
count goes UP. Counts going down are fine (a note is printed).

Non-zero baseline counts are expected: the posts predate some newer rules
(serial comma, no one-sentence paragraphs). This is a guard, not a zero check.

Run: python3 tests/test_corpus.py            (as a test)
     python3 tests/test_corpus.py --update   (regenerate the baseline)
"""
import collections
import json
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "scripts"))
import lint  # noqa: E402

CORPUS = os.path.join(HERE, "fixtures", "corpus-pre-2022")
BASELINE = os.path.join(HERE, "corpus_baseline.json")


def count_alerts():
    counts = collections.Counter()
    for name in sorted(os.listdir(CORPUS)):
        if not name.endswith(".md"):
            continue
        with open(os.path.join(CORPUS, name), encoding="utf-8") as f:
            for hit in lint.check(f.read(), "post"):
                counts[hit[2]] += 1
    return dict(sorted(counts.items()))


class CorpusRegression(unittest.TestCase):
    def test_no_rule_alerts_more_than_baseline(self):
        with open(BASELINE, encoding="utf-8") as f:
            baseline = json.load(f)
        current = count_alerts()
        worse = {r: (baseline.get(r, 0), n) for r, n in current.items() if n > baseline.get(r, 0)}
        better = {r: (b, current.get(r, 0)) for r, b in baseline.items() if current.get(r, 0) < b}
        for rule, (was, now) in sorted(better.items()):
            print(f"note: {rule} dropped {was} -> {now}; consider --update", file=sys.stderr)
        self.assertEqual(
            worse, {},
            "New alerts on human writing (rule: baseline, now). Fix the rule, "
            "or run --update if the new alerts are legitimate.",
        )


if __name__ == "__main__":
    if "--update" in sys.argv:
        counts = count_alerts()
        with open(BASELINE, "w", encoding="utf-8") as f:
            json.dump(counts, f, indent=2)
            f.write("\n")
        print(f"Wrote {BASELINE}: {sum(counts.values())} alerts across {len(counts)} rules")
    else:
        unittest.main()

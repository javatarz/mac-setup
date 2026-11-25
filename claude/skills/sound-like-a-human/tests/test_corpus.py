"""Regression guard: lint (through the Vale wrapper) the user's own pre-2022 posts and compare alerts
per file and rule against tests/corpus_baseline.json.

Human writing should not trigger new alerts. The test fails if any file has
more alerts for a rule than the baseline (a likely new false positive).
Counts going down are fine (a note is printed).

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

sys.dont_write_bytecode = True  # never leave __pycache__ in the repo

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, "..", "scripts")))
import lint  # noqa: E402
from runner import rel  # noqa: E402

CORPUS = os.path.join(HERE, "fixtures", "corpus-pre-2022")
BASELINE = os.path.join(HERE, "corpus_baseline.json")
MAX_LINES_SHOWN = 5  # per file and rule, to keep the message short


def lint_corpus():
    """Return {file: [hits]} where a hit is (line, level, rule, message, snippet)."""
    out = {}
    for name in sorted(os.listdir(CORPUS)):
        if name.endswith(".md"):
            with open(os.path.join(CORPUS, name), encoding="utf-8") as f:
                out[name] = lint.check(f.read(), "post")
    return out


def count_by_file(results):
    counts = {}
    for name, hits in results.items():
        c = collections.Counter(h[2] for h in hits)
        if c:
            counts[name] = dict(sorted(c.items()))
    return counts


class CorpusRegression(unittest.TestCase):
    def test_no_file_alerts_more_than_baseline(self):
        with open(BASELINE, encoding="utf-8") as f:
            baseline = json.load(f)
        known_rules = {r for rules in baseline.values() for r in rules}
        results = lint_corpus()
        current = count_by_file(results)

        problems, drops, unknown = [], [], set()
        for name, rules in current.items():
            for rule, n in rules.items():
                was = baseline.get(name, {}).get(rule, 0)
                if n > was:
                    shown = [h for h in results[name] if h[2] == rule][:MAX_LINES_SHOWN]
                    lines = "".join(f"\n      {name}:{h[0]}  {h[4][:50]!r}" for h in shown)
                    if rule not in known_rules:
                        unknown.add(rule)
                    problems.append(f"  {rule}: {was} -> {n} in {name}{lines}")
        for name, rules in baseline.items():
            for rule, was in rules.items():
                if current.get(name, {}).get(rule, 0) < was:
                    drops.append(f"{rule} in {name}")

        update_cmd = f"python3 {rel(os.path.abspath(__file__))} --update"
        if unknown:
            gone = sorted(known_rules - {r for rules in current.values() for r in rules})
            self.fail(
                "CORPUS BASELINE OUT OF DATE: rule id(s) not in the baseline: " + ", ".join(sorted(unknown)) + "\n"
                + (f"  rule id(s) in the baseline that no longer fire anywhere: {', '.join(gone)}\n" if gone else "")
                + "  why:   a rule was added or renamed in vale/styles/Voice, so its alerts have no baseline.\n"
                "  fix:   if the rename or addition was NOT intended, restore the rule name in vale/styles/Voice.\n"
                "         If it was, regenerate the baseline and review its diff:\n"
                f"           {update_cmd}"
            )
        if problems:
            self.fail(
                "CORPUS REGRESSION: rules now flag the author's own pre-2022 posts more than the baseline\n"
                + "\n".join(problems)
                + "\n  why:   these posts are human writing; extra alerts are most likely false positives in vale/styles/Voice.\n"
                "  fix:   narrow the rule in vale/styles/Voice and re-run. If the new alerts are correct\n"
                "         (the posts really break the rule), regenerate the baseline and review its diff:\n"
                f"           {update_cmd}"
            )
        if drops:
            print(f"note: {len(drops)} baseline entries dropped (e.g. {drops[0]}); "
                  f"run {update_cmd} to lock in the improvement", file=sys.stderr)


if __name__ == "__main__":
    if "--update" in sys.argv:
        counts = count_by_file(lint_corpus())
        with open(BASELINE, "w", encoding="utf-8") as f:
            json.dump(counts, f, indent=1, sort_keys=True)
            f.write("\n")
        total = sum(n for r in counts.values() for n in r.values())
        print(f"Wrote {rel(BASELINE)}: {total} alerts in {len(counts)} files")
    else:
        unittest.main()

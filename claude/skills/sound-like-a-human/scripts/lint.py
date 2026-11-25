#!/usr/bin/env python3
"""Lint the user's writing with Vale. Python standard library only.

The rules live in vale/styles/Voice (one .yml per rule, each with its own
tests). This script is the one command the skill, the evals and the hooks
name: it runs Vale with the skill's own config (never a repo's .vale.ini),
prints the alerts in a fixed format, and adds the keep-word check, which
Vale cannot do because it needs two inputs.

Usage:
  lint.py draft.md                 lint a file
  lint.py --text "..."             lint inline text
  lint.py --type social draft.md   social register (numerals on, paragraph rule off)
  lint.py --before notes.md draft.md
                                   also flag keep-words that review removed

Exit 1 if any error-level rule fires, 2 if Vale could not run, else 0.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys

SKILL = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
VALE_INI = os.path.join(SKILL, "vale", "vale.ini")
STYLE_DIR = os.path.join(SKILL, "vale", "styles", "Voice")
MIN_VALE = (3, 25)  # rule tests (3.24) and the metric scopes the rules use

# Words the user keeps. Review must not remove them (see --before).
KEEP_WORDS = [
    "cards", "stories", "tests", "checks", "spikes", "refine", "ship",
    "harness", "setup", "till", "quite", "folks", "learnt",
]


class ValeProblem(Exception):
    """Vale is missing, too old, or a rule is broken. Message says what, where, why, fix."""


def problem(what, where, why, fix):
    return ValeProblem(f"ERROR: {what}\n  where: {where}\n  why:   {why}\n  fix:   {fix}")


def vale_version(vale):
    out = subprocess.run([vale, "--version"], capture_output=True, text=True).stdout
    m = re.search(r"(\d+)\.(\d+)\.(\d+)", out)
    return tuple(int(x) for x in m.groups()) if m else None


def find_vale():
    vale = shutil.which("vale")
    if not vale:
        raise problem("Vale is not installed, so nothing was linted.", "scripts/lint.py",
                      "the writing rules run in Vale, and there is no Python fallback.",
                      "run `brew install vale` (or `brew bundle` in mac-setup), then re-run.")
    ver = vale_version(vale)
    if ver is None or ver < MIN_VALE:
        have = ".".join(map(str, ver)) if ver else "unknown"
        raise problem(f"Vale {have} is too old (need {'.'.join(map(str, MIN_VALE))} or newer).", vale,
                      "the rules use rule tests and metric scopes added in Vale 3.24 and 3.25.",
                      "run `brew upgrade vale`, then re-run.")
    return vale


def run_vale(vale, text, doc_type):
    """Run Vale on text and return its JSON alerts."""
    if not os.path.isfile(VALE_INI) or not os.path.isdir(STYLE_DIR):
        raise problem("The skill's Vale config or Voice style is missing.", os.path.relpath(VALE_INI),
                      "lint.py runs Vale with this config only.",
                      "restore vale/vale.ini and vale/styles/Voice from git (`git checkout -- vale`).")
    proc = subprocess.run(
        [vale, "--no-global", "--config", VALE_INI, "--output=JSON", f"--path={doc_type}/draft.md"],
        input=text, capture_output=True, text=True)
    if proc.returncode not in (0, 1):
        detail = (proc.stderr or proc.stdout).strip()
        m = re.search(r"[\w./-]+\.yml(?::\d+)?", detail)
        raise problem("Vale could not run.", m.group(0) if m else VALE_INI,
                      "a rule file or the config is invalid. Vale said:\n" + "\n".join("    " + ln for ln in detail.splitlines()),
                      "open that file at that line and fix it, then run `vale test vale/styles/Voice`.")
    try:
        data = json.loads(proc.stdout or "{}")
    except ValueError:
        raise problem("Vale printed output that is not JSON.", VALE_INI, "unexpected Vale output: " + proc.stdout[:200],
                      "run `vale --version`; if it works, re-run with a file to see Vale's own message.")
    return [a for alerts in data.values() for a in alerts]


def check(text, doc_type="post"):
    """Return [(line, level, rule, message, snippet)] sorted, like the old linter."""
    vale = find_vale()
    hits = [(a["Line"], a["Severity"], a["Check"], a["Message"], a["Match"]) for a in run_vale(vale, text, doc_type)]
    return sorted(hits)


def word_re(phrase):
    return re.compile(r"\b" + re.escape(phrase).replace(r"\ ", r"\s+") + r"\b", re.I)


def check_keep_words(before, after):
    hits = []
    for w in KEEP_WORDS:
        r = word_re(w)
        b, a = len(r.findall(before)), len(r.findall(after))
        if a < b:
            hits.append((0, "warning", "keep.removed", f'"{w}" appears {b} times before review, {a} after. The user keeps this word.', w))
    return hits


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("file", nargs="?")
    ap.add_argument("--text")
    ap.add_argument("--type", default="post", choices=["post", "doc", "slides", "email", "social"])
    ap.add_argument("--before", help="text before review, to check keep-words")
    args = ap.parse_args()

    if args.text is not None:
        text = args.text
    elif args.file:
        text = open(args.file, encoding="utf-8").read()
    else:
        text = sys.stdin.read()

    try:
        hits = check(text, args.type)
    except ValeProblem as exc:
        print(exc, file=sys.stderr)
        sys.exit(2)
    if args.before:
        hits += check_keep_words(open(args.before, encoding="utf-8").read(), text)

    order = {"error": 0, "warning": 1, "suggestion": 2}
    for line, level, rid, msg, snip in sorted(hits, key=lambda h: (h[0], order[h[1]])):
        print(f"{line:4d}  {level:10s} {rid:30s} {msg}  [{snip.strip()}]")
    counts = {lv: sum(1 for h in hits if h[1] == lv) for lv in order}
    print(f"\n{counts['error']} errors, {counts['warning']} warnings, {counts['suggestion']} suggestions")
    sys.exit(1 if counts["error"] else 0)


if __name__ == "__main__":
    main()

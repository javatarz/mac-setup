#!/usr/bin/env python3
# Deterministic pre-check for the review-writing skill. Regex only, so it
# catches the mechanical/lexical rules from SKILL.md; contextual rules
# (boast framing, scoped claims, negation setups, heading consistency, ...)
# still need the LLM review this complements rather than replaces.
#
# Usage:
#   score_review.py draft.md
#   score_review.py --text "paste a draft"
#
# Five groups, one point each. Exits 0 at 5/5, non-zero below it, so it
# works as a build gate ahead of the full skill review.

import argparse
import re
import sys

TIER1_VOCAB = [
    "delve", "tapestry", "testament to", "underscores", "seamless",
    "seamlessly", "robust", "navigate the landscape",
    "in today's fast-paced world", "it's important to note",
    "it's worth noting", "that being said", "at the end of the day",
    "unlock", "supercharge", "elevate", "game-changing",
    "revolutionise", "revolutionize", "harness the power of",
    "dive deep", "myriad", "plethora", "realm", "ever-evolving",
    "cutting-edge", "transformative", "paradigm shift", "synergy",
    "holistic", "embark",
]

TIER2_VOCAB = [
    "leverage", "foster", "crucial", "pivotal", "streamline",
    "empower", "showcase", "curated", "meticulous", "compelling",
    "innovative", "comprehensive", "journey", "solution",
    "effortless", "intuitive", "world-class", "best-in-class",
    "unleash", "boost",
]

CONSTRUCTIONS = [
    (r"\bnot just\b.{0,40}\bbut\b", "not just X, but Y"),
    (r"\bmore than just\b", "more than just X"),
    (r"\bwhether you'?re\b.{0,30}\bor\b", "whether you're X or Y"),
    (r"\bthat'?s where\b.{0,30}\bcomes? in\b", "that's where X comes in"),
    (r"\bsay goodbye to\b", "say goodbye to X"),
    (r"\bimagine a world where\b", "imagine a world where"),
    (r"\b(helps? you to|can help you)\b", "hedged benefit verb"),
    (r"\b(may potentially|could possibly|might possibly)\b", "stacked hedging"),
]

STOCK_IDIOMS = [
    "war stories", "move the needle", "low-hanging fruit",
    "at the end of the day", "boil the ocean", "think outside the box",
]

PROOF_PATTERN = re.compile(
    r"\b(trusted by|rated \d|[\d,]+\+?\s+(teams|users|customers|companies|developers)\b)",
    re.IGNORECASE,
)

MEETUP_PATTERN = re.compile(r"\bmeet-up\b", re.IGNORECASE)

REPEATED_QUALIFIER = re.compile(
    r"\b(the same|every|each)\b(\s+\S+){0,3},\s*\1\b", re.IGNORECASE
)

DASH_CHARS = re.compile(r"[–—]")  # en dash, em dash
HYPHEN_AS_DASH = re.compile(r"\s-\s")  # " - " joining clauses, not a hyphenated word
SYMBOLIC_APHORISM = re.compile(r"≠")  # ≠


def find_all(pattern, text, flags=re.IGNORECASE):
    if isinstance(pattern, str):
        pattern = re.compile(pattern, flags)
    return list(pattern.finditer(text))


def line_of(text, pos):
    return text.count("\n", 0, pos) + 1


def word_boundary(phrase):
    return r"\b" + re.escape(phrase).replace(r"\ ", r"\s+") + r"\b"


def check_vocabulary(text):
    hits = []
    for word in TIER1_VOCAB + TIER2_VOCAB:
        for m in find_all(word_boundary(word), text):
            hits.append((line_of(text, m.start()), word, m.group(0)))
    return hits


def check_constructions(text):
    hits = []
    for pattern, label in CONSTRUCTIONS:
        for m in find_all(pattern, text):
            hits.append((line_of(text, m.start()), label, m.group(0)))
    return hits


def check_punctuation(text):
    hits = []
    for m in find_all(DASH_CHARS, text):
        hits.append((line_of(text, m.start()), "em/en dash character", m.group(0)))
    for m in find_all(HYPHEN_AS_DASH, text):
        hits.append((line_of(text, m.start()), "hyphen used as dash connector", m.group(0)))
    for m in find_all(SYMBOLIC_APHORISM, text):
        hits.append((line_of(text, m.start()), "symbolic aphorism (≠)", m.group(0)))
    return hits


def check_rhythm(text):
    hits = []
    for m in find_all(REPEATED_QUALIFIER, text):
        hits.append((line_of(text, m.start()), "qualifier repeated across list", m.group(0)))
    for m in find_all(MEETUP_PATTERN, text):
        hits.append((line_of(text, m.start()), "meetup spelling", m.group(0)))
    return hits


def check_content(text):
    hits = []
    for m in find_all(PROOF_PATTERN, text):
        hits.append((line_of(text, m.start()), "unverified proof claim", m.group(0)))
    for idiom in STOCK_IDIOMS:
        for m in find_all(word_boundary(idiom), text):
            hits.append((line_of(text, m.start()), "stock idiom", m.group(0)))
    return hits


GROUPS = [
    ("vocabulary", "Banned vocabulary", check_vocabulary),
    ("constructions", "AI construction shapes", check_constructions),
    ("punctuation", "Dash / symbolic-aphorism tells", check_punctuation),
    ("rhythm", "Repeated qualifiers / spelling", check_rhythm),
    ("content", "Invented proof / stock idioms", check_content),
]


def score(text):
    results = {}
    points = 0
    for key, label, fn in GROUPS:
        hits = fn(text)
        results[key] = (label, hits)
        if not hits:
            points += 1
    return points, results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", nargs="?", help="path to a draft file")
    parser.add_argument("--text", help="draft text passed inline")
    args = parser.parse_args()

    if args.text is not None:
        text = args.text
    elif args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            text = f.read()
    else:
        text = sys.stdin.read()

    if not text.strip():
        print("error: empty input", file=sys.stderr)
        sys.exit(2)

    points, results = score(text)

    for key, label, fn in GROUPS:
        group_label, hits = results[key]
        if hits:
            print(f"[FAIL] {group_label} ({len(hits)} hit(s)):")
            for line_no, tag, snippet in hits[:10]:
                print(f"  line {line_no}: {tag} — {snippet!r}")
            if len(hits) > 10:
                print(f"  ... and {len(hits) - 10} more")
        else:
            print(f"[OK]   {group_label}")

    print(f"\nScore: {points}/{len(GROUPS)}")

    if points < len(GROUPS):
        print("Below 5/5 — run the full review-writing skill before shipping.")
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()

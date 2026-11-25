#!/usr/bin/env python3
"""Deterministic lint for the user's writing. Stdlib only.

Holds every rule that a word list, regex, or count can check, so the skill
prompt doesn't have to. Stopgap until Vale is approved (Phase 3); each rule
maps to a Vale existence, substitution, or occurrence rule.

Usage:
  lint.py draft.md                 lint a file
  lint.py --text "..."             lint inline text
  lint.py --type social draft.md   social register (skips paragraph rule)
  lint.py --before notes.md draft.md
                                   also flag keep-words that review removed

Exit 1 if any error-level rule fires, else 0.
"""

import argparse
import re
import sys

# ---------------------------------------------------------------- rule data

TIER1_VOCAB = [
    "delve", "tapestry", "testament to", "underscores", "seamless",
    "seamlessly", "robust", "navigate the landscape",
    "in today's fast-paced world", "it's important to note",
    "it's worth noting", "that being said", "at the end of the day",
    "unlock", "supercharge", "elevate", "game-changing", "revolutionise",
    "revolutionize", "harness the power of", "dive deep", "myriad",
    "plethora", "realm", "ever-evolving", "cutting-edge", "transformative",
    "paradigm shift", "synergy", "holistic", "embark",
]

TIER2_VOCAB = [  # fine once, flagged from the second use
    "leverage", "foster", "crucial", "pivotal", "streamline", "empower",
    "showcase", "curated", "meticulous", "compelling", "innovative",
    "comprehensive", "journey", "solution", "effortless", "intuitive",
    "world-class", "best-in-class", "unleash", "boost",
]

STOCK_IDIOMS = [
    "war stories", "move the needle", "low-hanging fruit", "boil the ocean",
    "think outside the box", "paint a clear picture", "paint a picture",
]

# Words the user keeps. Review must not remove them (see --before).
KEEP_WORDS = [
    "cards", "stories", "tests", "checks", "spikes", "refine", "ship",
    "harness", "setup", "till", "quite", "folks", "learnt",
]

# British spelling: American form -> British form. Stems cover -e/-es/-ed/-ing.
BRITISH = {
    "organiz": "organis", "optimiz": "optimis", "prioritiz": "prioritis",
    "realiz": "realis", "recogniz": "recognis", "summariz": "summaris",
    "standardiz": "standardis", "customiz": "customis", "normaliz": "normalis",
    "minimiz": "minimis", "maximiz": "maximis", "categoriz": "categoris",
    "emphasiz": "emphasis", "apologiz": "apologis", "utiliz": "utilis",
    "authoriz": "authoris", "visualiz": "visualis", "initializ": "initialis",
    "serializ": "serialis", "containeriz": "containeris", "modulariz": "modularis",
    "analyz": "analys",
}
BRITISH_WORDS = {
    "behavior": "behaviour", "color": "colour", "favorite": "favourite",
    "center": "centre", "honor": "honour", "labor": "labour",
    "neighbor": "neighbour", "flavor": "flavour", "catalog": "catalogue",
    "modeling": "modelling", "labeled": "labelled", "labeling": "labelling",
    "canceled": "cancelled", "canceling": "cancelling", "traveled": "travelled",
    "fulfill": "fulfil", "enroll": "enrol", "defense": "defence",
    "offense": "offence", "gray": "grey",
}

# (id, level, regex, message, case_sensitive)
# level: error = must fix; warning = fix unless there's a reason; suggestion = look at it
RULES = [
    # Indian English: errors and personal reject list (voice.md, usage-rule-test.md)
    ("usage.off-of", "error", r"\boff of\b", 'Use "off", "from", "by" or "based on", not "off of".', False),
    ("usage.lets", "error", r"\bLets\b(?! (?:you|us|them|me|him|her|it|the|a|an)\b)", 'Use "Let\'s".', True),
    ("usage.its-own", "error", r"\bit's own\b", 'Use "its own".', False),
    ("usage.where-as", "error", r"\bwhere as\b", 'Use "whereas".', False),
    ("usage.responsible-to", "warning", r"\bresponsible to (?!(?:the|a|an|your|our|their|my|his|her|its|whoever|whom)\b)\w+",
     'Use "responsible for" + -ing ("responsible for keeping time").', False),
    ("usage.may-be", "suggestion", r"(?:^|(?<=[.!?]\s))May be\b|\bmay be even\b",
     'If this means "perhaps", write "maybe".', True),
    ("usage.ish", "error", r"\b\d+ish\b|\b\w+-ish\b|\b(?:late|early|soon|ok|okay|maybe|sort)ish\b",
     'Avoid "-ish". Give the number or say "about" once.', False),
    ("usage.prepone", "error", r"\bprepon\w*", 'Use "bring forward".', False),
    ("usage.gotten", "error", r"\bgotten\b", 'Use "got" (British).', False),
    ("usage.meetup", "error", r"\bmeet-ups?\b", 'Use "meetup".', False),
    ("usage.groom", "warning", r"\bgroom(?:ing|ed)?\b", 'Use "refine" / "refinement".', False),

    # Punctuation
    ("punct.dash", "error", r"[–—]", "No em or en dashes. Use a full stop, comma, colon or parentheses.", True),
    ("punct.hyphen-as-dash", "error", r"(?<=\S)[ \t]-[ \t]", "Hyphen used as a dash. Use a full stop, comma or colon.", True),
    ("punct.exclamation", "error", r"(?<=\w)!(?=\s|$|\))", 'No "!" in drafts. The user adds one if they want it.', True),
    ("punct.emoticon", "error", r"(?<![\w(])(?::-?\)|:-?D\b|:-?P\b|;-?\)|:-?\()", "No emoticons in drafts.", True),
    ("punct.not-equal", "error", r"≠", "Symbolic aphorism. Say the literal claim.", True),
    # Serial comma, two strengths. 3+ items without the comma is near-certain;
    # "A, B and C" can be a clause, so it is only a suggestion.
    ("punct.serial-comma", "warning", r"\b[\w'-]+, [\w'-]+(?: [\w'-]+)?, (?:[\w'-]+ ){0,2}[\w'-]+ (?:and|or) [\w'-]+",
     'Serial comma: "tests, lint, and review".', False),
    ("punct.serial-comma-maybe", "suggestion",
     r"\b(?!(?:however|so|then|also|now|yes|no|well|first|second|finally|thus|again|today|here|there)\b)[\w'-]+, "
     r"(?!(?:is|was|are|were|be|been|has|had|have|made|gotten|got|which|who|that|but|it|this|they|we|you|i|he|she)\b)"
     r"[\w'-]+(?: [\w'-]+)? (?:and|or) [\w'-]+",
     'If this is a list, add the serial comma: "tests, lint, and review".', False),

    # Branding (project CLAUDE.md)
    ("brand.ie", "error", r"\biE\b", 'Spell out "intelligent Engineering".', True),
    ("brand.intelligent-engineering", "error",
     r"\b(?:Intelligent [Ee]ngineering|intelligent engineering|INTELLIGENT ENGINEERING)\b",
     'Write "intelligent Engineering" (lowercase i, capital E), even at the start of a sentence.', True),
    ("brand.emerge", "suggestion", r"\bEmerge\b", 'If this is the event series, write "emerge" (lowercase).', True),

    # Stance and numbers (voice.md)
    ("stance.hedge", "error", r"\b(?:I feel|I think|IMO|IMHO|in my opinion|I believe)\b",
     "State the stance plainly. Scope it with probably/might/chances are if needed.", False),
    ("numbers.about", "suggestion", r"\b(?:about|around|roughly|approximately|~) ?\$?\d",
     "Give the exact number if you have it.", False),

    # AI construction shapes (review-writing audit rules 15 to 21, 27, 40, 43)
    ("ai.not-just", "error", r"\bnot just\b.{0,40}\bbut\b|\bmore than just\b", "Cut the throwaway half; keep the claim.", False),
    ("ai.whether-youre", "error", r"\bwhether you'?re\b.{0,30}\bor\b", "Name the one reader you're writing for.", False),
    ("ai.comes-in", "error", r"\bthat'?s where\b.{0,30}\bcomes? in\b", "Say what X does.", False),
    ("ai.say-goodbye", "error", r"\bsay goodbye to\b", "Name what replaces it.", False),
    ("ai.imagine-world", "error", r"\bimagine a world\b", "Show the thing instead of staging it.", False),
    ("ai.hedged-benefit", "error", r"\b(?:helps? you to|can help you)\b", "Use one direct verb.", False),
    ("ai.stacked-hedge", "error", r"\b(?:may potentially|could possibly|might possibly)\b", "One hedge at most.", False),
    ("ai.isnt-its", "warning", r"\bisn'?t (?:just |about )?[\w' ]{1,30}[.,;] (?:it'?s|it is)\b", "Negation setup. Say the real point.", False),
    ("ai.anyone-can", "error", r"\banyone can\b", 'Say the easy part plainly ("X is the easy part").', False),
    ("ai.repeated-qualifier", "warning", r"\b(the same|every|each)\b(?:\s+\S+){0,3},\s*\1\b", "State the qualifier once.", False),
    ("ai.self-answer", "warning", r"(?:^|(?<=[.!]\s))The (?:result|answer|catch|twist|kicker|outcome)\?", "Self-answering question. State it plainly.", False),
    ("ai.setup-line", "warning", r"\b(?:Here'?s|Here is) (?:the|my|an?) (?:thing|point|caveat|catch|gap|truth|kicker)\b|\b(?:Worth noting|It'?s worth mentioning|Note that|The point is this)\b",
     "Empty setup line. Delete it if the next sentence carries the content.", False),
    ("content.proof", "error", r"\b(?:trusted by|rated \d|\d[\d,]*\+?\s+(?:teams|users|customers|companies|developers)\b)",
     "Proof claim. Keep only if true and checkable; else mark [needs number].", False),
]

MAX_SENTENCE_WORDS = 30

# ---------------------------------------------------------------- text prep


def strip_markup(text):
    """Blank out things prose rules shouldn't see, keeping line numbers."""
    def blank(m):
        return re.sub(r"[^\n]", " ", m.group(0))
    text = re.sub(r"\A---\n.*?\n---\n", blank, text, flags=re.S)          # frontmatter
    text = re.sub(r"^(```|~~~).*?^\1[^\n]*$", blank, text, flags=re.S | re.M)  # fenced code
    text = re.sub(r"`[^`\n]+`", blank, text)                              # inline code
    text = re.sub(r"<!--.*?-->", blank, text, flags=re.S)                 # comments
    text = re.sub(r"!\[[^\]]*\]\([^)]*\)", blank, text)                   # images
    text = re.sub(r"\]\([^)]*\)", lambda m: "]" + " " * (len(m.group(0)) - 1), text)  # link targets
    text = re.sub(r"https?://\S+", blank, text)                           # bare URLs
    return text


def line_of(text, pos):
    return text.count("\n", 0, pos) + 1


def prose_paragraphs(text):
    """Yield (start_offset, paragraph) for prose paragraphs only."""
    for m in re.finditer(r"(?:[^\n]+\n?)+", text):
        p = m.group(0).strip()
        if not p:
            continue
        first = p.lstrip()
        if first.startswith(("#", "|", ">", "-", "*", "+", "<")) or re.match(r"\d+[.)] ", first):
            continue
        yield m.start(), p


def sentences(paragraph):
    flat = re.sub(r"\s+", " ", paragraph)
    flat = re.sub(r"\b(e\.g|i\.e|etc|vs|Dr|Mr|Ms|Mrs)\.", lambda m: m.group(0).replace(".", "․"), flat)
    return [s for s in re.split(r"(?<=[.!?])\s+(?=[A-Z0-9\"'(])", flat) if s.strip()]


# ---------------------------------------------------------------- checks


def word_re(phrase):
    return re.compile(r"\b" + re.escape(phrase).replace(r"\ ", r"\s+") + r"\b", re.I)


def check(text, doc_type="post"):
    hits = []  # (line, level, rule, message, snippet)
    clean = strip_markup(text)

    for rid, level, pat, msg, cs in RULES:
        if rid == "punct.hyphen-as-dash":
            # don't flag markdown bullets or table separators
            for m in re.finditer(pat, clean):
                line_start = clean.rfind("\n", 0, m.start()) + 1
                if clean[line_start:m.start() + 1].lstrip().startswith("|"):
                    continue
                hits.append((line_of(clean, m.start()), level, rid, msg, m.group(0)))
            continue
        for m in re.finditer(pat, clean, 0 if cs else re.I | re.M):
            hits.append((line_of(clean, m.start()), level, rid, msg, m.group(0)))

    for w in TIER1_VOCAB:
        for m in word_re(w).finditer(clean):
            hits.append((line_of(clean, m.start()), "error", "vocab.banned", f'Banned word "{w}". Use a plain word.', m.group(0)))
    for w in TIER2_VOCAB:
        ms = list(word_re(w).finditer(clean))
        if len(ms) > 1:
            m = ms[1]
            hits.append((line_of(clean, m.start()), "warning", "vocab.repeated", f'"{w}" used {len(ms)} times. Fine once.', m.group(0)))
    for w in STOCK_IDIOMS:
        for m in word_re(w).finditer(clean):
            hits.append((line_of(clean, m.start()), "error", "vocab.idiom", "Stock idiom. Name the actual thing.", m.group(0)))

    for us, gb in BRITISH.items():
        for m in re.finditer(r"\b\w*" + us + r"(?:e|es|ed|ing|er|ers|ation|ations)\b", clean, re.I):
            hits.append((line_of(clean, m.start()), "warning", "spelling.british", f'British spelling: "{us}" -> "{gb}".', m.group(0)))
    for us, gb in BRITISH_WORDS.items():
        for m in re.finditer(r"\b" + us + r"s?\b", clean, re.I):
            hits.append((line_of(clean, m.start()), "warning", "spelling.british", f'British spelling: "{gb}".', m.group(0)))

    for start, para in prose_paragraphs(clean):
        ss = sentences(para)
        for s in ss:
            n = len(s.split())
            if n > MAX_SENTENCE_WORDS:
                hits.append((line_of(clean, start), "warning", "shape.long-sentence", f"{n} words. Split it (max {MAX_SENTENCE_WORDS}).", s[:60] + "..."))
        if doc_type in ("post", "doc") and len(ss) == 1 and not para.rstrip().endswith(":"):
            hits.append((line_of(clean, start), "warning", "shape.one-sentence-paragraph", "One-sentence paragraph. Fold it into a neighbour.", para[:60]))

    return sorted(hits)


def check_keep_words(before, after):
    hits = []
    for w in KEEP_WORDS:
        r = word_re(w)
        b, a = len(r.findall(before)), len(r.findall(after))
        if a < b:
            hits.append((0, "warning", "keep.removed", f'"{w}" appears {b} times before review, {a} after. The user keeps this word.', w))
    return hits


# ---------------------------------------------------------------- main


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

    hits = check(text, args.type)
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

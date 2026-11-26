"""Privacy guard: this skill lives in a PUBLIC repo, and it is used for emails
and client documents, so private details can leak into evals, pairs,
or examples. This test scans every text file in the skill folder and fails on:

- email addresses and phone numbers (everywhere, including the blog fixtures)
- URLs whose host is not on ALLOWED_HOSTS
- any term in an optional private denylist kept OUTSIDE the repo: the file at
  $SOUND_LIKE_A_HUMAN_PRIVATE_TERMS, or ~/.config/sound-like-a-human/private-terms.txt.
  One term per line, matched case-insensitively as a whole word. Blank lines and
  lines starting with # are ignored. If the file is missing, that check is skipped.

The blog fixtures (tests/fixtures/corpus-pre-2022) are the user's published
posts, so only the email and phone checks run on them.

Never put real client names in this repo, in a test, or in the README. The
unit tests below use made-up values.
"""
import os
import re
import sys
import unittest

sys.dont_write_bytecode = True  # never leave __pycache__ in the repo

HERE = os.path.dirname(os.path.abspath(__file__))
SKILL = os.path.normpath(os.path.join(HERE, ".."))
CORPUS = os.path.join(HERE, "fixtures", "corpus-pre-2022")
sys.path.insert(0, HERE)
from runner import rel  # noqa: E402

TEXT_EXTENSIONS = {".md", ".py", ".sh", ".json", ".txt", ".yml", ".yaml", ".toml", ".ini"}
# Under vale/styles, only our own style and config are scanned. Anything else is a
# package written by `vale sync` (gitignored, other people's text with their own links).
VALE_STYLES = os.path.join(SKILL, "vale", "styles")
OWN_VALE_DIRS = {"Voice", "config"}
ALLOWED_HOSTS = ("karun.me", "code.claude.com", "github.com", "raw.githubusercontent.com")
DEFAULT_TERMS_FILE = os.path.expanduser("~/.config/sound-like-a-human/private-terms.txt")

EMAIL = re.compile(r"[A-Za-z0-9._%+-]{1,64}@[A-Za-z0-9-]{1,63}(?:\.[A-Za-z0-9-]{1,63})*\.[A-Za-z]{2,}")
PHONE = re.compile(
    r"(?<![\w.])(?:\+\d{1,3}[ .-]?)?(?:\(\d{2,4}\)[ .-]?|\d{2,4}[ .-])\d{3,4}[ .-]\d{3,4}(?![\w-])"
)
URL = re.compile(r"https?://([^/\s:?#)>\"'\]]+)", re.IGNORECASE)

WHY = "This repo is public, so private details here would be published."
FIX = {
    "email address": "remove it or write [email]",
    "phone number": "remove it or write [phone]",
    "URL host": "remove the URL, or add the host to ALLOWED_HOSTS in tests/test_privacy.py if it is public",
    "private term": "replace it with a neutral placeholder such as 'a client' or '[person]', or drop the entry",
}


def terms_path():
    return os.environ.get("SOUND_LIKE_A_HUMAN_PRIVATE_TERMS") or DEFAULT_TERMS_FILE


def load_terms(path):
    """Return the list of denylist terms, or None when the file is missing."""
    if not os.path.isfile(path):
        return None
    with open(path, encoding="utf-8") as f:
        lines = [ln.strip() for ln in f]
    return [ln for ln in lines if ln and not ln.startswith("#")]


def host_allowed(host):
    host = host.lower().rstrip(".")
    return any(host == h or host.endswith("." + h) for h in ALLOWED_HOSTS)


def scan_text(text, terms=(), urls=True):
    """Return [(line_number, kind, matched_text)] for one file's text.

    A private-term hit reports the denylist line number, not the term, so a
    failure message never copies the private text into logs.
    """
    term_res = [(i, re.compile(r"(?<!\w)" + re.escape(t) + r"(?!\w)", re.IGNORECASE))
                for i, t in enumerate(terms, 1)]
    hits = []
    for n, line in enumerate(text.splitlines(), 1):
        hits += [(n, "email address", m.group()) for m in EMAIL.finditer(line)]
        hits += [(n, "phone number", m.group()) for m in PHONE.finditer(line)]
        if urls:
            hits += [(n, "URL host", m.group(1)) for m in URL.finditer(line) if not host_allowed(m.group(1))]
        hits += [(n, "private term", f"entry {i} of the private terms file")
                 for i, rx in term_res if rx.search(line)]
    return hits


def skip_dir(root, name):
    if name in {".git", "__pycache__"}:
        return True
    if root == os.path.join(VALE_STYLES, "config") and name == "dictionaries":
        return True  # the vendored en_GB dictionary and its README are third-party; the Skill vocabulary is scanned
    return root == VALE_STYLES and name not in OWN_VALE_DIRS


def skill_files():
    for root, dirs, files in os.walk(SKILL):
        dirs[:] = sorted(d for d in dirs if not skip_dir(root, d))
        for name in sorted(files):
            if os.path.splitext(name)[1].lower() in TEXT_EXTENSIONS:
                yield os.path.join(root, name)


def scan_skill(terms=()):
    problems = []
    for path in skill_files():
        in_corpus = path.startswith(CORPUS + os.sep)
        with open(path, encoding="utf-8", errors="replace") as f:
            text = f.read()
        hits = scan_text(text, (), urls=False) if in_corpus else scan_text(text, terms)
        for n, kind, what in hits:
            problems.append(f"{rel(path)}:{n}: {kind} ({what})\n"
                            f"    why: {WHY}\n    fix: {FIX[kind]}")
    return problems


class TestPrivacyScanner(unittest.TestCase):
    """Made-up values only. Pieces are joined so this file does not match itself."""

    def test_email(self):
        text = "write to " + "jane.doe" + "@" + "example" + ".test please"
        self.assertEqual([h[:2] for h in scan_text(text)], [(1, "email address")])

    def test_phone(self):
        for number in ("+44 20 7946 " + "0958", "555-010-" + "9999", "(555) 010-" + "9999"):
            self.assertEqual([h[1] for h in scan_text("call " + number)], ["phone number"], number)

    def test_dates_and_versions_are_not_phones(self):
        self.assertEqual(scan_text("decided 2026-11-24, version 1.2.3, 99.951% and 250+MB"), [])

    def test_url_allowlist(self):
        ok = "see https://code.claude.com/docs/en/x and https://github.com/a/b and https://www.karun.me/p"
        self.assertEqual(scan_text(ok), [])
        bad = scan_text("see " + "https" + "://wiki." + "client-co" + ".test/page")
        self.assertEqual([h[1] for h in bad], ["URL host"])

    def test_lookalike_host_is_blocked(self):
        self.assertEqual([h[1] for h in scan_text("https://karun.me" + ".evil.test/x")], ["URL host"])

    def test_denylist_whole_word_case_insensitive(self):
        terms = ["Acme" + "Corp"]
        self.assertEqual([h[:2] for h in scan_text("An " + "acmecorp" + " project", terms)], [(1, "private term")])
        self.assertEqual(scan_text("An " + "acmecorps" + " project", terms), [])

    def test_denylist_failure_does_not_echo_the_term(self):
        hit = scan_text("x " + "SecretName" + " y", ["SecretName"])[0]
        self.assertNotIn("secretname", hit[2].lower())

    def test_vale_config_and_rules_are_scanned_but_synced_packages_are_not(self):
        scanned = [rel(p) for p in skill_files()]
        self.assertTrue(any(p.endswith(os.path.join("vale", "vale.ini")) for p in scanned), "vale.ini must be scanned")
        self.assertTrue(any(os.path.join("styles", "Voice") in p and p.endswith(".yml") for p in scanned),
                        "Voice rule files must be scanned")
        self.assertTrue(skip_dir(VALE_STYLES, "ai-tells"))
        self.assertTrue(skip_dir(VALE_STYLES, ".vale-config"))
        for vendored in ("Voices", "Direct", "Human", "Std"):
            self.assertTrue(skip_dir(VALE_STYLES, vendored))
        self.assertTrue(skip_dir(os.path.join(VALE_STYLES, "config"), "dictionaries"))
        self.assertFalse(skip_dir(os.path.join(VALE_STYLES, "config"), "vocabularies"))
        self.assertFalse(skip_dir(VALE_STYLES, "Voice"))
        self.assertFalse(skip_dir(os.path.join(SKILL, "tests"), "ai-tells"))

    def test_corpus_mode_skips_urls(self):
        self.assertEqual(scan_text("see " + "https" + "://anything.example/x", urls=False), [])


class TestSkillFolderIsPublicSafe(unittest.TestCase):
    def test_no_private_details(self):
        path = terms_path()
        terms = load_terms(path)
        if terms is None:
            sys.stderr.write(f"note: private-terms check skipped, no file at {path} "
                             "(set SOUND_LIKE_A_HUMAN_PRIVATE_TERMS or create it to enable)\n")
            terms = ()
        problems = scan_skill(terms)
        if problems:
            self.fail(f"{len(problems)} private-looking detail(s) in a PUBLIC repo:\n" + "\n".join(problems))


class TestNoCorrectionsLogInRepo(unittest.TestCase):
    def test_log_lives_outside_the_repo(self):
        found = [rel(os.path.join(root, n)) for root, _, names in os.walk(SKILL)
                 for n in names if n == "corrections.md"]
        if found:
            self.fail("corrections.md must not be in this skill folder:\n"
                      + "\n".join(f"{f}\n    why: {WHY} The raw log can hold client names.\n"
                                   "    fix: move it to ~/.config/sound-like-a-human/corrections.md" for f in found))


if __name__ == "__main__":
    unittest.main()

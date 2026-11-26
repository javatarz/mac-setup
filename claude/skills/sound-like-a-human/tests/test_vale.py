"""Tests for the Vale rules in vale/styles/Voice.

1. `vale test --coverage` runs the `tests:` cases kept inside each rule file and
   fails if a rule has none, so a rule that matches nothing cannot sit unnoticed.
2. Per-type switches in vale/vale.ini: numerals only on social posts, no
   paragraph-count rule on social, email or slides.
3. The wrapper's failure messages when Vale is missing or a rule is broken.
"""
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True  # never leave __pycache__ in the repo

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, "..", "scripts")))
import lint  # noqa: E402
from runner import rel  # noqa: E402


class ValeRuleCases(unittest.TestCase):
    def test_rule_cases_pass_and_every_rule_has_one(self):
        vale = lint.find_vale()  # fails with the install message when Vale is missing
        proc = subprocess.run([vale, "--no-global", "--config", lint.VALE_INI, "test", "--coverage", lint.STYLE_DIR],
                              capture_output=True, text=True)
        if proc.returncode != 0:
            self.fail(
                "VALE RULE CASE FAILED\n"
                + "\n".join("  " + ln for ln in (proc.stdout + proc.stderr).strip().splitlines())
                + f"\n  where: the file named after 'from' above, under {rel(lint.STYLE_DIR)}\n"
                "  why:   a rule no longer behaves as its tests: case says, or a rule has no case.\n"
                "  fix:   restore the rule, or edit its tests: case if the change was meant.\n"
                f"         Re-run just this: vale --no-global --config {rel(lint.VALE_INI)} test --coverage {rel(lint.STYLE_DIR)}"
            )


def rules_for(text, doc_type):
    return {h[2] for h in lint.check(text, doc_type)}


class PerTypeSwitches(unittest.TestCase):
    def check_type(self, text, doc_type, rule, want):
        got = rule in rules_for(text, doc_type)
        if got != want:
            self.fail(
                f"VALE TYPE SWITCH BROKE: {rule} on type {doc_type}\n"
                f"  text:  {text!r}\n"
                f"  expected {'an alert' if want else 'no alert'}, got {'an alert' if got else 'no alert'}\n"
                f"  where: {rel(lint.VALE_INI)} (the [*.md], [social/*.md] and [{{social,email,slides}}/*.md] sections)\n"
                "  why:   the per-type override no longer applies.\n"
                "  fix:   restore the override in vale/vale.ini, or edit this test if the change was meant."
            )

    def test_numerals_warn_on_social_and_suggest_elsewhere(self):
        text = "We ran three tests."
        self.check_type(text, "social", "Voice.NumeralsSocial", True)
        self.check_type(text, "social", "Voice.Numerals", False)
        for t in ("post", "doc", "email", "slides"):
            self.check_type(text, t, "Voice.Numerals", True)
            self.check_type(text, t, "Voice.NumeralsSocial", False)
        levels = {h[2]: h[1] for t in ("social", "post") for h in lint.check(text, t)}
        self.assertEqual(levels["Voice.NumeralsSocial"], "warning")
        self.assertEqual(levels["Voice.Numerals"], "suggestion")

    def test_sentence_initial_numbers_flagged_on_social_only(self):
        self.check_type("Three tests failed.", "social", "Voice.NumeralsSocial", True)
        for t in ("post", "doc", "email", "slides"):
            self.check_type("Three tests failed.", t, "Voice.Numerals", False)

    def test_numerals_leave_digits_and_pronoun_one_alone(self):
        for text in ("We ran 3 tests and 10 checks.", "No one knows. One of them broke.", "The one thing that matters.",
                     "Which one? The one I wrote.", "Ran 1 check.", "A zero-sum, one-on-one talk about the second try."):
            for t in ("social", "post"):
                for rule in ("Voice.Numerals", "Voice.NumeralsSocial", "Voice.NumeralOne"):
                    self.check_type(text, t, rule, False)

    def test_one_as_a_number_is_a_warning_on_social_and_a_suggestion_elsewhere(self):
        text = "We ran one check."
        got = {t: {h[2]: h[1] for h in lint.check(text, t)}.get("Voice.NumeralOne") for t in ("social", "post")}
        self.assertEqual(got, {"social": "warning", "post": "suggestion"})

    def test_heading_length_is_soft_and_skips_the_title(self):
        nine = "One two three four five six seven eight nine"
        self.check_type(f"## {nine}\n\nText here.", "post", "Voice.HeadingLength", True)
        self.check_type("## One two three four five six seven eight\n\nText here.", "post", "Voice.HeadingLength", False)
        self.check_type(f"# {nine}\n\nText here.", "post", "Voice.HeadingLength", False)
        self.check_type(f"<!-- vale Voice.HeadingLength = NO -->\n## {nine}\n\nText here.", "post", "Voice.HeadingLength", False)
        # the comment switches it off for that heading only
        two = f"<!-- vale Voice.HeadingLength = NO -->\n## {nine}\n\nText here.\n\n<!-- vale Voice.HeadingLength = YES -->\n## {nine}\n\nText here."
        self.assertEqual([h[0] for h in lint.check(two, "post") if h[2] == "Voice.HeadingLength"], [7])
        self.assertEqual(next(h[1] for h in lint.check(f"## {nine}\n\nText here.", "post") if h[2] == "Voice.HeadingLength"), "warning")

    def test_one_sentence_paragraph_only_on_long_form(self):
        text = "One alone.\n\nTwo here. And another."
        for t in ("post", "doc"):
            self.check_type(text, t, "Voice.OneSentenceParagraph", True)
        for t in ("social", "email", "slides"):
            self.check_type(text, t, "Voice.OneSentenceParagraph", False)

    def test_front_matter_and_code_are_not_linted(self):
        self.check_type("---\ntitle: A - B\n---\n\nA clean sentence here. And another one.", "post", "Voice.HyphenAsDash", False)
        self.check_type("Run `a — b` now. Then stop.\n\n```\nx - y — z\n```\n", "post", "Voice.Dash", False)


class WrapperFailureMessages(unittest.TestCase):
    def test_missing_vale_stops_with_install_command(self):
        with tempfile.TemporaryDirectory() as empty:
            old = os.environ["PATH"]
            os.environ["PATH"] = empty
            try:
                with self.assertRaises(lint.ValeProblem) as ctx:
                    lint.find_vale()
            finally:
                os.environ["PATH"] = old
        msg = str(ctx.exception)
        for part in ("not installed", "where:", "why:", "fix:", "brew install vale"):
            self.assertIn(part, msg)

    def test_broken_rule_is_reported_with_file_and_fix(self):
        vale = lint.find_vale()
        tmp = tempfile.mkdtemp()
        try:
            shutil.copytree(os.path.join(lint.SKILL, "vale"), os.path.join(tmp, "vale"))
            with open(os.path.join(tmp, "vale", "styles", "Voice", "Broken.yml"), "w") as f:
                f.write("extends: existence\nmessage: x\nlevel: error\nraw:\n  - '(unclosed'\n")
            saved = (lint.VALE_INI, lint.STYLE_DIR)
            lint.VALE_INI = os.path.join(tmp, "vale", "vale.ini")
            lint.STYLE_DIR = os.path.join(tmp, "vale", "styles", "Voice")
            try:
                with self.assertRaises(lint.ValeProblem) as ctx:
                    lint.run_vale(vale, "Some text.", "post")
            finally:
                lint.VALE_INI, lint.STYLE_DIR = saved
        finally:
            shutil.rmtree(tmp)
        msg = str(ctx.exception)
        for part in ("Vale could not run", "Broken.yml", "why:", "fix:"):
            self.assertIn(part, msg)


if __name__ == "__main__":
    unittest.main()

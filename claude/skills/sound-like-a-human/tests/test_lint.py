"""Unit tests for scripts/lint.py. Run: python3 -m unittest discover tests"""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts"))
import lint  # noqa: E402

# (test name, text, expected rule id, or None when the text must be clean)
CASES = [
    ("serial_comma_maybe_flagged", "We use tests, lint and review on every card.", "punct.serial-comma-maybe"),
    ("serial_comma_present_is_clean", "We use tests, lint, and review on every card.", None),
    ("serial_comma_missing_in_list_of_four", "Run unit, contract, integration and e2e tests.", "punct.serial-comma"),
    ("however_comma_is_clean", "However, it made things harder and harder.", None),
    ("off_of", "I'm going off of memory.", "usage.off-of"),
    ("lets_as_contraction", "Lets take a step back.", "usage.lets"),
    ("lets_as_verb_is_clean", "It lets you move fast. Lets you know.", None),
    ("responsible_to_verb", "The team is responsible to keep time.", "usage.responsible-to"),
    ("responsible_to_noun_is_clean", "The team is responsible to the board.", None),
    ("may_be_as_verb_is_clean", "It may be true.", None),
    ("may_be_as_maybe", "May be even AJAX.", "usage.may-be"),
    ("ish_suffix", "We merged 800ish PRs.", "usage.ish"),
    ("ish_inside_words_is_clean", "This is English and we finish and publish.", None),
    ("gotten", "It has gotten worse.", "usage.gotten"),
    ("prepone", "Can we prepone the call?", "usage.prepone"),
    ("till_folks_learnt_are_clean", "I'll wait till Monday, folks. Quite a few learnt it.", None),
    ("meetup_as_noun", "Meet at the meet-up.", "usage.meetup"),
    ("groom_backlog", "We groom the backlog.", "usage.groom"),
    ("em_dash", "Checks run fast — really fast.", "punct.dash"),
    ("hyphen_as_dash", "Coverage is theatre - we measured it.", "punct.hyphen-as-dash"),
    ("compound_hyphens_are_clean", "A well-known cross-post.", None),
    ("exclamation", "This is great!", "punct.exclamation"),
    ("emoticon", "Not surprising :)", "punct.emoticon"),
    ("parentheses_are_clean", "Call f(x) and see (a) and (b).", None),
    ("american_spelling_flagged", "We optimized the build.", "spelling.british"),
    ("british_spelling_is_clean", "We optimised the build and resized it.", None),
    ("brand_ie_lowercase_i", "iE is our framework.", "brand.ie"),
    ("brand_intelligent_engineering_capitalized", "Intelligent Engineering helps.", "brand.intelligent-engineering"),
    ("brand_intelligent_engineering_lowercase_i_is_clean", "intelligent Engineering helps.", None),
    ("hedge_i_think", "I think this works.", "stance.hedge"),
    ("about_with_number", "It took about 15 seconds.", "numbers.about"),
    ("not_just_but", "It's not just a tool, but a workflow.", "ai.not-just"),
    ("hedged_benefit", "This helps you to ship.", "ai.hedged-benefit"),
    ("anyone_can", "Anyone can wire the pipeline.", "ai.anyone-can"),
    ("self_answered_question", "The result? Faster shipping.", "ai.self-answer"),
    ("setup_line", "Here's the caveat: it breaks.", "ai.setup-line"),
    ("banned_vocab_delve", "We delve into it.", "vocab.banned"),
    ("harness_is_clean", "We harness agents with a harness.", None),
    ("social_proof", "Trusted by 500 teams.", "content.proof"),
    ("stock_idiom", "These war stories matter.", "vocab.idiom"),
    ("repeated_qualifier", "the same guardrails, the same review gates", "ai.repeated-qualifier"),
]


class LintRuleCases(unittest.TestCase):
    pass


def _make(text, want):
    def test(self):
        got = {h[2] for h in lint.check(text, "social")}
        if want:
            self.assertIn(want, got, f"{text!r}: got {sorted(got)}")
        else:
            self.assertEqual(got, set(), f"{text!r} should be clean")
    return test


for _name, _text, _want in CASES:
    setattr(LintRuleCases, f"test_{_name}", _make(_text, _want))


class LintShapeRules(unittest.TestCase):
    def test_one_sentence_paragraph_flagged_in_post(self):
        hits = lint.check("One sentence alone.\n\nTwo here. And another.\n", "post")
        self.assertIn("shape.one-sentence-paragraph", [h[2] for h in hits])

    def test_long_sentence_flagged(self):
        hits = lint.check(" ".join(["word"] * 31) + ". Short one.", "post")
        self.assertIn("shape.long-sentence", [h[2] for h in hits])

    def test_keep_word_removed_is_reported(self):
        hits = lint.check_keep_words("Run the tests and checks.", "Run the suite.")
        self.assertTrue(hits)
        self.assertTrue(all(h[2] == "keep.removed" for h in hits))


if __name__ == "__main__":
    unittest.main()

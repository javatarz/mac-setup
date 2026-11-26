"""Tests for scripts/lint.py, the wrapper that runs the Vale rules.

Each case runs the real wrapper (and so Vale). Run: tests/run.sh"""
import os
import sys
import unittest

sys.dont_write_bytecode = True  # never leave __pycache__ in the repo

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, "..", "scripts")))
import lint  # noqa: E402
from runner import rel  # noqa: E402

# (test name, text, expected rule id, or None when the text must be clean)
CASES = [
    ("serial_comma_maybe_flagged", "We use tests, lint and review on every card.", "Voice.SerialCommaMaybe"),
    ("serial_comma_present_is_clean", "We use tests, lint, and review on every card.", None),
    ("serial_comma_missing_in_list_of_four", "Run unit, contract, integration and e2e tests.", "Voice.SerialComma"),
    ("however_comma_is_clean", "However, it made things harder and harder.", None),
    ("off_of", "I'm going off of memory.", "Voice.Prefer"),
    ("lets_as_contraction", "Lets take a step back.", "Voice.Lets"),
    ("lets_as_verb_is_clean", "It lets you move fast. Lets you know.", None),
    ("responsible_to_verb", "The team is responsible to keep time.", "Voice.ResponsibleTo"),
    ("responsible_to_noun_is_clean", "The team is responsible to the board.", None),
    ("may_be_as_verb_is_clean", "It may be true.", None),
    ("may_be_as_maybe", "May be even AJAX.", "Voice.MayBe"),
    ("ish_suffix", "We merged 800ish PRs.", "Voice.Ish"),
    ("ish_inside_words_is_clean", "This is English and we finish and publish.", None),
    ("gotten", "It has gotten worse.", "Voice.Prefer"),
    ("prepone", "Can we prepone the call?", "Voice.Prefer"),
    ("till_folks_learnt_are_clean", "I'll wait till Monday, folks. Quite a few learnt it.", None),
    ("meetup_as_noun", "Meet at the meet-up.", "Voice.Prefer"),
    ("groom_backlog", "We groom the backlog.", "Voice.Prefer"),
    ("em_dash", "Checks run fast — really fast.", "ai-tells.EmDashUsage"),
    ("hyphen_as_dash", "Coverage is theatre - we measured it.", "Voice.HyphenAsDash"),
    ("compound_hyphens_are_clean", "A well-known cross-post.", None),
    ("exclamation", "This is great!", "Voice.Exclamation"),
    ("emoticon", "Not surprising :)", "Voice.Emoticon"),
    ("parentheses_are_clean", "Call f(x) and see (a) and (b).", None),
    ("american_spelling_flagged", "We optimized the build.", "Voice.Spelling"),
    ("british_spelling_is_clean", "We optimised the build and resized it.", None),
    ("brand_ie_lowercase_i", "iE is our framework.", "Vale.Avoid"),
    ("brand_intelligent_engineering_capitalized", "Intelligent Engineering helps.", "Vale.Terms"),
    ("brand_intelligent_engineering_lowercase_i_is_clean", "intelligent Engineering helps.", None),
    ("hedge_i_think", "I think this works.", "Voice.Hedge"),
    ("about_with_number", "It took about 15 seconds.", "Voice.About"),
    ("not_just_but", "It's not just a tool, but a workflow.", "Voices.BinaryContrast"),
    ("hedged_benefit", "This helps you to ship.", "Voice.HedgedBenefit"),
    ("anyone_can", "Anyone can wire the pipeline.", "Voice.AnyoneCan"),
    ("self_answered_question", "The result? Faster shipping.", "ai-tells.RhetoricalSelfAnswer"),
    ("setup_line", "Here's the caveat: it breaks.", "Voice.Phrases"),
    ("banned_vocab_delve", "We delve into it.", "Voice.Banned"),
    ("harness_is_clean", "We harness agents with a harness.", None),
    ("social_proof", "Trusted by 500 teams.", "Voice.Proof"),
    ("stock_idiom", "These war stories matter.", "Voice.Phrases"),
    ("serial_comma_one_word_items", "We store configurations, secrets and keys.", "Voice.SerialCommaMaybe"),
    ("serial_comma_one_word_items_price", "Look at availability, price and stability.", "Voice.SerialCommaMaybe"),
    ("serial_comma_multi_word_items", "It runs on cloud, non cloud providers and bare metal servers.", "Std.Punctuation.OxfordComma"),
    ("fine_once_word_clean", "This is a crucial step.", None),
    ("fine_once_word_second_use", "A crucial step.\n\nAnother crucial step.", "Voice.OnceCrucial"),
    ("fine_once_leverage_second_use", "We leverage it. We leveraged it again.", "Voice.OnceLeverage"),
    ("second_boost_flagged", "One boost here. A boost there.", "Voice.Once"),
    ("one_boost_is_clean", "One boost here.", None),
    ("accepted_words_are_clean", "The backend costs 2 lakh.", None),
    ("spelling_word_swap_gray", "A gray box.", "Voice.Prefer"),
    ("repeated_qualifier", "the same guardrails, the same review gates", "Voice.RepeatedQualifier"),
]


class LintRuleCases(unittest.TestCase):
    pass


def _case_line(name):
    """Line of the CASES entry in this file, so failures can point at it."""
    with open(__file__, encoding="utf-8") as f:
        for n, line in enumerate(f, 1):
            if line.lstrip().startswith(f'("{name}",'):
                return n
    return 0


def _make(name, text, want):
    def test(self):
        got = sorted({h[2] for h in lint.check(text, "social")})
        if (want in got) if want else not got:
            return
        expected = f"rule {want}" if want else "no alerts"
        self.fail(
            f"LINT CASE BROKE: {name}\n"
            f"  where: {rel(__file__)}:{_case_line(name)} (CASES entry); the rules are the .yml files in vale/styles/Voice, the vendored packages and vale.ini\n"
            f"  text:  {text!r}\n"
            f"  expected {expected}, got {got or 'no alerts'}\n"
            "  why:   the linter no longer behaves as this case specifies.\n"
            "  fix:   if the rule change was a mistake, restore the rule in vale/styles/Voice;\n"
            "         if the new behavior is intended, edit the case in tests/test_lint.py."
        )
    return test


for _name, _text, _want in CASES:
    setattr(LintRuleCases, f"test_{_name}", _make(_name, _text, _want))


class LintShapeRules(unittest.TestCase):
    def test_one_sentence_paragraph_flagged_in_post(self):
        hits = lint.check("One sentence alone.\n\nTwo here. And another.\n", "post")
        self.assertIn("Voice.OneSentenceParagraph", [h[2] for h in hits])

    def test_long_sentence_flagged(self):
        hits = lint.check(" ".join(["word"] * 31) + ". Short one.", "post")
        self.assertIn("Voice.LongSentence", [h[2] for h in hits])

    def test_keep_word_removed_is_reported(self):
        hits = lint.check_keep_words("Run the tests and checks.", "Run the suite.")
        self.assertTrue(hits)
        self.assertTrue(all(h[2] == "keep.removed" for h in hits))


if __name__ == "__main__":
    unittest.main()

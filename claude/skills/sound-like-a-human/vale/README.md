# Vale rules

The rules we wrote live in `styles/Voice`, one `.yml` per rule with its own `tests:` cases. Third-party rules are vendored (copied, not synced) into `styles/ai-tells`, `styles/Voices`, `styles/Direct`, `styles/Human` and `styles/Std`, with each package's licence. Do not edit them: `vendor.sh` replaces them from a pinned tag (`./vendor.sh`, or `./vendor.sh ai-tells v1.38.0`), and `git diff` shows what changed. `vale.ini` has no `Packages` line, so Vale never fetches anything. Each package is switched off as a whole and single rules are switched on in `vale.ini`; where a package rule fired on the user's own posts, `Voice/` holds a derived rule (`extends:` plus `tokens-`) that drops the offending words.

Spelling is the vendored en_GB dictionary (`Voice.Spelling`). The user's exceptions are in `styles/config/vocabularies/Skill/`: `accept.txt` (words en_GB flags that are right, and brand terms in their exact case) and `reject.txt` (`iE`). `scripts/lint.py` runs them with `vale.ini`. Run `vale --no-global --config vale/vale.ini test --coverage vale/styles/Voice` to test them.

## Where a rule applies

| Rule | Level | Types |
|---|---|---|
| `NeedsNumber` | warning | all |
| `ContrastHeading`, `PunchHeading` | warning | all |
| `HeadingLength` (h2 and below, 9 words or more) | warning | all |
| `Numerals` (2 to 10), `NumeralOne` | suggestion | all but social |
| `NumeralsSocial`, `NumeralOne` | warning | social |
| `ContrastBody`, `Aphorism`, `HeadingComma`, `HeadingRepeat`, `Triples`, `BoastRigour`, `BuzzWords`, `Aspirational`, `GenericWe`, `Consistent` | suggestion | all |
| `SoftBut`, `LinkTwice` | suggestion | social |
| `StageDirection` | suggestion | slides |
| `DecidedDate`, `DecidedReason` | suggestion | doc |

Switch `HeadingLength` off for one heading with `<!-- vale Voice.HeadingLength = NO -->` on the line before it. The h1 post title is never checked.

## Vendored rules that are on

Why each is on or off, with noise counts: `docs/wip/writing-system/vale-tuning.md` in the writing-system notes ("Vendored packages").

- `Voices`: Banned (derived as `Voice.Banned`), InflatedWords, BinaryContrast, ThroatClearing.
- `Direct`: Hedging; Length is `Voice.LongSentence` (limit 30).
- `Human`: Tics (derived as `Voice.Tics`, without "showcase").
- `Std`: Punctuation.OxfordComma (it also catches lists with multi-word items; `Voice.SerialComma` and `SerialCommaMaybe` are our own, restored because Std missed 7 of the user's lists).
- `ai-tells`: 45 rules, listed in `vale.ini`. `OverusedVocabulary`, `OverusedVocabularyVerbs` and `OpeningCliches` are the derived `Voice.*` versions.
- `Voice.Phrases`, `Voice.Once` and `Voice.Prefer` are the small custom word lists. `Voice.Once<Word>` (12 files) allows innovative, leverage, pivotal, empower, world-class, foster, meticulous, crucial, best-in-class, comprehensive, streamline and unleash once per piece and flags the second use. The vendored rules that flag every use of them are derived in `Voice/` without them.

## How the judgement rules were set

Each "partly checkable" rule was run over the user's 12 posts from 2016 to 2021 (about 7,900 words) before it shipped.

- Over 2 alerts per 1,000 words, or under half of sampled hits real: the rule stays in the prose. Passive voice, contractions, short sentences, and repeated words in a sentence did not pass. A punch word in body text did not pass either (3 hits, none a punch).
- 0.5 to 2 alerts per 1,000 words and at least half real: suggestion.
- Under 0.5 per 1,000 words: suggestion, or warning for headings, numerals on social and a leftover `[needs number]`, where the fix is mechanical.
- Rules for social posts, slides and docs have no matching posts in that corpus, so they ship as suggestions and were checked on test cases only.
- `OneSentenceParagraph` fires often on those posts (8.5 per 1,000 words) because it enforces a choice the user made after 2021. It is judged on precision only and stays. The serial comma is `SerialComma`, `SerialCommaMaybe` and `Std.Punctuation.OxfordComma`.

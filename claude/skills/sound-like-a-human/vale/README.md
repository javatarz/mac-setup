# Vale rules

The rules live in `styles/Voice`, one `.yml` per rule with its own `tests:` cases. `scripts/lint.py` runs them with `vale.ini`. Run `vale --no-global --config vale/vale.ini test --coverage vale/styles/Voice` to test them.

## Where a rule applies

| Rule | Level | Types |
|---|---|---|
| `NeedsNumber` | warning | all |
| `ContrastHeading`, `PunchHeading` | warning | all |
| `HeadingLength` (h2 and below, 9 words or more) | warning | all |
| `Numerals` (2 to 10), `NumeralOne` | suggestion | all but social |
| `NumeralsSocial`, `NumeralOne` | warning | social |
| `ContrastBody`, `Aphorism`, `HeadingComma`, `HeadingRepeat`, `Triples`, `BoastRigour`, `BuzzWords`, `Aspirational`, `GenericWe`, `SummaryMarker`, `Consistent` | suggestion | all |
| `SoftBut`, `LinkTwice` | suggestion | social |
| `StageDirection` | suggestion | slides |
| `DecidedDate`, `DecidedReason` | suggestion | doc |

Switch `HeadingLength` off for one heading with `<!-- vale Voice.HeadingLength = NO -->` on the line before it. The h1 post title is never checked.

## How the judgement rules were set

Each "partly checkable" rule was run over the user's 12 posts from 2016 to 2021 (about 7,900 words) before it shipped.

- Over 2 alerts per 1,000 words, or under half of sampled hits real: the rule stays in the prose. Passive voice, contractions, short sentences, and repeated words in a sentence did not pass. A punch word in body text did not pass either (3 hits, none a punch).
- 0.5 to 2 alerts per 1,000 words and at least half real: suggestion.
- Under 0.5 per 1,000 words: suggestion, or warning for headings, numerals on social and a leftover `[needs number]`, where the fix is mechanical.
- Rules for social posts, slides and docs have no matching posts in that corpus, so they ship as suggestions and were checked on test cases only.
- `OneSentenceParagraph` and `SerialCommaMaybe` fire often on those posts (8.5 and 1.8 per 1,000 words) because they enforce choices the user made after 2021. They are judged on precision only and stay.

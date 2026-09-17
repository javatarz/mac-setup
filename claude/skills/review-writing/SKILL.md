---
name: review-writing
description: >
  Automatically review AND revise any prose I write against my personal style
  — blog posts, articles, LinkedIn posts, docs, README prose, long-form
  messages. Run this immediately after drafting or editing such content, even
  if I didn't ask for a review. Applies fixes directly by default instead of
  just listing them.
---

TRIGGER — run this every time, without being asked, right after you (Claude)
finish drafting or editing prose content for me: a blog post, article,
LinkedIn/social post, doc section, README prose, or any other written piece
meant for a reader. This includes content you write inline in the
conversation and content you write to a file.

SKIP for: code, commit messages, PR descriptions, commands/config, this
SKILL.md itself, or short factual replies with no real prose to critique.

Default behavior: **review, then apply the fixes yourself** using Edit/Write
on the actual file (or by revising the message before sending it, if it's
inline content with no file). Do not stop at a list of suggestions and wait
for approval. Only skip auto-apply if I explicitly say "just review",
"don't change anything", or "show me the list first" for that request.

Review the content against my writing style below, fix what the review
finds, then report back per the "Final Response" section — a short summary,
not the full section-by-section report.

Optional fast pre-check: `tools/score_review.py` is a deterministic regex
lint covering the mechanical/lexical rules below (banned vocabulary, AI
construction shapes, dash tells, repeated-qualifier lists, invented proof,
stock idioms) — `python3 tools/score_review.py draft.md` or `--text "..."`,
scores 5 groups, exits non-zero below 5/5. It's a cheap catch-obvious-stuff
pass, not a substitute for the full review below — most rules here
(boast framing, scoped claims, negation setups, heading consistency,
authenticity, Elements of Style) need judgment a regex can't apply.

## My Writing Style

**Tone**: Grounded, modest, technical. Clear and direct—no fluff or corporate jargon. Calm and confident, never boastful. Simple but not simplistic.

**Voice**: Understatement over big claims. Clarity over cleverness. No dramatic, salesy, or self-important language. No hero narratives ("I drive clarity," "I transform engineering"). Specific examples over abstract generalities.

**Phrasing**:
- Shorter over longer
- Concrete over vague
- Technical but accessible, not academic
- Avoid overselling adjectives ("revolutionary," "world-class," "groundbreaking")
- Prefer: "Here's what I'm exploring…", "Here's how I think about…", "A practical approach is…"

**Content focus**: Intelligent engineering, AI-assisted software delivery, architecture, developer experience. Writing should capture thinking + practical value. Honest, thoughtful, useful.

## Review Process

**All sections below are mandatory.** Do not skim - treat each section with the same thoroughness as a standalone review. Complete each section fully before moving to the next.

### 1. AI Tells Check
Flag anything too marketing-y, self-important, vague, dramatic, buzzword-heavy,
wordy, or academic. The shapes below are the common ways this happens —
diagnostic, not exhaustive:

**Structural tells**:
- Abstract wisdom without specifics ("Better thinking in produces better thinking out")
- Missing the "I" voice — abstract "we" throughout instead of personal experience
- Overly parallel/poetic structures ("Not X. Not Y. Z." for dramatic effect)
- Triple constructions ("extend your reach, accelerate your ideas, and surface possibilities")
- Blockquote overuse for emphasis
- Bold-lead bullets on every item: a list where every single bullet opens with a bolded phrase (**Term:** explanation) is a formatting tell, not a real emphasis choice. Bold sparingly, only where a term genuinely needs a visual anchor. Counter-example (kept): one or two bolded leads in a longer list, used because those specific items are lookup keys (e.g. a glossary), is fine — this only targets the pattern where literally every bullet gets the same treatment.
- AI construction shapes — recognizable sentence patterns, not vocabulary, so word-swaps don't fix them:
  - `not just X, but Y` / `more than just X` ("It's not just a tool, it's a workflow") → cut the throwaway first half, keep the actual claim.
  - `whether you're X or Y` ("Whether you're a beginner or an expert...") → name the one reader actually being addressed.
  - `that's where X comes in` → state directly what X does.
  - `say goodbye to X` → name what replaces X, not the farewell.
  - `imagine a world where...` → show the thing instead of staging it.
  - Hedged benefit verbs ("helps you to", "can help you") → commit to one direct verb.
  - Stacked hedging ("may potentially", "could possibly") → one hedge at most, ideally zero.
  - Self-answering question ("The result? Faster shipping.") → state it as a plain sentence.
- Empty setup/announcement lines: a sentence that names the *category* of what's coming ("the caveat," "the gap," "the point") instead of just stating the content. E.g. "Name the gaps this does not close, because they are real. MCP servers talk over stdio..." → cut to "MCP servers talk over stdio..."; "Here is the honest caveat: I could not find documentation stating..." → cut to "I could not find documentation stating...". Test: if deleting the sentence loses zero information because the next sentence already carries it, cut it. Common shapes: "Here is/Here's [the point/the caveat/the thing]:", "Note that...", "Name the gap(s):", "Worth noting...", "It's worth mentioning...", "The point is this:". Do not flag genuine signposting for a real enumeration that follows (e.g. "Three layers, in this order:" right before a First/Second/Third list) — that helps the reader parse structure rather than padding.
- Wordy lead-in when the piece already has simpler phrasing for the same idea: if an earlier line already stated the idea plainly, reuse that exact phrasing for a later reference instead of re-deriving a new, wordier one. Example: "So for every safety net you rely on, ask:" → "Ask this of any safety net you have" (reusing phrasing already established earlier in the piece). Counter-example (kept): restating an idea in genuinely different, still-plain words is fine when nothing established earlier already said it better — this only fires when a plainer version already exists in the piece.
- Abstract-clever heading/title over plain-descriptive: a heading that states an abstract relation between categories ("X separates Y from Z", "the difference between...") instead of naming what the section actually is. Test: would you say this heading out loud to a colleague? Example: "One question separates real from decorative" → "The question to ask every guardrail". Counter-example (kept): "Green is a claim, not a fact" as a section heading is fine when the contrast IS the thesis, stated concretely in the author's own register — not every contrast title is empty cleverness.
- List-then-possessive-punchline construction: a list of items followed by a flip built for effect ("...are all theirs"). Often doubles as a triple construction. Say the underlying fact as a plain sentence. Example: "the failures, the practices, and the reviews behind this talk are all theirs" → reworded as a direct, plain attribution sentence. Counter-example (kept): a short, specific credit line ("Thanks to [name] for catching the edge case in review") is fine — it's a plain sentence, not a constructed flip.
- Heading that duplicates a section type already named elsewhere in the same project: when a sibling doc already has a heading for the same kind of section (e.g. "Open Questions"), reuse that exact heading instead of inventing new phrasing for the same role. Example: "Questions worth deciding before the architecture" → "Open Questions" (matches the heading already used in a sibling doc for the same section type). Counter-example (kept): a heading with no established sibling precedent is free to be as descriptive as the content needs — this only fires when a convention already exists elsewhere in the project.
- Isn't-X-it's-Y negation setup: framing a claim by first negating a strawman before stating the real point. This constructed flourish shows up in prose, not just slide decks — say the real point directly. Example: "isn't 'can we do this.' It's which of two ways to split cost and latency" → "The real decision is which of two ways to split cost and latency." Counter-example (kept): a negation doing real disambiguating work — ruling out a plausible but wrong reading before the sentence runs long — is fine; this only targets the rhetorical setup used for punch, not genuine clarification.

**Language tells**:
- Banned vocabulary — words a model reaches for as the safest available token; humans mostly don't. The fix is a plainer word, never a same-register synonym (`leverage` doesn't become `utilise`, it becomes `use`).
  - Delete on sight: `delve`, `tapestry`, `testament to`, `underscores`, `seamless(ly)`, `robust`, `navigate the landscape`, `in today's fast-paced world`, `it's important/worth noting`, `that being said`, `at the end of the day`, `unlock`, `supercharge`, `elevate`, `game-changing`, `revolutionise/revolutionize`, `harness the power of`, `dive deep`, `myriad`, `plethora`, `realm`, `ever-evolving`, `cutting-edge`, `transformative`, `paradigm shift`, `synergy`, `holistic`, `embark`.
  - Fine once, damning if repeated across sections: `leverage`, `foster`, `crucial`, `pivotal`, `streamline`, `empower`, `showcase`, `curated`, `meticulous`, `compelling`, `innovative`, `comprehensive`, `journey`, `solution`, `effortless`, `intuitive`, `world-class`, `best-in-class`, `unleash`, `boost`.
- Buzzword soup ("curiosity, continuous improvement, and lightweight experimentation")
- Generic thought leadership ("AI is reshaping how we think while we deliver")
- Salesy phrases ("That's the real craft of...", "Become harder to compete with over time")
- Passive corporate constructions ("Intentional adoption prevents accidental dependencies being created")
- Redundancy dressed as emphasis ("hallucinated APIs that do not exist")
- Em-dashes and en-dashes: banned as sentence connectors, not just overused — most humans don't write with them. Rewrite with a period, comma, semicolon, or parentheses. This does not touch ordinary hyphenated words ("cross-post", "well-known", "on-call") — a hyphen inside a word is fine; the ban is only on using a dash character to join clauses. Counter-example (kept): "cross-post" stays hyphenated; don't split or merge it into "cross post" or "crosspost" just because dashes are otherwise banned.
  Also covers a hyphen used *as a dash substitute* to join two clauses (statement, hyphen, addendum). If the addendum boasts or editorializes rather than adding information, it's doubly wrong: fix the dash AND cut the addendum — see the boast/meta-narration rule below for the test. Example: "Coverage is theater - we measured it" → "Coverage is theater". Counter-example (kept): "Mutant 32 inverts the review rule - high-value orders from unknown countries now skip human review" — the second half is real information; keep the content, just replace the hyphen with a period or colon.
- Boast or meta-narration about our own rigor or process: the sentence announces that evidence or effort exists, or narrates the writing/analysis process, instead of just delivering the result. Shapes: rhetorical-question-then-reveal ("That test? We ran the numbers on it."), "We didn't just X, we Y'd", reframe-as-profundity ("The gap is the finding."), rigor labels ("the right way", "we ran this", "done properly"), process narration ("I've reviewed the requirements and structured the following...", "Let me break this down..."). Test: is this sentence about the subject, or about us / our process? Example: "We didn't just eyeball it. We measured it." → deleted; let the measurement itself (the numbers that follow) do the work. Counter-example (kept): "(untested in production)" attached to one specific claim — an epistemic-status label scoped to the exception is honest labeling, not a boast. Label only the exception; the default needs no label, and state a caveat once, in prose, where the concept is introduced, rather than re-attaching it to every later mention.
- Compressed or symbolic aphorisms: a claim squeezed into shorthand ("Mandatory ≠ maximal") or a terse compound ("The harness compounds.") reads as a flourish even when the underlying verb is accurate, because the reader has to decode it. Say the literal claim and name what the subject actually does. Example: "Mandatory ≠ maximal" → "The mandatory set is small on purpose"; "The harness compounds." → "Harness quality compounds over time." Counter-example (kept): a punchy claim is fine as long as its mechanism stays in the same breath — "The harness never regresses, it only gets better" works because the mechanism (never regresses) rides with the punch; stripping it to just "It only gets better" turns it into the aspirational claim the piece is arguing against.
- Don't recycle a line that already failed to land: if an aphorism was used before (an earlier post, an earlier draft) and is known not to have landed with readers, restate it in plain words with its mechanism attached rather than reusing it unchanged. Example: "Green is a claim, not a fact" (already used once, didn't land) → "A green build only tells you the checks passed. It doesn't tell you the checks are any good." Counter-example (kept): a first use of a contrast line as the piece's actual thesis, stated concretely in the author's own register, is fine — this only fires on a documented re-use of something that already flopped.
- Vague anthropomorphism where a precise term of art exists: a fuzzy human metaphor standing in for a documented, named phenomenon the audience already knows. Example: "forgotten under pressure" → "lost in the middle of a long context" (an engineering-literate audience knows this term). Counter-example (kept): "the agent is confident and wrong" — vivid and accurate, and no term of art replaces it; don't force jargon where the plain phrase is already clearest. Corollary: once a piece defines a term for a concept, use that exact term everywhere after — an undefined synonym (calling it "the fleet" after the piece established "the factory") costs the reader a translation beat.
- "Anyone can X" belittling phrasing: framing a step as trivial belittles the reader instead of making the actual point. State the easy/hard contrast plainly. Example: "Anyone can wire the pipeline." → "Wiring up the pipeline is the easy part." Counter-example (kept): naming a genuine skill floor without belittling ("Wiring the pipeline takes an afternoon; making the test suite trustworthy takes months") is fine — it's a contrast, not a put-down.
- Stock idioms and business cliches: a worn phrase standing in for the actual thing. Example: "war stories" → "failures" / "incidents". Counter-example (kept): the same cliche as private shorthand in internal notes or scratch docs, never shipped to a reader, doesn't need fixing — this targets copy that goes out, not working notes.
- Restating information already established earlier in the same sentence: a parenthetical or appositive that repeats a fact the sentence (or the sentence before it) already gave. Example: "a stronger, and more expensive, version" → "a stronger version" (the cost was already stated earlier). Counter-example (kept): a parenthetical that adds a fact the reader doesn't have yet is fine — this only targets restating what's already on the page.
- Qualifier repeated across a list: repeating the same word before every item in a list ("the same guardrails, the same review gates, the same audit trail") reads as parallel-for-effect rather than plain enumeration. State the qualifier once. Example: "the same guardrails, the same review gates, the same audit trail" → "the same guardrails, review gates, and audit trail". Counter-example (kept): repeating a light connector like "and" across a list is normal English, not a tell — this only targets repeating a heavier qualifier (an adjective/determiner like "the same", "every", "each") before every item.
- Benefit-clause-but-cost-clause compound sentences: a single sentence stacking a benefit and a cost joined by "but" reads as a pro glued to a con. Prefer an explicit "trades X for Y" framing, or split into two short sentences. Example: "This has the lowest monthly cost but requires the highest maintenance." → "This trades a lower monthly bill for the highest maintenance cost." This is frequency guidance, not an outright ban — an occasional "but" is fine; don't reach for this shape as the default connector for every benefit/cost tradeoff.
- Standing spelling rule: "meetup" (one word), never "meet-up".

**Content tells**:
- Never invent proof: no user counts, testimonials, ratings, or "trusted by N teams" unless every one is true and checkable. If a claim needs a number that isn't available, either drop the claim or flag it inline (e.g. "[needs number]") rather than filling in a plausible-sounding one. A false positive here costs a rewrite; a false negative ships a claim that can't be backed. This is the same epistemic-labeling discipline as the scoped-claim and boast rules above, applied to numbers specifically.
- No friction or uncertainty — reads like settled truth
- No personal anecdotes — principles without stories
- Aspirational framing ("The engineers I admire most...") instead of observation ("The engineers I've seen do this well...")
- Claim scoped beyond what the reader can see: a number, count, or reference that depends on content not actually shown or established earlier in the piece. Example: "our teams run rungs 1-3 today" when only two rungs have been described so far → "our teams run these today". Counter-example (kept): a caveat positioned directly against the one claim it scopes to ("(designed, not yet run in production)" right next to the claim it qualifies) is fine — this targets claims whose referent doesn't exist yet in the reader's view, not scoped caveats.
- Code, config, or command samples that don't survive a literal parse-or-run check: a technical reader will parse them literally. Don't put simulated output inside an input block, don't pin a dependency to a vague snapshot ("@ latest as of March") when an exact version or SHA is available, and don't use a prose sentence where the sample needs an actual check or assertion. Example: a "config" sample containing a line like `score: 4/5 passed` → move that line into a separate "output" block; it isn't part of the input. Counter-example (kept): a snippet explicitly marked as pseudocode or illustrative ("# illustrative, not runnable") doesn't need to parse or run — it isn't claiming to.

**Register tells (LinkedIn/X, short-form posts)**:
- Full stops over dash-joined qualifiers: short-form social copy reads as full sentences, not a stitched qualifier. Example: "All three - but written down, not relied on." → "All 3. Written down, not relied on."
- Numerals over spelled-out numbers in this register ("three" → "3" in the example above).
- No softening "but" in short declaratives: state the second clause as its own sentence instead of hedging it onto the first with "but".
Counter-example (kept): none of this applies outside short-form social copy — a blog post or doc can spell out "three" and use "but" normally; this register only governs LinkedIn/X-style posts, where clipped, numeral-heavy, full-stop delivery is the author's actual voice there.

### 2. Authenticity Check
Gut check, not a new checklist: does this sound like something the author
would actually say? The tells above are the mechanical version of this test
(I-voice, personal anecdotes, acknowledged uncertainty, named specifics vs
generic advice all appear there as things to flag when *absent*) — this
section is for whatever a real voice would catch that pattern-matching
doesn't: an anecdote that's technically specific but reads generic, a
comparison that's accurate but bloodless, a hedge that's honest but
oddly placed.

### 3. Clarity & Concision Review
Apply Elements of Style principles:

**Elementary Rules of Usage (Grammar & Punctuation)**:
- Rule 1: Form possessive singular with 's
- Rule 2: Use comma in series
- Rule 3: Enclose parenthetic expressions between commas
- Rule 4: Place comma before coordinating conjunction
- Rule 5: Don't join independent clauses with comma
- Rule 6: Don't break sentences in two
- Rule 7: Participial phrases must refer to grammatical subject

**Elementary Principles of Composition**:
- Rule 8: One paragraph per topic
- Rule 9: Begin paragraphs with topic sentence
- Rule 10: Use active voice
- Rule 11: Put statements in positive form
- Rule 12: Use definite, specific, concrete language
- Rule 13: Omit needless words
- Rule 14: Avoid succession of loose sentences
- Rule 15: Express coordinate ideas in similar form
- Rule 16: Keep related words together
- Rule 17: Keep to one tense in summaries
- Rule 18: Place emphatic words at the end

**Common Issues to Check** (beyond Rules 1–18 above — don't re-flag as a
separate issue what a numbered rule already covers, e.g. passive voice is
Rule 10, vague language is Rule 12, needless words is Rule 13):
- Unclear or weak sentence structure
- Sentences that could be split for punch
- Sections that bundle more than one idea (extension of Rule 8, one paragraph per topic, applied at the section level): split into separate sections, one claim each. Example: one dense section walking through an eval deep-dive covering four separate points → four short sections, one point each. Counter-example (kept): a single section with one claim plus supporting detail/evidence for that same claim is fine — this targets multiple distinct claims crammed together, not elaboration on one claim.
- Symmetrical paragraphs (extension of Rule 14, avoid a succession of loose sentences): every paragraph landing at the same length, same sentence count, same rhythm reads mechanical even when each paragraph is individually fine. Vary it hard — a short paragraph after a long one is a legitimate move, not a defect. Counter-example (kept): two consecutive paragraphs happening to land at a similar length by coincidence isn't a tell; this only fires when the whole piece falls into a visible, repeated pattern (e.g. every paragraph is exactly three sentences).

### 4. Identify & Apply Fixes
Work out the 3–5 most impactful fixes (internal working list, not the final
response):

**For each issue**:
- **Location**: The problematic text
- **Issue**: Which rule is violated (AI-tell pattern, style mismatch, or Elements of Style rule)
- **Problem**: What's wrong
- **Fix**: The improved version

**Prioritize**: cutting AI-isms, adding personal voice where missing,
making abstract statements concrete, converting passive to active voice,
tightening wordy/needless constructions.

Then **apply these fixes directly** to the content (Edit/Write the file, or
revise the draft before sending it) — see "Default behavior" above. Don't
present this list to me and wait; that list is your own working notes for
what to change.

### 5. Summary (internal)
Work out whether the piece passed clean or needed revision, and how much
(minor polish vs significant rewrite). Feeds the Final Response below —
don't print the full section-by-section report by default. Only for a full
report requested explicitly (see below): also note in passing what worked
well (authentic voice, concrete examples, active voice) — skip this for the
default compact response.

## Final Response

After applying fixes, reply with a short summary, not the full report:
- One line: passed clean, or needed revision (minor polish / significant rewrite)
- The fixes actually made, as a compact bullet list (issue → what changed)
- Skip sections that found nothing — don't pad with "no issues in Authenticity Check" filler

Give the full section-by-section report only if I explicitly ask for it
("full review", "walk me through the review", "show all sections").

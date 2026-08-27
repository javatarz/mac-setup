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

### 1. Tone & Voice Review
Flag anything: too marketing-y, self-important, vague, dramatic, buzzword-heavy, wordy, or academic.

### 2. ChatGPT Tells Check
Flag these AI-generated content patterns:

**Structural tells**:
- Abstract wisdom without specifics ("Better thinking in produces better thinking out")
- Missing the "I" voice — abstract "we" throughout instead of personal experience
- Overly parallel/poetic structures ("Not X. Not Y. Z." for dramatic effect)
- Triple constructions ("extend your reach, accelerate your ideas, and surface possibilities")
- Blockquote overuse for emphasis
- Empty setup/announcement lines: a sentence that names the *category* of what's coming ("the caveat," "the gap," "the point") instead of just stating the content. E.g. "Name the gaps this does not close, because they are real. MCP servers talk over stdio..." → cut to "MCP servers talk over stdio..."; "Here is the honest caveat: I could not find documentation stating..." → cut to "I could not find documentation stating...". Test: if deleting the sentence loses zero information because the next sentence already carries it, cut it. Common shapes: "Here is/Here's [the point/the caveat/the thing]:", "Note that...", "Name the gap(s):", "Worth noting...", "It's worth mentioning...", "The point is this:". Do not flag genuine signposting for a real enumeration that follows (e.g. "Three layers, in this order:" right before a First/Second/Third list) — that helps the reader parse structure rather than padding.

**Language tells**:
- Buzzword soup ("curiosity, continuous improvement, and lightweight experimentation")
- Generic thought leadership ("AI is reshaping how we think while we deliver")
- Salesy phrases ("That's the real craft of...", "Become harder to compete with over time")
- Passive corporate constructions ("Intentional adoption prevents accidental dependencies being created")
- Redundancy dressed as emphasis ("hallucinated APIs that do not exist")
- Em-dash overuse — most humans don't write with em-dashes; prefer commas, periods, or parentheses

**Content tells**:
- No friction or uncertainty — reads like settled truth
- No personal anecdotes — principles without stories
- Aspirational framing ("The engineers I admire most...") instead of observation ("The engineers I've seen do this well...")

### 3. Authenticity Check
Does this sound like something the author would actually say? Look for:
- Personal anecdotes from actual experience
- "I" for opinions, "we" to include the reader
- Concrete failure modes witnessed firsthand
- Specific comparisons (bad prompt vs good prompt)
- Acknowledged uncertainty ("These principles aren't final...")
- Named tools and techniques, not generic advice

### 4. Clarity & Concision Review
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

**Common Issues to Check**:
- Unclear sentences and unnecessary complexity
- Redundancy and needless words (can any phrase be cut?)
- Sentences that could be split for punch
- Passive voice overuse
- Vague, abstract language
- Negative statements that could be positive
- Weak sentence structure

### 5. Identify & Apply Fixes
Work out the 3–5 most impactful fixes (internal working list, not the final
response):

**For each issue**:
- **Location**: The problematic text
- **Issue**: Which rule is violated (ChatGPT pattern, style mismatch, or Elements of Style rule)
- **Problem**: What's wrong
- **Fix**: The improved version

**Prioritize**:
- Cutting ChatGPT-isms
- Adding personal voice where missing
- Tightening wordy constructions
- Making abstract statements concrete
- Converting passive to active voice
- Removing needless words

Then **apply these fixes directly** to the content (Edit/Write the file, or
revise the draft before sending it) — see "Default behavior" above. Don't
present this list to me and wait; that list is your own working notes for
what to change.

### 6. Positive Elements
Highlight what works well:
- Authentic personal voice where present
- Clear, concrete examples
- Effective use of active voice
- Good Elements of Style adherence
- Strong technical clarity

### 7. Summary (internal)
Work out whether the piece passed clean or needed revision, and how much
(minor polish vs significant rewrite). Feeds the Final Response below —
don't print the full 7-section report by default.

## Final Response

After applying fixes, reply with a short summary, not the full report:
- One line: passed clean, or needed revision (minor polish / significant rewrite)
- The fixes actually made, as a compact bullet list (issue → what changed)
- Skip sections that found nothing — don't pad with "no issues in Authenticity Check" filler

Give the full section-by-section report only if I explicitly ask for it
("full review", "walk me through the review", "show all sections").

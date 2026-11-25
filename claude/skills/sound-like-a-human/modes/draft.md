# Draft mode

Use this when the user gives notes, an idea, or asks for a new piece. The steps below are for a blog post or a document. The type file says which steps to shorten for slides, email, and social posts.

## Steps

1. **Read the user's notes in full.** List what they already say in the user's words. That wording goes into the draft as is.
2. **Ask what's missing, one question at a time.** Give the context for each question and your recommendation. Ask about the reader, the one point the piece makes, real cases and numbers, and anything confidential. Don't ask what the notes already answer.
3. **Write `brief.md`** from `brief-template.md`, next to the draft. Every later step reads the brief, so put each decision there, not only in chat.
4. **Gate 1: the user approves the brief.** Don't outline until they do.
5. **Propose the title and headings in both shapes,** side by side: labels or imperatives ("Run tests in parallel") and short sentences ("Each test runs in one place"). The post type in the brief says which one to recommend. Under each heading, add one line for the planning note: the single point that section makes. The planning note is for you and the user; it never appears in the piece.
6. **Gate 2: the user picks the headings.** Don't draft until they do.
7. **Draft the whole piece in one pass.** Build each section around the user's wording from step 1. Follow the honesty rules in `SKILL.md`: any number you don't have becomes `[needs number]`.
8. **Lint it:** `python3 ${CLAUDE_SKILL_DIR}/scripts/lint.py --type <type> <file>`. Fix errors and warnings.
9. **Run review mode** (`modes/review.md`) in a fresh-context subagent. Don't review your own draft in the same context that wrote it.
10. **Hand it over** with a short list: anything you invented (hypothetical examples, framing), every `[needs number]`, and any word decision you made from the Oxford fallback.

## Shorter pieces

An email, a message, or a social post skips the brief file and both gates. Ask the questions you need, draft, lint, and review. Slides keep the gates; see `types/slides.md`.

## What not to do

- Don't write a draft before the brief is approved, even a "rough" one. A model draft replaces the user's wording and flattens the voice.
- Don't merge the user's notes into tidier sentences. Fix grammar and order; keep their words.
- Don't fill a gap with a plausible story. Ask, or mark the gap.

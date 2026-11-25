---
name: sound-like-a-human
description: >
  Draft or review any prose for the user so it sounds like them: blog posts, slide
  text and speaker notes, documents for publishing, emails, and LinkedIn or X
  posts. Use when they ask for a draft, and run it without being asked right
  after you draft or edit such prose (review mode). Skip code, commit
  messages, PR descriptions, config, and short factual chat replies.
---

# Sound like a human

One language system for everything the user publishes. The voice is the same everywhere; only the structure changes by type.

## 1. Pick the mode and the type

| Mode | When | Read |
|---|---|---|
| draft | The user gives notes, an idea, or asks for a new piece | `modes/draft.md` |
| review | Text already exists: your own draft, the user's text, or an edit | `modes/review.md` |

| Type | Read |
|---|---|
| Blog post | `types/blog.md` |
| Slide text or speaker notes | `types/slides.md` |
| Document for publishing | `types/doc.md` |
| Email or message | `types/email.md` |
| LinkedIn or X post | `types/social.md` |

If the type is unclear, ask. Then read, in this order: `voice.md`, `examples.md`, `pairs.md`, the mode file, the type file. Read them before writing a word.

## 2. Honesty rules (every mode and type)

1. **Every story told as something that happened comes from the user's notes or the brief.** Never invent one.
2. **A real case the user can't share** (client work) is told with identifying details removed: "On one project, our tests called an external service that took 30 seconds."
3. **A made-up example is framed as hypothetical:** "Say...", "Consider...", "Imagine...". Use one only when the real example can't be shared.
4. **Never invent proof.** No numbers, counts, quotes, or results that aren't in the notes or sources. If a claim needs a number you don't have, write `[needs number]`.
5. **Never present designed-only work as production practice.** Label it where the claim is made, once.
6. **Caveats come only from the brief.** Add a limit or caveat only for a claim the brief marks as uncertain.
7. **Keep the user's wording.** Where their notes already say it, use their words and shape around them. Model-written text is what flattens the voice. In review, text that breaks no rule stays untouched: don't split or join sentences, drop words, swap synonyms, or spell out numerals (see `modes/review.md`).

## 3. Avoid-list

AI habits the linter can't catch. Each needs judgement. If you see one, rewrite it plainly.

1. **Abstract wisdom with no specifics.** "Better thinking in produces better thinking out." Give the case or cut it.
2. **Contrast setups for punch.** "X, not Y", "isn't X, it's Y", "Not X. Not Y. Z." State the X. Keep a negation only when it rules out a likely misreading.
3. **Compressed aphorisms.** "The harness compounds." / "X is the work." Say the literal claim, or the action the reader should take.
4. **Clever headings and titles.** "One question separates real from decorative." Name what the section is. Would the user say it out loud to a colleague?
5. **Punch words.** "nobody", "everyone", "beats", "the real" used for effect. Name the literal thing.
6. **Dramatic fragments.** "I couldn't." on its own. Join a short contrast with "but".
7. **Triples and parallel lists for rhythm.** Three items because three sounds good. Keep the items that are true and needed.
8. **List-then-punchline.** "...the failures, the practices, and the reviews are all theirs." Say it as a plain sentence.
9. **Boasting about rigour or narrating the process.** "We didn't just eyeball it. We measured it." Give the measurement.
10. **Buzzwords, thought leadership, and sales lines.** "AI is reshaping how we think." Say what changed, for whom, by how much.
11. **Passive corporate sentences.** "Intentional adoption prevents dependencies being created." Say who does what.
12. **Saying it twice.** Redundant emphasis ("hallucinated APIs that do not exist") or a clause that repeats the sentence before.
13. **Aspirational framing.** "The engineers I admire most..." Use what they saw: "The engineers I've seen do this well...".
14. **Shrinking what happened.** "asked a question" when it was a set of questions. Keep the real size.
15. **Empty setup lines.** "Here's the thing:" before the thing. Delete it if the next sentence carries the content.

## 4. Lint

Run `python3 ${CLAUDE_SKILL_DIR}/scripts/lint.py --type <type> <file>` on every draft and every revision. Fix every error. Fix warnings unless there's a reason; say what the reason was. Look at suggestions.

In review mode, pass the text from before your edits: `--before <old-file>`. It flags any of the user's keep-words that your edits removed.

Spelling, punctuation, word lists, and length limits live in the linter. Don't re-check them by reading.

## 5. When the user corrects your wording

Append the correction to `~/.config/sound-like-a-human/corrections.md` (create the folder and file if missing) the moment it happens: before, after, and the reason in one line. The log stays on this machine, never in this repo, because the repo is public. Every repo writes to the same log. A correction becomes public only when the user approves turning it into a pair or lint rule. If it's a new kind of fix, propose a pair for `pairs.md` or a rule for `scripts/lint.py`. Prefer the lint rule when a regex or word list can catch it.

Before you write a pair or rule, strip client and company names, people's names, email addresses, and client details that aren't in the user's published posts, and keep only the wording lesson. If you're unsure whether a detail is private, ask the user first.

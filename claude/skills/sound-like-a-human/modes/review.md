# Review mode

Use this on any text that already exists: your own draft, the user's text, or an edit. Run it without being asked right after you draft or edit prose. Fix by default; if the user says "just review", list the fixes and change nothing.

## Who reviews

Review in a fresh-context subagent when you wrote the text. The context that wrote a draft can't see its own habits. Give the subagent only these files: the text, `brief.md` (if there is one), `SKILL.md`, `voice.md`, `examples.md`, `pairs.md`, and the type file. Don't pass the chat or your reasoning.

## Steps

1. **Lint first:** `python3 ${CLAUDE_SKILL_DIR}/scripts/lint.py --type <type> <file>`. Fix what it reports before reading for judgement, so the review spends its attention on what a regex can't catch.
2. **Read the whole piece once** against the checks below, the honesty rules, and the avoid-list in `SKILL.md`.
3. **Pick the 3 to 5 fixes that matter most.** A wrong claim or an invented story comes before a clever heading; a clever heading comes before a word choice.
4. **Apply them,** keeping the user's wording everywhere else. Save the old text first.
5. **Lint again with `--before <old-file>`.** It flags any keep-word your edits removed. Put those words back unless the fix needed them gone.
6. **Report in a few lines:** what you changed and why, one line each. Give the full report only if the user asks.

## Leave clean text alone

A sentence that breaks no rule stays exactly as written. Anything on the avoid-list, flagged by the lint, or covered by a type-file rule (such as words to digits on social posts) IS a rule break: fix it. Zero edits is a valid review. Models over-edit in these ways, so don't:

- **Split or join sentences.** Keep the author's sentence boundaries, including short endings ("Small margin. It held.").
- **Drop words.** A clause that breaks no rule stays; a buzzword or punch word does not ("It's not glamorous, but...", "not when a timer says so").
- **Swap a phrase for a synonym.** "I don't think it's anyone's fault" stays; it doesn't become "I don't blame anyone".
- **Contract a full form.** "does not prove" stays; the writer chose it for stress or style.
- **Reword to tighten.** "The fewest words" applies to a sentence you are already fixing, not to one that is fine.
- **Turn digits into words.** "3 checks" stays "3 checks". The social rule still turns "three" into "3".
- **Touch headings, code blocks, or a flagged caveat.** A designed-only label or a thank-you stays.

A fix changes only the words its rule names. A dash becomes a comma, colon, or parentheses; the rest of that sentence stays.

## Checks that need the whole piece

- **Does it sound like the user?** Compare a few paragraphs with `examples.md` and the drafts in `pairs.md`. If a line reads like a `<draft>`, rewrite it the way the `<fix>` goes.
- **One point per section.** Each section makes the point its heading names. Move or cut anything else.
- **Nothing depends on what comes later.** A claim that needs a fact or a term from a later section moves after it, or the fact moves up.
- **Nothing is said twice.** A later sentence that restates an earlier idea in more words goes.
- **One term per concept.** Use the same word for the same thing all the way through. Use the term of art over a metaphor.
- **Paragraph length varies** within 2 to 4 sentences. Several paragraphs of the same shape in a row read as generated.
- **Blockquotes are rare.** Use one for a real quote, not for emphasis.
- **Headings don't clash with sibling pieces.** In a series, check the brief's list of sibling posts; don't rename a section type they already name.
- **No line the brief lists as one that already failed.** The brief keeps lines the user rejected; don't bring them back in new words.

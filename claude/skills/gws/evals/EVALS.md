# Evals for the `gws` skill

Golden-scenario eval harness. Purpose: catch regressions when `SKILL.md`
changes — verify Claude still routes Google Workspace file access through
`gws`, still discovers unfamiliar flags instead of guessing, and still
leaves unrelated tasks alone.

This is a tool-choice/behavior skill, not a text-transform skill, so the
eval shape differs from a review-style skill: each sample is a user request.
Claude is asked to state the plan and exact commands it would run — not to
actually execute them — so the eval can run unattended without live Google
credentials or side effects.

## Layout

```
evals/
  EVALS.md          this file
  samples/          8 synthetic request scenarios, each with frontmatter:
                     id, purpose, expected_behavior, forbidden,
                     expected_verdict, notes
```

Samples map to `SKILL.md` sections:

| Sample | Section under test |
|---|---|
| `01_doc_read_via_url` | Fast paths (Doc read) + Getting an ID from a URL |
| `02_sheet_range_read` | Fast paths (Sheet read) |
| `03_slides_summary` | Fast paths (Slides read) |
| `04_drive_search_mcp_temptation` | Rule (avoid `mcp__claude_ai_Google_Drive__*`) + Fast paths (Drive search) |
| `05_sheet_append` | Fast paths (Sheet append) |
| `06_drive_upload` | Fast paths (Drive upload) |
| `07_unfamiliar_flag_discovery` | Discovery first (regression check — must not fabricate flags) |
| `08_unrelated_negative_control` | False-positive baseline — no Google Workspace involvement, `gws` should not appear |

## Running the eval

For each sample:

1. Strip the frontmatter; the body is the user request.
2. Feed the current `SKILL.md` plus the request to a fresh agent (or
   `Skill({skill: "gws"})` context) and ask it to state, in plain text, the
   exact `gws` command(s) it would run — or the discovery commands it would
   run first if unsure — without actually invoking any tool.
3. Capture that plan text.
4. Score against the sample's frontmatter:
   - **`expected_behavior`**: does the plan name or clearly describe each
     expected step (correct service/resource, ID pulled from URL, discovery
     step taken when required)? Match on substance, not exact command
     syntax — the CLI drifts, so an equivalent working command counts.
   - **`forbidden`**: for `04` and `08` especially, the bar is zero
     occurrences of the forbidden tools/patterns. Any appearance is a
     regression — note it specifically.
   - **Verdict match**: does the overall plan land on something consistent
     with `expected_verdict`?
5. Record pass/fail per sample in a run log (date, SKILL.md git hash, model
   id, notes) if you're tracking drift over multiple runs.

## Running via script

`./run-evals.sh` automates the above: `claude -p` states a plan for each
sample with the skill loaded, a judge model scores the plan against
`expected_behavior`/`forbidden`, and results land in `results/<timestamp>/`
as a `.plan.md` and `.verdict.txt` per sample plus `MODEL.txt` recording the
resolved model id. Defaults to `sonnet`; pin another with
`EVAL_MODEL=claude-opus-5 ./run-evals.sh`. Compare `MODEL.txt` across runs
before treating a pass/fail delta as a real regression rather than a model
change.

## When to run this

- After any edit to `SKILL.md`, before committing.
- After a `gws` CLI upgrade, to check the fast-path examples haven't gone
  stale (a stale example is a low-severity finding — the discovery-first
  rule is what actually protects correctness — but worth refreshing).

## Known limits

- This is an LLM-judged eval on stated plans, not executed commands — it
  catches routing/discovery mistakes in Claude's reasoning, not CLI syntax
  errors. It won't catch a `gws` version bump silently breaking a fast-path
  example; that needs a real run against `gws --dry-run`.
- 8 samples cover each rule category once, not exhaustively. Add a sample
  whenever a real session surfaces a routing mistake (wrong tool chosen) or
  a fabricated flag worth locking in as a regression check.

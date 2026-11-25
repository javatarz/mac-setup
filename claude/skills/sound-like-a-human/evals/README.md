# Evals for sound-like-a-human

These evals check that the skill still works as models change, and show how well each model follows it. They use `claude plugin eval` (Claude Code v2.1.299 or later). The skill folder is a skills-directory plugin (`.claude-plugin/plugin.json`), so the eval loads it on its own, with nothing else from your setup.

## Cost

Every agent run and every `llm` grader is a real model call on your account. The suite has 30 cases and each case runs 3 times by default. With the default models (Opus, Sonnet, Haiku) that is 3 full suite runs, so about 270 agent runs plus judge calls. Ways to spend less:

- Run a subset with `--tag` or `--case`.
- Use `--runs 1` while iterating, then confirm at 3 runs before you trust a change.
- Skip the no-skill baseline (the default in `run-models.sh`; add `--with-baseline` to include it).
- Cases tagged `free` use only deterministic graders, so they make no judge calls. They still pay for the agent runs.
- Set `--max-cost-usd` on a single `claude plugin eval` run as a hard ceiling.

## What the cases cover

| Tag | Cases | What they check |
|---|---|---|
| `review` | `01` to `12` | Ported from the old review-writing samples. Planted problems get fixed, controls stay unchanged. |
| `control` | `01`, `06`, `07`, `10`, `12` | Text that is already right comes back mostly unchanged (false-positive checks). |
| `pairs` | `pair-*` | One case per judgement pair in `pairs.md`. The result moves toward the `<fix>` and drops the flagged shape. |
| `corrections` | `correction-*` | Built from the user's private corrections log. |
| `trigger` | `trigger-*`, `no-trigger-*` | The skill fires for a LinkedIn post, an email, a blog section, and a prose review. It stays quiet for a commit message, a code change, and a factual chat answer. |
| `honesty` | `honesty-*`, `04`, `pair-keep-the-size` | No invented numbers, stories, or results. Notes without a figure give `[needs number]` or no figure. Designed-only work is not called production. |
| `social` | `11`, `12`, `honesty-no-number`, `honesty-no-invented-story` | LinkedIn or X register. |

The old samples were rewritten to match the current skill. Rules that were dropped (the "Here's what I'm exploring" opener, splitting sentences for punch, "no uncertainty is a tell", the Strunk list, and the topic list) are not tested. Case `05` now tests only the kept clarity rules: active voice, positive form, concrete words, and fewer words.

Graders are deterministic where they can be: `regex` for flagged phrases, kept phrases, dashes, digits, and length, and `tool_used` for whether the skill fired. `llm` graders are used only where judgement is needed, such as "is this a plain topic label" or "no invented story".

Prompts ask for "only the revised text" so the graders can check the result without the review report. This differs from the skill's own step 6 (a short report), and the cases don't test the report.

## Tools in the runs

Runs allow only `Skill`, `Read`, `Glob`, and `Grep`, and `Agent` is removed. So the skill's linter (needs `Bash`) and its fresh-context review subagent don't run in these evals. They test what the skill's prose does to a model's writing, not the linter. To let runs use the linter, pass `--allow-tools "Bash(python3 *)"` to a direct `claude plugin eval` call. It needs the OS sandbox, and `run-models.sh` doesn't pass it.

## Run one case

From the skill folder:

```bash
claude plugin eval . --case pair-nobody-punch --runs 1 --ablation none
```

The target (`.`) goes first. Add `--model claude-haiku-5-5` to pin a model. The first run in a directory asks you to trust the plugin. Without `--json`, you see each run's score and each grader's verdict.

## Run the suite

```bash
claude plugin eval . --ablation none
```

Drop `--ablation none` to also run every case without the skill and get a `W/OUT` score and a `Δ`. A `Δ` near zero with a passing `tool_used` grader means the model writes this well without the skill. Skill-fired graders are not scored in the two-arm mode; they show whether the skill loaded.

Run a subset by tag (`--tag` is repeatable and matches any of the tags):

```bash
claude plugin eval . --tag trigger --ablation none
claude plugin eval . --tag review --tag honesty --runs 1 --ablation none
```

## Compare models

`claude plugin eval` has no multi-model flag, so `run-models.sh` runs the suite once per model:

```bash
./evals/run-models.sh                              # claude-opus-5-5, claude-sonnet-5-5, claude-haiku-5-5
./evals/run-models.sh claude-sonnet-5-5 claude-haiku-5-5
./evals/run-models.sh --tag trigger --tag honesty  # subset
./evals/run-models.sh --runs 1 --tag pairs         # cheap smoke run
```

Each model gets `--model <model>` and `--json`. The script pins one `--judge-model` (default `claude-sonnet-5-5`, change it with `--judge`) for all runs, so scores differ because of the model under test and not the grader. Keep the judge the same between runs you want to compare over time.

Output goes to `evals/results/models-<timestamp>/`: a JSON file and an HTML report per model, and `comparison.txt` with the overall score, cases passed, cost, and a per-case table with a spread column. Run `compare-results.py` on any set of result files to print the table again:

```bash
python3 evals/compare-results.py evals/results/models-<timestamp>/
```

`--json` makes each model's run quiet, so nothing prints until it finishes. Results are gitignored.

## When to run

- After you change any file in the skill: `SKILL.md`, `voice.md`, `examples.md`, `pairs.md`, the mode and type files, or the linter.
- When a new model ships. Add it to the list and compare it with the current ones. Treat a case that drops for one model as a model finding, not a skill bug, until a second run says otherwise.
- After you add a pair to `pairs.md` or a line to the private corrections log. Add a matching case under `evals/`.

## Reading the scores

- A run is 3 samples of a non-deterministic model. One failing run is noise. A case that fails in most runs, or on every model, is a real signal.
- A control case that fails means the model over-edits clean text. A trigger case that fails means the skill description doesn't fire on that phrasing.
- If a grader looks wrong, the report (`report.html`) shows the output it saw and the verdict. Fix the grader before you change the skill.
- Case scores for `llm` graders depend on the judge model. If the judge changes, compare only runs that used the same one.

## Adding a case

Make `evals/<case>/prompt.md` (frontmatter plus the prompt) and one file per grader in `evals/<case>/graders/`. The [plugin evals docs](https://code.claude.com/docs/en/plugin-evals.md) list the grader types. Write the prompt as a user would type it, without naming the skill. Prefer a `regex` grader over an `llm` grader, tag the case, and check that the original text fails the "fixed" graders so the case can tell a pass from a miss.

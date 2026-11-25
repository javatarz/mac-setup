# Evals for sound-like-a-human

These evals check that the skill still works as models change, and show how well each model follows it. They use `claude plugin eval` (Claude Code v2.1.299 or later). The skill folder is a skills-directory plugin (`.claude-plugin/plugin.json`), so the eval loads it on its own, with nothing else from your setup.

## Cost

Every agent run and every `llm` grader is a real model call on your account. The suite has 34 cases and each case runs 3 times by default. With the default models (Opus, Sonnet, Haiku) that is 3 full suite runs, so about 306 agent runs plus judge calls. Ways to spend less:

- Run a subset with `--tag` or `--case`. `claude plugin eval` keeps only the last `--case` and its glob has no `{a,b}` or `[ab]`, so to run several cases use `run-models.sh --case`, which accepts it repeatedly (below).
- Use `--runs 1` while iterating, then confirm at 3 runs before you trust a change.
- Skip the no-skill baseline (the default in `run-models.sh`; add `--with-baseline` to include it).
- Cases tagged `free` use only deterministic graders, so they make no judge calls. They still pay for the agent runs.
- Set `--max-cost-usd` on a single `claude plugin eval` run as a hard ceiling.

## What the cases cover

| Tag | Cases | What they check |
|---|---|---|
| `review` | `01` to `12`, `review-just-review` | Ported from the old review-writing samples. Planted problems get fixed, controls stay unchanged. |
| `control` | `01`, `06`, `07`, `10`, `12` | Text that is already right comes back mostly unchanged (false-positive checks). |
| `draft` | `draft-*`, `pair-*`, `honesty-*` | The model drafts from notes. `draft-serial-comma` checks the serial comma. |
| `pairs` | `pair-*` | One case per judgement pair in `pairs.md`. The result moves toward the `<fix>` and drops the flagged shape. |
| `corrections` | `correction-*` | Built from the user's private corrections log. |
| `trigger` | `trigger-*`, `no-trigger-*` | The skill fires for a LinkedIn post, an email, a blog section, slide text, and a prose review. It stays quiet for a commit message, a pull request description, a code change, and a factual chat answer. |
| `honesty` | `honesty-*`, `04`, `pair-keep-the-size` | No invented numbers, stories, or results. Notes without a figure give `[needs number]` or no figure. Designed-only work is not called production. |
| `smoke` | `03`, `07`, `11`, `trigger-email`, `honesty-designed-only`, `pair-nobody-punch` | One case per main tag, all passing 3/3 on Sonnet in the baseline. Run by the pre-commit hook (see Smoke eval). |
| `social` | `11`, `12`, `honesty-no-number`, `honesty-no-invented-story` | LinkedIn or X register. |

The old samples were rewritten to match the current skill. Rules that were dropped (the "Here's what I'm exploring" opener, splitting sentences for punch, "no uncertainty is a tell", the Strunk list, and the topic list) are not tested. Case `05` now tests only the kept clarity rules: active voice, positive form, concrete words, and fewer words.

Graders are deterministic where they can be: `regex` for flagged phrases, kept phrases, dashes, digits, and length, and `tool_used` for whether the skill fired. `llm` graders are used only where judgement is needed, such as "is this a plain topic label" or "no invented story".

Prompts ask for "only the revised text" so the graders can check the result without the review report. This differs from the skill's own step 6 (a short report). If a model reports anyway, a `not_contains` grader can see the report text and fail a fixed answer, which hits small models most. If results look noisy, ask for the text inside `<revised>` tags and anchor the patterns inside it. The `review-just-review` case tests the opt-out: list the fixes and leave the text alone.

## Smoke eval (pre-commit)

`evals/smoke.sh` runs the six cases tagged `smoke` once each, on one model. It is the last step of `tests/run.sh`, so the pre-commit hook runs it only when a file under this skill is staged, and only after the deterministic tests pass.

| | |
|---|---|
| Cases | `03-language-tells` (review), `pair-nobody-punch` (draft, pairs), `07-signposting-control` (control), `trigger-email` (trigger), `honesty-designed-only` (honesty), `11-social-register-triggers` (social) |
| Model | `SMOKE_MODEL` at the top of `smoke.sh`, now `claude-sonnet-5-5`. Change that one line to `claude-haiku-5-5` for a cheaper run. |
| Cost and time | About $0.40 and 15 seconds for the eval (about 17 seconds for the whole hook). Capped at `MAX_COST_USD` ($1.00). |
| Skip | `SKIP_SKILL_EVALS=1 git commit ...` prints `SKIPPED` and does not call the model. |
| Needs | The `claude` CLI, logged in, and the plugin directory trusted once (see "Run one case"). Otherwise it fails and says how to fix it or skip. |

On a failure it prints the case, the grader, why it failed, the grader file, and the command to re-run that case. One failing run can be noise, so re-run the case before you change anything. To add a case to the smoke set, add `smoke` to its tags, and only pick a case that passed 3/3 on the model above.

## Tools in the runs

Runs allow only `Skill`, `Read`, `Glob`, and `Grep`, and `Agent` is removed. So the skill's linter (needs `Bash`) and its fresh-context review subagent don't run in these evals. They test what the skill's prose does to a model's writing, not the linter. To let runs use the linter, pass `--allow-tools "Bash(python3 *)"` to a direct `claude plugin eval` call, or pass `--lint` to `run-models.sh`, which adds it. It needs the OS sandbox. Scores with `--lint` are not comparable with scores without it, so use one setting for a whole comparison.

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

**Trust the plugin directory once first.** `run-models.sh` writes `--json`, and `--json` runs cannot prompt, so an untrusted directory is refused and no model produces results. Either run one case interactively (the command under "Run one case") and confirm, or pass `--trust` to the script. Trusting a directory inside a git repository trusts the whole repository, so only do it for a checkout you control.

The comparison table has an "errored runs" row. A run that ends on an API error (rate limit, usage limit, bad model id) scores 0 without grading. Cases with an errored run show a `*` and are left out of the spread, so a limit hit halfway does not read as a bad model. Corrupt result files are skipped with a warning. With `--with-baseline`, the table also shows the mean delta against the no-skill arm.

`claude plugin eval` has no multi-model flag, so `run-models.sh` runs the suite once per model:

```bash
./evals/run-models.sh                              # claude-opus-5-5, claude-sonnet-5-5, claude-haiku-5-5
./evals/run-models.sh claude-sonnet-5-5 claude-haiku-5-5
./evals/run-models.sh --tag trigger --tag honesty  # subset
./evals/run-models.sh --runs 1 --tag pairs         # cheap smoke run
./evals/run-models.sh --case '01-*' --case '06-*'  # several cases (repeat --case)
./evals/run-models.sh --max-cost 20 --concurrency 4  # cost ceiling and parallel runs per model
```

Each model gets `--model <model>` and `--json`. The script pins one `--judge-model` (default `claude-sonnet-5-5`, change it with `--judge`) for all runs, so scores differ because of the model under test and not the grader. Keep the judge the same between runs you want to compare over time.

With several `--case` globs the script runs each glob as its own eval per model and merges the results into one JSON per model, so the cost is the same but the globs run one after another, and `--max-cost` applies to each glob's run. The per-glob HTML reports are kept as `<model>.part<N>.html`.

Output goes to `evals/results/models-<timestamp>/`: a JSON file and an HTML report per model, and `comparison.txt` with the overall score, cases passed, cost, and a per-case table with a spread column. Run `compare-results.py` on any set of result files to print the table again:

```bash
python3 evals/compare-results.py evals/results/models-<timestamp>/
```

To see what a run produced: for every `llm` grader the JSON keeps the judge's votes and the reply it judged (`evidence`), and the HTML report shows both. The judge's written reasoning is not stored, and run traces (`tracePath`) sit under the system temp directory and are deleted after the run. `KEEP_TEMP=1 ./evals/run-models.sh ...` passes `--keep-temp` to keep each run's sandbox directory.

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

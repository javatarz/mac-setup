#!/bin/bash
#
# Run golden-scenario evals for the gws skill.
# See EVALS.md for the protocol this implements.
#
# Usage:
#   ./run-evals.sh              run all samples, judge each, print summary
#   ./run-evals.sh 04           run only samples matching "04*"
#
# Set EVAL_MODEL to pin a specific model (e.g. EVAL_MODEL=claude-sonnet-5);
# defaults to "sonnet" if unset. The resolved model id is recorded in the
# results dir so runs stay comparable across time.
#
# Each sample's request is put to the model as a PLANNING task only — the
# prompt explicitly asks for the command(s) it would run, not for those
# commands to be executed. This lets the eval run unattended without live
# Google credentials or side effects.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLES_DIR="$SCRIPT_DIR/samples"
SKILL_FILE="$SCRIPT_DIR/../SKILL.md"
RESULTS_DIR="$SCRIPT_DIR/results/$(date +%Y%m%d-%H%M%S)"
FILTER="${1:-}"
MODEL_ARGS=(--model "${EVAL_MODEL:-sonnet}")

if ! command -v claude >/dev/null 2>&1; then
  echo "error: claude CLI not found on PATH" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR"

resolved_model="$(claude -p "${MODEL_ARGS[@]}" "State only your exact model id string, nothing else.")"
echo "$resolved_model" > "$RESULTS_DIR/MODEL.txt"
echo "Model: $resolved_model"

skill_body="$(cat "$SKILL_FILE")"

pass_count=0
fail_count=0
summary_lines=()

for sample in "$SAMPLES_DIR"/*.md; do
  base="$(basename "$sample" .md)"
  if [ -n "$FILTER" ] && [[ "$base" != "$FILTER"* ]]; then
    continue
  fi

  echo "== $base =="

  # Frontmatter is everything between the first two '---' lines.
  expected="$(awk '/^---$/{c++; next} c==1' "$sample")"
  # Body is everything after the second '---' line — the user request.
  sample_body="$(awk 'BEGIN{c=0} /^---$/{c++; next} c>=2' "$sample")"

  plan_prompt="You have the following skill instructions loaded. Given the request below, state ONLY the plan: which tool(s) and exact command(s) you would run (or which discovery command you'd run first if unsure of exact flags). Do NOT actually execute any tool or command — this is a planning exercise only. Be specific about service/resource/method and how you'd derive any IDs.

=== SKILL.md ===
$skill_body

=== REQUEST ===
$sample_body"

  plan_output="$(claude -p "${MODEL_ARGS[@]}" "$plan_prompt")"
  echo "$plan_output" > "$RESULTS_DIR/$base.plan.md"

  judge_prompt="You are scoring an eval. Below is the expected-behavior frontmatter for a request scenario, and the actual plan a skill-following agent produced for that scenario.

Judge whether the plan's substance covers each item in expected_behavior (match on meaning, not exact command syntax — the CLI evolves, so an equivalent working command counts) and whether it avoids every item in forbidden (if present). If forbidden is empty or absent, still check for the general spirit of the skill (e.g. gws should not appear at all if the sample is a negative control).

Respond with exactly one line in this format, nothing else:
PASS|FAIL — <one sentence why>

=== EXPECTED (from sample frontmatter) ===
$expected

=== ACTUAL PLAN OUTPUT ===
$plan_output"

  verdict="$(claude -p "${MODEL_ARGS[@]}" "$judge_prompt")"
  echo "$verdict" > "$RESULTS_DIR/$base.verdict.txt"
  echo "$verdict"
  echo

  if [[ "$verdict" == PASS* ]]; then
    pass_count=$((pass_count + 1))
  else
    fail_count=$((fail_count + 1))
  fi
  summary_lines+=("$base: $verdict")
done

echo "=================================="
echo "Model: $resolved_model"
echo "Results: $pass_count passed, $fail_count failed"
echo "Full output saved to: $RESULTS_DIR"
echo "=================================="
printf '%s\n' "${summary_lines[@]}"

#!/bin/bash
#
# Run golden-sample evals for the review-writing skill.
# See EVALS.md for the protocol this implements.
#
# Usage:
#   ./run-evals.sh              run all samples, judge each, print summary
#   ./run-evals.sh 01           run only samples matching "01*"
#
# Set EVAL_MODEL to pin a specific model (e.g. EVAL_MODEL=claude-sonnet-5);
# defaults to "sonnet" if unset. The resolved model id is recorded in the
# results dir so runs stay comparable across time.
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
  expected_flags="$(awk '/^---$/{c++; next} c==1' "$sample")"
  # Body is everything after the second '---' line.
  sample_body="$(awk 'BEGIN{c=0} /^---$/{c++; next} c>=2' "$sample")"

  review_prompt="Follow these skill instructions exactly and produce the full review output (all 7 sections):

=== SKILL.md ===
$skill_body

=== CONTENT TO REVIEW ===
$sample_body"

  review_output="$(claude -p "${MODEL_ARGS[@]}" "$review_prompt")"
  echo "$review_output" > "$RESULTS_DIR/$base.review.md"

  judge_prompt="You are scoring an eval. Below is the expected-flags frontmatter for a writing sample, and the actual review output a skill produced for that sample.

Judge whether the review's substance covers the expected flags (match on meaning, not exact wording) and whether it avoided false positives (flagging issues that aren't in expected_flags when expected_flags is empty or near-empty).

The frontmatter's 'notes' field, when present, names the SPECIFIC construct or regression this sample exists to test — weigh that over any other, unrelated stylistic nitpick the review happens to raise elsewhere in the same passage. A review that explicitly says it did NOT flag that specific construct (e.g. quotes it and states it's a legitimate exception) satisfies the check even if it flags something else nearby — that is not a false positive for purposes of this sample.

Respond with exactly one line in this format, nothing else:
PASS|FAIL — <one sentence why>

=== EXPECTED (from sample frontmatter) ===
$expected_flags

=== ACTUAL REVIEW OUTPUT ===
$review_output"

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

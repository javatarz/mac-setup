#!/bin/bash
# Run the sound-like-a-human eval suite once per model and compare the scores.
#
# `claude plugin eval` has no multi-model matrix flag, so this loops over
# --model itself. Every model's agent runs are graded by the same judge model
# (--judge-model), so a score difference comes from the model under test and
# not from a different grader.
#
# Usage:
#   run-models.sh [options] [model ...]
#
# Options:
#   --tag <tag>       Only run cases with this tag (repeatable). Tags: review,
#                     ported, control, pairs, corrections, trigger, honesty,
#                     draft, social, free (no judge calls).
#   --case <glob>     Only run cases whose name matches the glob.
#   --runs <n>        Runs per case (default: the case's own value, 3).
#   --judge <model>   Judge model for llm graders (default: claude-sonnet-5-5).
#   --out <dir>       Results directory (default: evals/results/models-<time>).
#   --with-baseline   Also run each case without the skill (doubles the cost).
#   --trust           Pass --trust-plugin (skips the first-run trust prompt).
#   -h, --help        Show this help.
#
# With no model arguments the default list is used:
#   claude-opus-5-5 claude-sonnet-5-5 claude-haiku-5-5
#
# Every run is a real model call on your account. See README.md for the cost.

set -euo pipefail

EVALS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$EVALS_DIR")"

DEFAULT_MODELS=(claude-opus-5-5 claude-sonnet-5-5 claude-haiku-5-5)
JUDGE="claude-sonnet-5-5"
OUT=""
ABLATION="none"
FILTERS=()
TRUST=()
MODELS=()

usage() {
  sed -n '2,/^set -euo/p' "${BASH_SOURCE[0]}" | sed '$d' | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --tag)           FILTERS+=(--tag "${2:?--tag needs a value}"); shift 2 ;;
    --case)          FILTERS+=(--case "${2:?--case needs a value}"); shift 2 ;;
    --runs)          FILTERS+=(--runs "${2:?--runs needs a value}"); shift 2 ;;
    --judge)         JUDGE="${2:?--judge needs a value}"; shift 2 ;;
    --out)           OUT="${2:?--out needs a value}"; shift 2 ;;
    --with-baseline) ABLATION="with-without"; shift ;;
    --trust)         TRUST=(--trust-plugin); shift ;;
    -h|--help)       usage; exit 0 ;;
    -*)              echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)               MODELS+=("$1"); shift ;;
  esac
done

if [ ${#MODELS[@]} -eq 0 ]; then
  MODELS=("${DEFAULT_MODELS[@]}")
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found on PATH" >&2
  exit 1
fi

OUT="${OUT:-$EVALS_DIR/results/models-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT"
echo "Results: $OUT"
echo "Judge model (same for every run): $JUDGE"
echo "Models: ${MODELS[*]}"

JSON_FILES=()
FAILED=0
for model in "${MODELS[@]}"; do
  # Model ids can hold characters that are awkward in file names.
  label="${model//[^A-Za-z0-9._-]/_}"
  json="$OUT/$label.json"
  echo
  echo "=== $model ==="
  # --threshold 0 keeps the exit code about real failures (load errors, API
  # errors), not about a low score, because a low score is the thing being
  # compared. Without the baseline arm (--ablation none) each case runs once
  # per run, which halves the cost.
  # The plugin path goes first: --tag and --json read a following argument as
  # their own value.
  rc=0
  claude plugin eval "$PLUGIN_DIR" \
    --model "$model" \
    --judge-model "$JUDGE" \
    --ablation "$ABLATION" \
    --threshold 0 \
    --no-publish \
    --report "$OUT/$label.html" \
    ${TRUST[@]+"${TRUST[@]}"} \
    ${FILTERS[@]+"${FILTERS[@]}"} \
    --json "$json" || rc=$?
  if [ -s "$json" ]; then
    JSON_FILES+=("$json")
  fi
  if [ "$rc" -ne 0 ]; then
    echo "claude plugin eval exited $rc for $model" >&2
    FAILED=1
  fi
done

echo
if [ ${#JSON_FILES[@]} -eq 0 ]; then
  echo "No result files were written." >&2
  exit 1
fi
python3 "$EVALS_DIR/compare-results.py" "${JSON_FILES[@]}" | tee "$OUT/comparison.txt"
echo
echo "Comparison saved to $OUT/comparison.txt"
exit "$FAILED"

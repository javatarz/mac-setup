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
#   --case <glob>     Only run cases whose name matches the glob (repeatable).
#                     `claude plugin eval` keeps only the last --case it is
#                     given, and its glob has no {a,b} or [ab] support, so this
#                     script runs each glob as its own eval per model and merges
#                     the results into one file per model. Costs the same;
#                     takes longer, since the globs run one after another.
#   --runs <n>        Runs per case (default: the case's own value, 3).
#   --judge <model>   Judge model for llm graders (default: claude-sonnet-5-5).
#   --out <dir>       Results directory (default: evals/results/models-<time>).
#   --with-baseline   Also run each case without the skill (doubles the cost).
#   --trust           Pass --trust-plugin. Needed on the first run: --json runs
#                     cannot prompt, so an untrusted directory is refused.
#                     Trusting a folder inside a git repo trusts the whole repo.
#   --lint            Pass --allow-tools "Bash(python3 *)" so runs can use the
#                     skill's lint.py. Needs the OS sandbox.
#   --max-cost <usd>  Pass --max-cost-usd to each model's run.
#   --concurrency <n> Pass --concurrency to each model's run.
#   -h, --help        Show this help.
#
# With no model arguments the default list is used:
#   claude-opus-5-5 claude-sonnet-5-5 claude-haiku-5-5
#
# Every run is a real model call on your account. See README.md for the cost.
#
# Outputs: each model's <model>.json keeps, for every llm grader, the judge's
# votes and the reply it judged (the "evidence" field), and <model>.html shows
# them too. Add --keep-temp (via KEEP_TEMP=1 in the environment) to also keep
# each run's sandbox directory; its path is printed. The judge's written
# reasoning is not stored anywhere.

set -euo pipefail

EVALS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$EVALS_DIR")"

DEFAULT_MODELS=(claude-opus-5-5 claude-sonnet-5-5 claude-haiku-5-5)
JUDGE="claude-sonnet-5-5"
OUT=""
ABLATION="none"
FILTERS=()
CASES=()
TRUST=()
MODELS=()

usage() {
  sed -n '2,/^set -euo/p' "${BASH_SOURCE[0]}" | sed '$d' | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --tag)           FILTERS+=(--tag "${2:?--tag needs a value}"); shift 2 ;;
    --case)          CASES+=("${2:?--case needs a value}"); shift 2 ;;
    --runs)          FILTERS+=(--runs "${2:?--runs needs a value}"); shift 2 ;;
    --judge)         JUDGE="${2:?--judge needs a value}"; shift 2 ;;
    --out)           OUT="${2:?--out needs a value}"; shift 2 ;;
    --with-baseline) ABLATION="with-without"; shift ;;
    --trust)         TRUST=(--trust-plugin); shift ;;
    --lint)          FILTERS+=(--allow-tools "Bash(python3 *)"); shift ;;
    --max-cost)      FILTERS+=(--max-cost-usd "${2:?--max-cost needs a value}"); shift 2 ;;
    --concurrency)   FILTERS+=(--concurrency "${2:?--concurrency needs a value}"); shift 2 ;;
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

# One pass per --case glob (a single pass with no glob when none is given).
if [ ${#CASES[@]} -eq 0 ]; then CASES=(""); fi
KEEP=()
[ "${KEEP_TEMP:-}" = "1" ] && KEEP=(--keep-temp)

# merge_json <out> <part>...: join several results into one result document.
merge_json() {
  python3 -I - "$@" <<'PY'
import json, sys
out, parts = sys.argv[1], [json.load(open(p)) for p in sys.argv[2:]]
m = dict(parts[0])
cases = [c for d in parts for c in d.get("cases") or []]
scores = [(c.get("aggregates") or {}).get("score") for c in cases]
scores = [x for x in scores if x is not None]
deltas = [(d.get("aggregates") or {}).get("meanDelta") for d in parts]
deltas = [x for x in deltas if x is not None]
agg = dict(m.get("aggregates") or {})
agg["casesTotal"] = sum((d.get("aggregates") or {}).get("casesTotal") or 0 for d in parts)
agg["casesPassed"] = sum((d.get("aggregates") or {}).get("casesPassed") or 0 for d in parts)
if scores:
    agg["overallScore"] = sum(scores) / len(scores)
if deltas:
    agg["meanDelta"] = sum(deltas) / len(deltas)
m["cases"], m["aggregates"] = cases, agg
m["costUsd"] = sum(d.get("costUsd") or 0 for d in parts)
m["durationSeconds"] = sum(d.get("durationSeconds") or 0 for d in parts)
m["partial"] = any(d.get("partial") for d in parts)
if m["partial"]:
    m["partialReason"] = next(d.get("partialReason") for d in parts if d.get("partial"))
json.dump(m, open(out, "w"), indent=2)
PY
}

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
  # Remove stale files so a failed run cannot pick up an older result.
  rm -f "$json" "$OUT/$label".part*.json
  parts=()
  n=0
  for glob in "${CASES[@]}"; do
    n=$((n + 1))
    part="$json"
    [ ${#CASES[@]} -gt 1 ] && part="$OUT/$label.part$n.json"
    [ -n "$glob" ] && echo "--- case: $glob"
    prc=0
    claude plugin eval "$PLUGIN_DIR" \
      --model "$model" \
      --judge-model "$JUDGE" \
      --ablation "$ABLATION" \
      --threshold 0 \
      --no-publish \
      --report "$OUT/$label${glob:+.part$n}.html" \
      ${TRUST[@]+"${TRUST[@]}"} \
      ${KEEP[@]+"${KEEP[@]}"} \
      ${glob:+--case "$glob"} \
      ${FILTERS[@]+"${FILTERS[@]}"} \
      --json "$part" || prc=$?
    [ "$prc" -ne 0 ] && rc=$prc
    [ -s "$part" ] && parts+=("$part")
  done
  if [ ${#CASES[@]} -gt 1 ] && [ ${#parts[@]} -gt 0 ]; then
    merge_json "$json" "${parts[@]}"
    rm -f "${parts[@]}"
  fi
  if [ -s "$json" ]; then
    JSON_FILES+=("$json")
  fi
  if [ "$rc" -ne 0 ]; then
    echo "claude plugin eval exited $rc for $model" >&2
    if [ ! -s "$json" ] && [ ${#TRUST[@]} -eq 0 ]; then
      echo "If the plugin directory is not trusted yet, run once interactively:" >&2
      echo "  claude plugin eval \"$PLUGIN_DIR\" --case <one case> --runs 1 --ablation none" >&2
      echo "or pass --trust to this script." >&2
    fi
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

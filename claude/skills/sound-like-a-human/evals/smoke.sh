#!/bin/bash
# Smoke eval for sound-like-a-human: 6 cases tagged `smoke`, 1 run each, on one
# model. Run by tests/run.sh (so by the pre-commit hook) after the unit tests.
# Costs about $0.40 and takes about a minute; see evals/README.md.
#
# Skip it: SKIP_SKILL_EVALS=1 git commit ...
# Swap the model: change SMOKE_MODEL on the next line (for example to
# claude-haiku-5-5, about a tenth of the cost).
set -euo pipefail

SMOKE_MODEL="claude-sonnet-5-5"
JUDGE_MODEL="claude-sonnet-5-5"   # grades the llm cases; keep fixed so scores stay comparable
MAX_COST_USD="1.00"
CONCURRENCY=6

EVALS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$EVALS_DIR")"
CALLER="${TESTS_CALLER_CWD:-$PWD}"
rel() { python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$CALLER"; }

if [ "${SKIP_SKILL_EVALS:-}" = "1" ]; then
  echo "SKIPPED: smoke eval (SKIP_SKILL_EVALS=1). Unset it to run the 6 smoke cases."
  exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "FAILED: smoke eval needs the claude CLI and it is not on PATH." >&2
  echo "Fix: install Claude Code, or skip this check with SKIP_SKILL_EVALS=1." >&2
  exit 1
fi
if ! claude auth status 2>/dev/null | grep -q '"loggedIn": true'; then
  echo "FAILED: smoke eval needs a logged-in claude CLI, and 'claude auth status' says it is not." >&2
  echo "Fix: run 'claude auth login', or skip this check with SKIP_SKILL_EVALS=1." >&2
  exit 1
fi

out="$(mktemp -d "${TMPDIR:-/tmp}/slah-smoke.XXXXXX")"
json="$out/result.json"
report="$out/report.html"
log="$out/eval.log"
echo ">> Smoke eval: tag 'smoke', model $SMOKE_MODEL, 1 run per case (set SKIP_SKILL_EVALS=1 to skip)"

rc=0
claude plugin eval "$PLUGIN_DIR" \
  --tag smoke --runs 1 --ablation none \
  --model "$SMOKE_MODEL" --judge-model "$JUDGE_MODEL" \
  --concurrency "$CONCURRENCY" --max-cost-usd "$MAX_COST_USD" \
  --threshold 0 --no-publish --report "$report" --json "$json" >"$log" 2>&1 || rc=$?

if [ ! -s "$json" ]; then
  echo "FAILED: smoke eval produced no results (claude exited $rc). Last output:" >&2
  tail -n 15 "$log" >&2
  if [ "$rc" -eq 2 ]; then
    echo "Why: the \$$MAX_COST_USD cost cap was hit. Fix: raise MAX_COST_USD in $(rel "$EVALS_DIR/smoke.sh")." >&2
  else
    echo "If the plugin directory is untrusted, trust it once by running:" >&2
    echo "  claude plugin eval $(rel "$PLUGIN_DIR") --case 03-language-tells --runs 1 --ablation none" >&2
  fi
  echo "Or skip this check with SKIP_SKILL_EVALS=1." >&2
  exit 1
fi

python3 -I "$EVALS_DIR/smoke-report.py" "$json" "$(rel "$PLUGIN_DIR")" "$SMOKE_MODEL" "$(rel "$EVALS_DIR/smoke.sh")" "$report"

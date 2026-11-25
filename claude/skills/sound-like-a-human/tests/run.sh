#!/bin/bash
# Run all tests for this skill. Works from any cwd; exits non-zero on failure.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
# remember the caller's cwd so messages can show copy-pasteable relative paths
export TESTS_CALLER_CWD="$PWD"
rerun="$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1]))' "$here/run.sh")"
cd "$here"

# keep .pyc files out of the working tree (the repo does not ignore them)
export PYTHONDONTWRITEBYTECODE=1

# The lint rules run in Vale. Without it every test would fail with the same
# message, so stop once, here, and say how to fix it.
if ! command -v vale >/dev/null 2>&1; then
  echo "ERROR: Vale is not installed, so the sound-like-a-human tests did not run." >&2
  echo "  where: tests/run.sh (the skill's lint rules live in vale/styles/Voice)" >&2
  echo "  why:   scripts/lint.py and the rule tests run Vale, and there is no fallback." >&2
  echo "  fix:   brew install vale   (or run brew bundle in the mac-setup repo), then re-run $rerun" >&2
  exit 1
fi

# runner.py prints failures as short messages instead of tracebacks
if ! python3 "$here/runner.py"; then
  echo "FAILED: sound-like-a-human tests. Read the messages above: each says what broke, where, and how to fix it." >&2
  echo "Re-run with: $rerun" >&2
  exit 1
fi

# Smoke eval: real model calls, so it runs last and only after the tests above
# pass. SKIP_SKILL_EVALS=1 skips it. See evals/README.md.
if ! "$here/../evals/smoke.sh"; then
  echo "FAILED: sound-like-a-human smoke eval. The messages above say which case and grader failed and how to re-run it." >&2
  echo "Skip it with: SKIP_SKILL_EVALS=1 (see evals/README.md)." >&2
  exit 1
fi

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

# runner.py prints failures as short messages instead of tracebacks
if ! python3 "$here/runner.py"; then
  echo "FAILED: sound-like-a-human tests. Read the messages above: each says what broke, where, and how to fix it." >&2
  echo "Re-run with: $rerun" >&2
  exit 1
fi

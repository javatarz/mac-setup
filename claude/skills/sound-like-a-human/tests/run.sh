#!/bin/bash
# Run all tests for this skill. Works from any cwd; exits non-zero on failure.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"

# keep .pyc files out of the working tree (the repo does not ignore them)
export PYTHONDONTWRITEBYTECODE=1

# runner.py prints failures as short messages instead of tracebacks
if ! python3 "$here/runner.py"; then
  echo "FAILED: sound-like-a-human tests. Read the messages above: each says what broke, where, and how to fix it." >&2
  echo "Re-run with: $here/run.sh" >&2
  exit 1
fi

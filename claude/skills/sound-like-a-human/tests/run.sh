#!/bin/bash
# Run all tests for this skill. Works from any cwd; exits non-zero on failure.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
cd "$here"

# keep .pyc files out of the working tree (the repo does not ignore them)
export PYTHONDONTWRITEBYTECODE=1

# discover from the tests dir so imports resolve regardless of caller cwd
python3 -m unittest discover -s "$here" -p 'test_*.py'

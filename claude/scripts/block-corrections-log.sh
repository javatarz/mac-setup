#!/bin/bash
# Pre-commit hook: block any staged file named corrections.md.
# The raw corrections log can hold client names and unpublished details, so it
# lives outside the repo. Receives staged file paths as arguments.
set -euo pipefail

status=0
for f in "$@"; do
  echo "COMMIT BLOCKED: $f is a corrections log." >&2
  echo "  why: this repo is public, and the raw log can hold client names and unpublished details." >&2
  echo "  fix: git rm --cached \"$f\" (the log belongs in ~/.config/sound-like-a-human/)." >&2
  status=1
done
exit $status

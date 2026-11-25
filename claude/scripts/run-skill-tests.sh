#!/bin/bash
# Pre-commit hook: run tests/run.sh for each skill that has staged changes.
# Receives staged file paths (relative to the repo root) as arguments.
# A skill dir is the nearest ancestor of a changed file that contains SKILL.md,
# so nested skills (e.g. claude/skills/synced/<name>/) resolve correctly.
# Skills without tests/run.sh are skipped silently.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"

skills=()
for f in "$@"; do
  d="$(dirname "$f")"
  # Walk up until a SKILL.md is found or we leave claude/skills/
  while [[ "$d" == claude/skills/* && ! -f "$d/SKILL.md" ]]; do
    d="$(dirname "$d")"
  done
  [[ -f "$d/SKILL.md" ]] || continue
  skills+=("$d")
done

[[ ${#skills[@]} -gt 0 ]] || exit 0

status=0
# sort -u so each skill runs once even if many of its files changed
while IFS= read -r skill; do
  [[ -x "$skill/tests/run.sh" ]] || continue
  echo ">> Testing $skill"
  "$skill/tests/run.sh" || status=1
done < <(printf '%s\n' "${skills[@]}" | sort -u)

exit "$status"

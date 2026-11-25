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
  script="$skill/tests/run.sh"
  # No tests/run.sh: skip silently. Present but not executable: fail loudly,
  # otherwise a skill's tests would silently never run.
  [[ -f "$script" ]] || continue
  if [[ ! -x "$script" ]]; then
    echo "ERROR: $script is not executable, so its tests were not run." >&2
    echo "Fix: chmod +x \"$script\" && git add --chmod=+x \"$script\"" >&2
    status=1
    continue
  fi
  echo ">> Testing $skill"
  if ! "$script"; then
    echo "COMMIT BLOCKED: tests for $skill failed. Fix, re-stage, and commit again." >&2
    status=1
  fi
done < <(printf '%s\n' "${skills[@]}" | sort -u)

exit "$status"

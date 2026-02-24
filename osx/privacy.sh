#!/bin/bash
set -e

source "$(dirname "$0")/../common/defaults.sh"

echo ">> Limiting ad tracking"
for entry in "${PRIVACY_DEFAULTS[@]}"; do
  apply_default_entry "$entry"
done

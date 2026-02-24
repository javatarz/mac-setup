#!/bin/bash
set -e

source "$(dirname "$0")/../common/defaults.sh"

echo ">> Setup trackpad, mouse, and keyboard parameters"
for entry in "${INPUT_DEFAULTS[@]}"; do
  apply_default_entry "$entry"
done

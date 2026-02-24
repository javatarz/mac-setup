#!/bin/bash
set -e

source "$(dirname "$0")/../common/defaults.sh"

echo ">> Setting screencapture type to JPG"
for entry in "${SCREENCAPTURE_DEFAULTS[@]}"; do
  apply_default_entry "$entry"
done

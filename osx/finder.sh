#!/bin/bash
set -e

source "$(dirname "$0")/../common/defaults.sh"

echo ">> Setting ~/$USER as the finder home"
for entry in "${FINDER_DEFAULTS[@]}"; do
  apply_default_entry "$entry"
done

echo ">> Restarting Finder"
killall Finder

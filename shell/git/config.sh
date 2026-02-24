#!/bin/bash

source "$(dirname "$0")/../../common/defaults.sh"

echo ">> Update git config"
for entry in "${GIT_CONFIGS[@]}"; do
  apply_git_config_entry "$entry"
done

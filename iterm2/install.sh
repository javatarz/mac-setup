#!/bin/bash
set -e

source "$(dirname "$0")/../common/defaults.sh"

# `default writes` are not used because the iterm2 data structure is painful to setup
# Hopefully this changes in the future. The approach below is currently iterm2's recommended setup procedure
echo
echo "> iterm2/install.sh"
# echo ">> Deleting iterm2 settings"
# delete_if_available com.googlecode.iterm2

echo ">> Replacing with checked in iterm2 settings"
sudo cp iterm2/com.googlecode.iterm2.plist /Library/Preferences/

echo ">> Setup iterm2 config backup settings"
for entry in "${ITERM2_DEFAULTS[@]}"; do
  apply_default_entry "$entry"
done
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "`pwd`/iterm2/"

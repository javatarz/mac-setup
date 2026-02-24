#!/bin/bash
set -e

source "$(dirname "$0")/../common/defaults.sh"

# Dock
echo ">> Setup dock parameters"
for entry in "${DOCK_DEFAULTS[@]}"; do
  apply_default_entry "$entry"
done
for entry in "${DOCK_DELETIONS[@]}"; do
  apply_deletion_entry "$entry"
done
echo ">> Restarting Dock"
killall Dock

# Siri
echo ">> Hiding Siri"

echo ">> Cleaning up menu bar items"
for entry in "${MENU_DELETIONS[@]}"; do
  apply_deletion_entry "$entry"
done

echo ">> Setting menu bar defaults"
for entry in "${MENU_DEFAULTS[@]}"; do
  apply_default_entry "$entry"
done

echo ">> Adding Time Machine to menu bar"
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"

echo ">> Restarting SystemUIServer"
killall -KILL SystemUIServer

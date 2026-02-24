#!/bin/sh
set -e

source "$(dirname "$0")/../common/functions.sh"

# Dock
echo ">> Setup dock parameters"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -float 32
defaults write com.apple.dock largesize -float 92
defaults write com.apple.dock orientation right
defaults write com.apple.dock mineffect genie
defaults write com.apple.dock minimize-to-application true
delete_if_available com.apple.dock persistent-apps
defaults write com.apple.dock show-recents -bool false
echo ">> Restarting Dock"
killall Dock

# Siri
echo ">> Hiding Siri"
defaults write com.apple.Siri StatusMenuVisible 0
defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" 0

echo ">> Cleaning up menu bar items"
delete_if_available com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.battery"
delete_if_available com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.clock"
delete_if_available com.apple.systemuiserver menuExtras
delete_if_available com.apple.systemuiserver "NSStatusItem Visible DoNotDisturb"

echo ">> Hiding Airplay from menu bar"
defaults write com.apple.airplay showInMenuBarIfPresent false

echo ">> Adding Time Machine to menu bar"
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" true
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"

echo ">> Setting menu bar clock to analog"
defaults write com.apple.menuextra.clock IsAnalog -bool true

echo ">> Restarting SystemUIServer"
killall -KILL SystemUIServer

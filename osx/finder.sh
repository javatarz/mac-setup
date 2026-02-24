#!/bin/sh
set -e

echo ">> Setting ~/$USER as the finder home"
defaults write com.apple.finder NewWindowTarget "PfHm"
defaults write com.apple.finder NewWindowTargetPath "file:///Users/$USER/"

echo ">> Restarting Finder"
killall Finder

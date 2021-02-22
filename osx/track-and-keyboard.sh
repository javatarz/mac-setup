#!/bin/sh

# Trackpad
echo ">> Setup trackpad speed parameters"
defaults write -g com.apple.trackpad.scaling 3

# Keyboard
echo ">> Setup keyboard speed parameters"
defaults write -g InitialKeyRepeat 15
defaults write -g KeyRepeat 2

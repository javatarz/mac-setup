#!/bin/sh

# Trackpad
echo ">> Setup trackpad speed parameters"
defaults write -g com.apple.trackpad.scaling 5.0

# Keyboard
echo ">> Setup keyboard speed parameters"
defaults write -g InitialKeyRepeat 68
defaults write -g KeyRepeat 2

#!/bin/sh

# Trackpad
echo ">> Setup trackpad speed parameters"
defaults write -g com.apple.trackpad.scaling 3

# Mouse
echo ">> Setup mouse speed parameters"
defaults write -g com.apple.mouse.scaling 3
defaults write -g com.apple.scrollwheel.scaling 1

# Keyboard
echo ">> Setup keyboard speed parameters"
defaults write -g InitialKeyRepeat 15
defaults write -g KeyRepeat 2

#!/bin/sh
set -e

echo ">> Setting screencapture type to JPG"
defaults write com.apple.screencapture type JPG

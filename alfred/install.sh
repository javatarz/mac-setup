#!/bin/sh

echo
echo "> alfred/install.sh"

echo ">> Writing Alfred config backup preferences"
defaults write com.runningwithcrayons.Alfred-Preferences syncfolder -string "`pwd`/alfred"

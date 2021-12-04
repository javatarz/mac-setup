#!/bin/sh

source common/functions.sh

# `default writes` are not used because the iterm2 data structure is painful to setup
# Hopefully this changes in the future. The approach below is currently iterm2's recommended setup procedure
echo
echo "> iterm2/install.sh"
# echo ">> Deleting iterm2 settings"
# delete_if_available com.googlecode.iterm2

echo ">> Replacing with checked in iterm2 settings"
sudo cp iterm2/com.googlecode.iterm2.plist /Library/Preferences/

echo ">> Setup iterm2 config backup settings"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -int 1
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "`pwd`/iterm2/"
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -int 1
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2

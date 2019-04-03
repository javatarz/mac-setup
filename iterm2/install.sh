# `default writes` are not used because the iterm2 data structure is painful to setup
# Hopefully this changes in the future. The approach below is currently iterm2's recommended setup procedure
echo
echo "> iterm2/install.sh"
echo ">> Deleting iterm2 settings"
defaults delete com.googlecode.iterm2

echo ">> Replacing with checked in iterm2 settings"
sudo cp iterm2/com.googlecode.iterm2.plist /Library/Preferences/
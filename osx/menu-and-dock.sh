# Dock
echo ">> Setup dock parameters"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -float 32
defaults write com.apple.dock largesize -float 92
defaults write com.apple.dock orientation right
defaults write com.apple.dock mineffect genie
defaults write com.apple.dock minimize-to-application 1
defaults write com.apple.dock persistent-apps " "
defaults write com.apple.dock show-recents -bool false
echo ">> Restarting Dock"
killall Dock

# Siri
echo ">> Hiding Siri"
defaults write com.apple.Siri StatusMenuVisible 0
defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" 0
echo ">> Restarting SystemUIServer"
killall -KILL SystemUIServer

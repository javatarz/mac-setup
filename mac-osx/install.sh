# UI
defaults write -g AppleInterfaceStyle Dark

# Trackpad
defaults write -g com.apple.trackpad.scaling 5.0

# Keyboard
defaults write -g InitialKeyRepeat 15
defaults write -g KeyRepeat 2

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -float 32
defaults write com.apple.dock largesize -float 92
defaults write com.apple.dock orientation right
defaults write com.apple.dock mineffect genie
defaults write com.apple.dock minimize-to-application 1
defaults write com.apple.dock persistent-apps " "
defaults write com.apple.dock show-recents -bool false

# Siri
defaults write com.apple.Siri StatusMenuVisible 0
defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" 0

# Global defaults writes require a logout
# osascript -e 'tell app "System Events" to log out'
killall Dock
killall -KILL SystemUIServer

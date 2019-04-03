# UI
defaults write -g AppleInterfaceStyle Dark

# Trackpad
defaults write -g com.apple.trackpad.scaling 5.0

# Keyboard
defaults write -g InitialKeyRepeat 15
defaults write -g KeyRepeat 2

# Dock
defaults write com.apple.dock autohide 1
defaults write com.apple.dock magnification 1
defaults write com.apple.dock titlesize 27
defaults write com.apple.dock largesize 91
defaults write com.apple.dock orientation right
defaults write com.apple.dock mineffect genie

# Global defaults writes require a logout
# osascript -e 'tell app "System Events" to log out'
killall Dock

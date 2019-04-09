defaults write com.apple.controlstrip FullCustomized -array \
  "com.apple.system.group.brightness" \
  "com.apple.system.mission-control" \
  "com.apple.system.launchpad" \
  "com.apple.system.group.keyboard-brightness" \
  "com.apple.system.group.media" \
  "com.apple.system.group.volume" \
  "com.apple.system.show-desktop" \
  "com.apple.system.screen-lock"

defaults write com.apple.controlstrip MiniCustomized -array \
  "com.apple.system.brightness" \
  "com.apple.system.volume" \
  "com.apple.system.mute" \
  "com.apple.system.screen-lock"

killall ControlStrip
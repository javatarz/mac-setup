result=$(defaults read -g AppleInterfaceStyle 2>/dev/null)

if [ "$result" != "Dark" ]; then
  echo
  echo "Enable Dark mode"
  osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
fi

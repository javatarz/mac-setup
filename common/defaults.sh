#!/bin/bash
# Shared configuration arrays and helpers for install and verify scripts.
# Each defaults entry is pipe-delimited: domain|key|type|value|label
# Type: -bool, -int, -float, -string, or "none" for untyped writes.
# Each deletion entry is pipe-delimited: domain|key|label
# Each git config entry is pipe-delimited: key|value

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

# --- Dock ---

DOCK_DEFAULTS=(
  "com.apple.dock|autohide|-bool|true|Dock autohide"
  "com.apple.dock|magnification|-bool|true|Dock magnification"
  "com.apple.dock|tilesize|-float|32|Dock tile size"
  "com.apple.dock|largesize|-float|92|Dock large size"
  "com.apple.dock|orientation|none|right|Dock orientation"
  "com.apple.dock|mineffect|none|genie|Dock minimize effect"
  "com.apple.dock|minimize-to-application|none|true|Dock minimize to application"
  "com.apple.dock|show-recents|-bool|false|Dock hide recent apps"
)

DOCK_DELETIONS=(
  "com.apple.dock|persistent-apps|Dock persistent apps"
)

# --- Menu bar ---

MENU_DEFAULTS=(
  "com.apple.Siri|StatusMenuVisible|none|0|Siri StatusMenuVisible"
  "com.apple.systemuiserver|NSStatusItem Visible Siri|none|0|Siri visible in menu"
  "com.apple.airplay|showInMenuBarIfPresent|none|false|Airplay in menu bar"
  "com.apple.systemuiserver|NSStatusItem Visible com.apple.menuextra.TimeMachine|none|true|Time Machine in menu bar"
  "com.apple.menuextra.clock|IsAnalog|-bool|true|Menu bar clock analog"
)

MENU_DELETIONS=(
  "com.apple.systemuiserver|NSStatusItem Visible com.apple.menuextra.battery|Battery in menu bar"
  "com.apple.systemuiserver|NSStatusItem Visible com.apple.menuextra.clock|Clock in menu bar"
  "com.apple.systemuiserver|menuExtras|Menu extras"
  "com.apple.systemuiserver|NSStatusItem Visible DoNotDisturb|Do Not Disturb in menu bar"
)

# --- Input devices ---

INPUT_DEFAULTS=(
  "NSGlobalDomain|com.apple.trackpad.scaling|-int|3|Trackpad speed"
  "NSGlobalDomain|com.apple.mouse.scaling|-int|3|Mouse speed"
  "NSGlobalDomain|com.apple.scrollwheel.scaling|-int|1|Scroll wheel speed"
  "NSGlobalDomain|InitialKeyRepeat|-int|15|Initial key repeat delay"
  "NSGlobalDomain|KeyRepeat|-int|2|Key repeat rate"
)

# --- Finder ---

FINDER_DEFAULTS=(
  "com.apple.finder|NewWindowTarget|none|PfHm|Finder new window target"
  "com.apple.finder|NewWindowTargetPath|none|file:///Users/$USER/|Finder new window path"
)

# --- Screen capture ---

SCREENCAPTURE_DEFAULTS=(
  "com.apple.screencapture|type|none|JPG|Screenshot format"
)

# --- Privacy ---

PRIVACY_DEFAULTS=(
  "com.apple.AdLib|AD_DEVICE_IDFA|none|00000000-0000-0000-0000-000000000000|IDFA zeroed"
  "com.apple.AdLib|forceLimitAdTracking|none|true|Limit ad tracking"
)

# --- iTerm2 ---
# NoSyncNeverRemind suppresses the "settings changed externally" dialog on quit.
# _selection=0 auto-selects "Copy" to save local changes back to the custom folder.
# See iTermRemotePreferences.m for dialog definition.

ITERM2_DEFAULTS=(
  "com.googlecode.iterm2|LoadPrefsFromCustomFolder|-int|1|iTerm2 loads prefs from custom folder"
  "com.googlecode.iterm2|NoSyncNeverRemindPrefsChangesLostForFile|-int|1|iTerm2 suppress prefs change reminder"
  "com.googlecode.iterm2|NoSyncNeverRemindPrefsChangesLostForFile_selection|-int|0|iTerm2 prefs change reminder selection"
)

# --- Git ---

GIT_CONFIGS=(
  "commit.gpgsign|true"
  "core.editor|vim"
  "init.defaultBranch|main"
  "diff.external|difft"
)

# --- Helper functions ---

# Convert write-time type+value to the value returned by `defaults read`.
normalize_for_read() {
  local type="$1" value="$2"
  case "$type" in
    -bool)
      case "$value" in
        true)  echo "1" ;;
        false) echo "0" ;;
        *)     echo "$value" ;;
      esac
      ;;
    *) echo "$value" ;;
  esac
}

# Parse a pipe-delimited defaults entry and run `defaults write`.
apply_default_entry() {
  local IFS='|'
  read -r domain key type value label <<< "$1"
  if [ "$type" = "none" ]; then
    defaults write "$domain" "$key" "$value"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

# Parse a pipe-delimited deletion entry and delete the key if it exists.
apply_deletion_entry() {
  local IFS='|'
  read -r domain key label <<< "$1"
  delete_if_available "$domain" "$key"
}

# Parse a pipe-delimited defaults entry, normalize, and verify.
# Requires report_success and report_failure to be defined by caller.
verify_default_entry() {
  local IFS='|'
  read -r domain key type value label <<< "$1"
  local expected actual
  expected=$(normalize_for_read "$type" "$value")
  actual=$(defaults read "$domain" "$key" 2>/dev/null)
  if [ "$actual" = "$expected" ]; then
    report_success "$label"
  else
    report_failure "$label (expected: $expected, got: $actual)"
  fi
}

# Parse a git config entry and apply it.
apply_git_config_entry() {
  local IFS='|'
  read -r key value <<< "$1"
  git config --global "$key" "$value"
}

# Parse a git config entry and verify it.
# Requires report_success and report_failure to be defined by caller.
verify_git_config_entry() {
  local IFS='|'
  read -r key value <<< "$1"
  local actual
  actual=$(git config --global --get "$key" 2>/dev/null)
  if [ "$actual" = "$value" ]; then
    report_success "git $key = $value"
  else
    report_failure "git $key (expected: $value, got: $actual)"
  fi
}

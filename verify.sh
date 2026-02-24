#!/bin/bash

source "$(dirname "$0")/common/functions.sh"

echo "--- Running Setup Verification ---"

STATUS=0 # Initialize status to success (0 = success, 1 = failure)
FAILURES=() # Array to store failure messages

# Function to report success
report_success() {
  echo "  ✅ $1"
}

# Function to report failure
report_failure() {
  echo "  ❌ $1"
  STATUS=1
  FAILURES+=("$1")
}

# Helper to verify macOS defaults
verify_default() {
  local domain="$1" key="$2" expected="$3" label="$4"
  local actual
  actual=$(defaults read "$domain" "$key" 2>/dev/null)
  if [ "$actual" = "$expected" ]; then
    report_success "$label"
  else
    report_failure "$label (expected: $expected, got: $actual)"
  fi
}

# Helper to verify git global config
verify_git_config() {
  local key="$1" expected="$2"
  local actual
  actual=$(git config --global --get "$key" 2>/dev/null)
  if [ "$actual" = "$expected" ]; then
    report_success "git $key = $expected"
  else
    report_failure "git $key (expected: $expected, got: $actual)"
  fi
}

# 1. Xcode Command Line Tools
echo -e "\n--- Checking Xcode Command Line Tools ---"
if command_exists xcode-select;
  then
    if xcode-select -p &> /dev/null;
      then
        report_success "Xcode Command Line Tools are installed."
      else
        report_failure "Xcode Command Line Tools are NOT installed. Run: xcode-select --install"
    fi
  else
    report_failure "xcode-select command not found. Xcode Command Line Tools are NOT installed."
fi

# 2. Homebrew Installation
echo -e "\n--- Checking Homebrew installation ---"
if command_exists brew; then
  report_success "Homebrew is installed."

  # 2.1. Verify Brew Packages
  echo -e "\n  Verifying Homebrew packages from Brewfile..."
  BREWFILE_PATH="brew/Brewfile"
  if [ -f "$BREWFILE_PATH" ];
    then
      # Get all installed brew formulas and casks once
      INSTALLED_FORMULAS=$(brew list --formula 2>/dev/null)
      INSTALLED_CASKS=$(brew list --cask 2>/dev/null)

      # Extract brew and cask entries, getting only the base name
      BREW_PACKAGES=$(grep "^brew " "$BREWFILE_PATH" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g' | awk -F'/' '{print $NF}')
      CASK_PACKAGES=$(grep "^cask " "$BREWFILE_PATH" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g' | awk -F'/' '{print $NF}')

      for pkg in $BREW_PACKAGES;
        do
          if echo "$INSTALLED_FORMULAS" | grep -q "^$pkg$";
            then
              report_success "Brew formula: $pkg is installed."
            else
              report_failure "Brew formula: $pkg is NOT installed."
          fi
      done

      for pkg in $CASK_PACKAGES;
        do
          if echo "$INSTALLED_CASKS" | grep -q "^$pkg$";
            then
              report_success "Brew cask: $pkg is installed."
            else
              report_failure "Brew cask: $pkg is NOT installed."
          fi
      done
    else
      report_failure "Brewfile not found at $BREWFILE_PATH. Cannot verify packages."
  fi
else
  report_failure "Homebrew is NOT installed. Cannot verify packages."
fi



# 3. Fish Shell Installation
echo -e "\n--- Checking Fish Shell installation ---"
if command_exists fish;
  then
    report_success "Fish Shell is installed."
    # Check if fish is the default shell
    if [ "$SHELL" = "/usr/local/bin/fish" ] || [ "$SHELL" = "/opt/homebrew/bin/fish" ]; then
      report_success "Fish is the default shell."
    else
      report_failure "Fish is NOT the default shell. Run: chsh -s $(which fish)"
    fi
  else
    report_failure "Fish Shell is NOT installed."
fi


# 4. Secrets Verification
echo -e "\n--- Checking for secrets ---"
FILES_TO_CHECK=("~/.ssh/config" "~/.ssh/emr_dev" "~/.config/fish/conf.d/secrets.fish")
for file_path in "${FILES_TO_CHECK[@]}"; do
  expanded_path=$(eval echo "$file_path")
  if [ -e "$expanded_path" ];
    then
      report_success "$file_path exists."
    else
      report_failure "$file_path does NOT exist."
  fi
done

DIRECTORIES_TO_CHECK=("~/.ssh/keys" "~/.ssh/envs")
for dir_path in "${DIRECTORIES_TO_CHECK[@]}"; do
  expanded_path=$(eval echo "$dir_path")
  if [ -d "$expanded_path" ];
    then
      report_success "$dir_path exists."
      if [ -z "$(ls -A $expanded_path)" ]; then
        report_failure "$dir_path is empty."
      else
        report_success "$dir_path is not empty."
      fi
    else
      report_failure "$dir_path does NOT exist."
  fi
done


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 5. Shell Config Symlinks
echo -e "\n--- Checking Shell Config Symlinks ---"
FISH_CONF_DIR="$HOME/.config/fish/conf.d"
SHELL_CONFIGS=("dir.fish" "setup_helper.fish" "autojump.fish" "fzf.fish" "git.fish" "docker.fish" "lazy.fish" "import.fish")
for config in "${SHELL_CONFIGS[@]}"; do
  link_path="$FISH_CONF_DIR/$config"
  expected_target="$SCRIPT_DIR/shell/$config"
  if [ -L "$link_path" ]; then
    actual_target=$(readlink "$link_path")
    if [ "$actual_target" = "$expected_target" ]; then
      report_success "$config symlinked correctly."
    else
      report_failure "$config symlink points to $actual_target (expected: $expected_target)"
    fi
  else
    report_failure "$config is not symlinked in $FISH_CONF_DIR"
  fi
done

# 6. Oh My Fish
echo -e "\n--- Checking Oh My Fish ---"
if [ -d "$HOME/.local/share/omf" ]; then
  report_success "Oh My Fish is installed."
else
  report_failure "Oh My Fish is NOT installed (~/.local/share/omf missing)."
fi

if [ -d "$HOME/.local/share/omf/themes/bobthefish" ]; then
  report_success "bobthefish theme is installed."
else
  report_failure "bobthefish theme is NOT installed."
fi

# 7. Git Global Config
echo -e "\n--- Checking Git Global Config ---"
verify_git_config "commit.gpgsign" "true"
verify_git_config "core.editor" "vim"
verify_git_config "init.defaultBranch" "main"
verify_git_config "diff.external" "difft"

# 8. macOS Defaults
echo -e "\n--- Checking macOS Defaults ---"
verify_default "com.apple.dock" "autohide" "1" "Dock autohide"
verify_default "com.apple.dock" "orientation" "right" "Dock orientation"
verify_default "NSGlobalDomain" "AppleInterfaceStyle" "Dark" "Dark mode"
verify_default "NSGlobalDomain" "KeyRepeat" "2" "Key repeat rate"
verify_default "com.apple.finder" "NewWindowTarget" "PfHm" "Finder new window target"
verify_default "com.apple.screencapture" "type" "JPG" "Screenshot format"
verify_default "com.apple.AdLib" "forceLimitAdTracking" "1" "Limit ad tracking"

# 9. Claude Code
echo -e "\n--- Checking Claude Code ---"
if command_exists claude; then
  report_success "claude command exists."
else
  report_failure "claude command NOT found."
fi

if [ -L "$HOME/.claude/statusline.fish" ]; then
  report_success "~/.claude/statusline.fish is a symlink."
else
  report_failure "~/.claude/statusline.fish is NOT a symlink."
fi

if [ -L "$HOME/.claude/commands" ]; then
  report_success "~/.claude/commands is a symlink."
else
  report_failure "~/.claude/commands is NOT a symlink."
fi

# 10. iTerm2
echo -e "\n--- Checking iTerm2 ---"
verify_default "com.googlecode.iterm2" "LoadPrefsFromCustomFolder" "1" "iTerm2 loads prefs from custom folder"

# 11. Alfred
echo -e "\n--- Checking Alfred ---"
ALFRED_SYNC=$(defaults read com.runningwithcrayons.Alfred-Preferences syncfolder 2>/dev/null)
if echo "$ALFRED_SYNC" | grep -q "alfred"; then
  report_success "Alfred sync folder is configured."
else
  report_failure "Alfred sync folder not configured (got: $ALFRED_SYNC)"
fi


echo -e "\n--- Verification Summary ---"
if [ $STATUS -eq 0 ];
  then
    echo "✅ All checks passed successfully!"
  else
    echo "❌ Some checks failed:"
    for failure in "${FAILURES[@]}"; do
      echo "  - $failure"
    done
fi

exit $STATUS

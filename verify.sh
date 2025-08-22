#!/bin/bash

echo "--- Running Setup Verification ---"

# Function to check if a command exists
command_exists () {
  type "$1" &> /dev/null ;
}

# 1. Xcode Command Line Tools
echo -e "\nChecking Xcode Command Line Tools..."
if command_exists xcode-select; then
  if xcode-select -p &> /dev/null; then
    echo "  ✅ Xcode Command Line Tools are installed."
  else
    echo "  ❌ Xcode Command Line Tools are NOT installed. Run: xcode-select --install"
  fi
else
  echo "  ❌ xcode-select command not found. Xcode Command Line Tools are NOT installed."
fi

# 2. Homebrew Installation
echo -e "\nChecking Homebrew installation..."
if command_exists brew; then
  echo "  ✅ Homebrew is installed."

  # 2.1. Verify Brew Packages
  echo -e "\n  Verifying Homebrew packages from Brewfile..."
  BREWFILE_PATH="brew/Brewfile"
  if [ -f "$BREWFILE_PATH" ]; then
    # Extract brew and cask entries
    BREW_PACKAGES=$(grep "^brew " "$BREWFILE_PATH" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
    CASK_PACKAGES=$(grep "^cask " "$BREWFILE_PATH" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')

    for pkg in $BREW_PACKAGES; do
      if brew list --formula "$pkg" &> /dev/null; then
        echo "    ✅ Brew formula: $pkg is installed."
      else
        echo "    ❌ Brew formula: $pkg is NOT installed."
      fi
    done

    for pkg in $CASK_PACKAGES; do
      if brew list --cask "$pkg" &> /dev/null; then
        echo "    ✅ Brew cask: $pkg is installed."
      else
        echo "    ❌ Brew cask: $pkg is NOT installed."
      fi
    done
  else
    echo "  ❌ Brewfile not found at $BREWFILE_PATH. Cannot verify packages."
  fi

else
  echo "  ❌ Homebrew is NOT installed. Cannot verify packages."
fi

# 3. Fish Shell Installation
echo -e "\nChecking Fish Shell installation..."
if command_exists fish; then
  echo "  ✅ Fish Shell is installed."
else
  echo "  ❌ Fish Shell is NOT installed."
fi

# 4. Presence of Securely Transferred Files
echo -e "\nChecking for securely transferred files..."
FILES_TO_CHECK=("~/.ssh" "~/.gnupg" "~/.config/fish/conf.d/secrets.fish")
for file_path in "${FILES_TO_CHECK[@]}"; do
  expanded_path=$(eval echo "$file_path")
  if [ -e "$expanded_path" ]; then
    echo "  ✅ $file_path exists."
  else
    echo "  ❌ $file_path does NOT exist."
  fi
done

echo -e "\n--- Verification Complete ---"

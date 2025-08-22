#!/bin/bash

echo "--- Running Setup Verification ---"

STATUS=0 # Initialize status to success

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
    STATUS=1
  fi
else
  echo "  ❌ xcode-select command not found. Xcode Command Line Tools are NOT installed."
  STATUS=1
fi

# 2. Homebrew Installation
echo -e "\nChecking Homebrew installation..."
if command_exists brew; then
  echo "  ✅ Homebrew is installed."

  # 2.1. Verify Brew Packages
  echo -e "\n  Verifying Homebrew packages from Brewfile..."
  BREWFILE_PATH="brew/Brewfile"
  if [ -f "$BREWFILE_PATH" ]; then
    # Get all installed brew formulas and casks once
    INSTALLED_FORMULAS=$(brew list --formula 2>/dev/null)
    INSTALLED_CASKS=$(brew list --cask 2>/dev/null)

    # Extract brew and cask entries, getting only the base name
    BREW_PACKAGES=$(grep "^brew " "$BREWFILE_PATH" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g' | awk -F'/' '{print $NF}')
    CASK_PACKAGES=$(grep "^cask " "$BREWFILE_PATH" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g' | awk -F'/' '{print $NF}')

    for pkg in $BREW_PACKAGES; do
      if echo "$INSTALLED_FORMULAS" | grep -q "^$pkg$"; then
        echo "    ✅ Brew formula: $pkg is installed."
      else
        echo "    ❌ Brew formula: $pkg is NOT installed."
        STATUS=1
      fi
    done

    for pkg in $CASK_PACKAGES; do
      if echo "$INSTALLED_CASKS" | grep -q "^$pkg$"; then
        echo "    ✅ Brew cask: $pkg is installed."
      else
        echo "    ❌ Brew cask: $pkg is NOT installed."
        STATUS=1
      fi
    done
  else
    echo "  ❌ Brewfile not found at $BREWFILE_PATH. Cannot verify packages."
    STATUS=1
  fi

else
  echo "  ❌ Homebrew is NOT installed. Cannot verify packages."
  STATUS=1
fi


# 3. Fish Shell Installation
echo -e "\nChecking Fish Shell installation..."
if command_exists fish; then
  echo "  ✅ Fish Shell is installed."
else
  echo "  ❌ Fish Shell is NOT installed."
  STATUS=1
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
    STATUS=1
  fi
done

echo -e "\n--- Verification Complete ---"

exit $STATUS

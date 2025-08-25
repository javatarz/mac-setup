#!/bin/bash

echo "--- Running Setup Verification ---"

STATUS=0 # Initialize status to success (0 = success, 1 = failure)
FAILURES=() # Array to store failure messages

# Function to check if a command exists
command_exists () {
  type "$1" &> /dev/null ;
}

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
  report_failure "Homebrew is NOT installed. Cannot verify packages."
else
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
fi



# 3. Fish Shell Installation
echo -e "\n--- Checking Fish Shell installation ---"
if command_exists fish;
  then
    report_success "Fish Shell is installed."
  else
    report_failure "Fish Shell is NOT installed."
fi

# 4. Presence of Securely Transferred Files
echo -e "\n--- Checking for securely transferred files ---"
FILES_TO_CHECK=("~/.ssh" "~/.gnupg" "~/.config/fish/conf.d/secrets.fish")
for file_path in "${FILES_TO_CHECK[@]}"; do
  expanded_path=$(eval echo "$file_path")
  if [ -e "$expanded_path" ];
    then
      report_success "$file_path exists."
    else
      report_failure "$file_path does NOT exist."
  fi
done

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


#!/bin/sh

# Source common functions
. "$(dirname "$0")"/../common/functions.sh

echo
echo "> brew/install.sh"

# Detect architecture and set Homebrew prefix
detect_homebrew_prefix

which brew >/dev/null
if test $? -ne 0; then
  echo ">> Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  # Add brew to .zprofile so future zsh login shells have brew in PATH (Homebrew recommended post-install step).
  # Single quotes ensure the eval command is written literally and executed at login time, not at install time.
  echo ">> Adding brew to zsh profile (Homebrew recommended post-install step)"
  (echo; echo 'eval "$('"${HOMEBREW_PREFIX}"'/bin/brew shellenv)"') >> ~/.zprofile
  eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
else
  echo ">> Brew already installed"
fi

echo ">> Switching off analytics"
brew analytics off

echo ">> Remove any apps not on the Brewfile"
brew bundle cleanup --file=brew/Brewfile --force

echo ">> Installing brew and cask apps"
brew bundle --file=brew/Brewfile

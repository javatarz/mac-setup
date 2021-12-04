#!/bin/sh

echo
echo "> brew/install.sh"
which brew >/dev/null
if test $? -ne 0; then
  echo ">> Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
  echo ">> Brew already installed"
fi

echo ">> Switching off analytics"
brew analytics off

echo ">> Remove any apps not on the Brewfile"
brew bundle cleanup --file=brew/Brewfile --force

echo ">> Installing brew and cask apps"
brew bundle --file=brew/Brewfile

echo ">> Setting up JDK paths"
sh brew/jdk.sh

#!/bin/sh
set -e # Exit immediately if a command exits with a non-zero status

sh xcode/install.sh
sh brew/install.sh

echo "> Checking brew is added to path"
eval "$(brew shellenv)" # Ensure brew is in PATH for subsequent scripts
if ! echo "$PATH" | grep -q "$(brew --prefix)/bin"; then
  echo ">> Adding Homebrew to PATH"
  export PATH="$(brew --prefix)/bin:$PATH"
fi

sh shell/install.sh
sh shell/1password.sh
sh scripts/transfer/transfer.sh
sh iterm2/install.sh
sh spectacle/install.sh
sh alfred/install.sh
sh osx/install.sh
sh verify.sh

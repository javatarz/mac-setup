#!/bin/sh

echo
echo "> xcode/install.sh"

# Check if Xcode Command Line Tools are already installed
if xcode-select -p &> /dev/null; then
  echo ">> Xcode Command Line Tools are already installed."
else
  echo ">> Installing Xcode Command Line Tools..."
  xcode-select --install
fi

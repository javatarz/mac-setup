#!/bin/bash
set -e

REPO_URL="https://github.com/javatarz/mac-setup.git"
TARGET_DIR="$HOME/projects/personal/mac-setup"

# --- Xcode Command Line Tools ---
echo ">> Checking Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
  echo ">> Xcode Command Line Tools already installed."
else
  echo ">> Installing Xcode Command Line Tools..."
  xcode-select --install

  echo ">> Waiting for Xcode Command Line Tools installation to complete..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  echo ">> Xcode Command Line Tools installed."
fi

# --- Clone or update repo ---
if [ -d "$TARGET_DIR/.git" ]; then
  echo ">> Repository already exists at $TARGET_DIR. Pulling latest..."
  git -C "$TARGET_DIR" pull
else
  echo ">> Cloning repository to $TARGET_DIR..."
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

# --- Run install ---
echo ">> Running install from $TARGET_DIR..."
cd "$TARGET_DIR"
./install.sh

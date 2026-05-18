#!/bin/sh
set -e

# Get absolute path to this script's directory
pos="$(cd "$(dirname "$0")" && pwd)"

echo
echo "> Setting up Claude Code"

echo ">> Installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

# Create ~/.claude directory if it doesn't exist
mkdir -p ~/.claude

# Symlink statusline script
echo ">> Linking statusline script"
ln -sf "$pos/statusline.fish" ~/.claude/statusline.fish

# Remove legacy commands symlink (commands migrated to skills)
echo ">> Removing legacy commands symlink"
rm -rf ~/.claude/commands

# Symlink skills directory
echo ">> Linking skills directory"
rm -rf ~/.claude/skills
ln -sf "$pos/skills" ~/.claude/skills

echo ">> Claude Code setup complete"
echo "   Note: settings.json is not symlinked (contains machine-specific plugin configs)"

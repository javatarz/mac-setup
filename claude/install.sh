#!/bin/sh

# Get absolute path to this script's directory
pos="$(cd "$(dirname "$0")" && pwd)"

echo
echo "> Setting up Claude Code"

# Create ~/.claude directory if it doesn't exist
mkdir -p ~/.claude

# Symlink statusline script
echo ">> Linking statusline script"
ln -sf "$pos/statusline.fish" ~/.claude/statusline.fish

# Symlink commands directory
# Remove existing commands dir/symlink first to ensure clean state
echo ">> Linking commands directory"
rm -rf ~/.claude/commands
ln -sf "$pos/commands" ~/.claude/commands

echo ">> Claude Code setup complete"
echo "   Note: settings.json is not symlinked (contains machine-specific plugin configs)"

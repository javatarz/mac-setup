#!/bin/sh

pos=$(dirname "$0")
source "$pos/../common/functions.sh"

echo
echo "> Setting up shell"

# Detect architecture and set Homebrew prefix
detect_homebrew_prefix

# Set fish shell path based on architecture
FISH_PATH="${HOMEBREW_PREFIX}/bin/fish"

if [ "$SHELL" != "${FISH_PATH}" ]; then
  echo ">> Changing default shell to fish."
  sudo sh -c "echo ${FISH_PATH} >> /etc/shells"
  chsh -s "${FISH_PATH}"
fi

# Add brew to fish paths (only if not already there)
if ! grep -q "set -U fish_user_paths ${HOMEBREW_PREFIX}/bin" ~/\.config/fish/config.fish 2>/dev/null; then
  echo ">> Add brew to fish paths"
  # This needs to be added to a fish config file, not directly executed in bash
  # We'll add a line to a fish config file that will be sourced later
  echo "set -U fish_user_paths ${HOMEBREW_PREFIX}/bin \$fish_user_paths" >> ~/\.config/fish/conf.d/brew_paths.fish
fi

echo ">> Remove existing symlinks to this repo's fish scripts"
mkdir -p ~/.config/fish/conf.d
find ~/.config/fish/conf.d -maxdepth 1 -lname '*mac-setup/shell*' -delete
echo ">> Replace with symlinks to in-project .fish scripts. Open a new shell for scripts to take effect."
for f in "$(pwd)"/shell/*.fish; do
  ln -sf "$f" ~/.config/fish/conf.d/
done

echo ">> Install OMF"
fish ./shell/omf/install.fish

echo ">> Install OMF dependencies"
fish ./shell/omf/dependencies.fish

# Add fzf bindings based on architecture
if [ -d "${HOMEBREW_PREFIX}/opt/fzf" ]; then
  echo ">> Add fzf bindings"
  "${HOMEBREW_PREFIX}/opt/fzf/install" --all
fi

sh ./shell/git/config.sh


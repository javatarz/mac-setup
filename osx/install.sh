#!/bin/sh
set -e

echo
echo "> osx/install.sh"
sh osx/ui.sh
bash osx/track-and-keyboard.sh
bash osx/menu-and-dock.sh
sh osx/touchbar.sh
bash osx/finder.sh
bash osx/screencapture.sh

echo "!! Please log out and log back in to apply OSX specific changes"

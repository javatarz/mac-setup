#!/bin/sh

rm -f ~/Library/Application\ Support/Spectacle/Shortcuts.json
ln -s $PWD/spectacle/Shortcuts.json ~/Library/Application\ Support/Spectacle/Shortcuts.json

killall Spectacle

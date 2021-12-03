#!/bin/sh

echo ">> Update git config"
git config --global commit.gpgsign true
git config --global core.editor vim
git config --global init.defaultBranch main

function brewfile
  rm -f ~/projects/personal/mac-setup/brew/Brewfile
  brew bundle dump --file=~/projects/personal/mac-setup/brew/Brewfile
end

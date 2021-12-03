#!/usr/local/bin/fish

functions | grep omf >/dev/null
if test $status -ne 0
  curl -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
  source $HOME/.config/fish/conf.d/omf.fish
else
  echo ">>> OMF is already installed, skipping step"
end

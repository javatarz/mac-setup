#!/bin/sh
echo
echo "> Setting up shell"

finger karun | grep -q "Shell: /usr/local/bin/fish"
if [ $? != 0 ]; then
  echo ">> Changing default shell to fish."
  chsh -s /usr/local/bin/fish
fi

echo ">> Remove symlink to current fish scripts"
mkdir -p ~/.config/fish/conf.d
ls -l ~/.config/fish/conf.d/ | grep mac-setup/shell | cut -d ' ' -f 13 | xargs printf -- "/Users/$USER/.config/fish/conf.d/%s\n" | xargs rm
echo ">> Replace with symlink to in-project .fish scripts file. Open a new shell for scripts to take effect."
ln -s `pwd`/shell/*.fish ~/.config/fish/conf.d

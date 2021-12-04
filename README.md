# Setting up your machine

1. Ensure your machine is running (at least) OSX Catalina
1. Run `bash <(curl -s https://raw.githubusercontent.com/javatarz/mac-setup/main/bootstrap.sh)`
1. Log out and back in to apply OSX changes (can be done at the end)
1. Login to the App Store in the background (before mac apps get installed)
1. Restore the list of Manual Items (below)
1. Run `mkdir -p ~/projects/personal && cd ~/projects/personal && git clone git@github.com:javatarz/mac-setup.git && cd mac-setup && ./install.sh` to move shell configurations to a more permanent path. Restart shell to apply changes
1. Log out and back in to apply OSX changes (can be ignored if it hasn't been already done)

# Updating the codebase over time

## Brew packages
```bash
rm -f brew/Brewfile && brew bundle dump --file=brew/Brewfile
```

Once you have fish setup, the function `brewfile` will do the above command for you.

## OSX settings (or any other plist)
Setup the aliases
```bash
alias bef="rm -f before after && defaults read > before"
alias aft="defaults read > after && code --diff before after"
```

In a directory with write privileges, run `bef`, make the changes you wish to record and then run `aft`. The console will output the differences.

## Iterm2
Settings are automatically saved to `/Users/karun/projects/personal/mac-setup/iterm2` if the directory exists.

Make changes via the iterm2 UI and commit the file.

# Manual items

1. ~/.ssh
1. ~/.gnupg
1. ~/.config/fish/conf.d/secrets.fish

# Pending items

* OSX
    * Spotlight shortcut (currently done by Bartender)
* Secrets management
* Automate alfred config setup
* iStat Menus - Menu configurations
* Automate mac-setup checkout process

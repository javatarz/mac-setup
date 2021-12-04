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

## iTerm2
Open `Preferences > General > Preferences` and set the config path to `<base-path>/mac-setup/iterm2`

Make changes via the iterm2 UI and commit the file.

## Alfred
Open `Preferences > Advanced > Set Preferences Folder` and set the config path to `<base-path>/mac-setup/alfred`

Make changes via the Alfred UI and commit the file.

## iStat Menus
Update the menu structure as required

# Manual items

1. ~/.ssh
1. ~/.gnupg
1. ~/.config/fish/conf.d/secrets.fish

# Pending items

* OSX
    * Spotlight shortcut (currently done by Bartender)
* Secrets management
* Automate telling Alfred to save config to mac-setup directory
* iStat Menus - Menu configurations
* Automate mac-setup checkout process

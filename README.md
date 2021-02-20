# Setting up your machine

1. Ensure your machine is running (at least) OSX Mojave
1. Run `bash <(curl -s https://raw.githubusercontent.com/javatarz/mac-setup/main/bootstrap.sh)`

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

# Pending items

* OSX
    * Spotlight shortcut
* Bootstrap script - Single line execution on a clean machine
* Automate alfred config setup
* Automate iTerm2 config setup
* iStat Menus - Menu configurations

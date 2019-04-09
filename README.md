# Setting up your machine

1. Download the codebase and execute `install.sh`
2. Open Iterm2 and ask it to read settings from `/Users/karun/projects/personal/mac-setup/iterm2`
3. Open Alfred > Preferences > Advanced > Syncing > Set Preferences folder and set it to the `alfred` directory in this project
4. Load the `git` module in ~/.zprestorc

# Updating the codebase over time

## Brew packages
```bash
rm -f brew/Brewfile && brew bundle dump --file=brew/Brewfile
```

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

# Pending items

* OSX
    * Spotlight shortcut
* Bootstrap script - Single line execution on a clean machine
* Git
    * Default configuration
    * Signed commits
* Automate alfred config setup
* Automate iTerm2 config setup
* Automate .zpreztorc update
* iStat Menus - Menu configurations

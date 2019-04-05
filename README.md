# Setting up your machine

1. Download the codebase and execute `install.sh`
2. Open Alfred > Preferences > Advanced > Syncing > Set Preferences folder and set it to the `alfred` directory in this project
3. Load the `git` module in ~/.zprestorc

# Updating the codebase over time

## Brew packages
```bash
cd brew
brew bundle dump
```

## OSX settings (or any other plist)
Setup the aliases
```bash
alias bef="rm -f before after && defaults read > before"
alias aft="defaults read > after && diff before after"
```

In a directory with write privileges, run `bef`, make the changes you wish to record and then run `aft`. The console will output the differences.
Running `code --diff before after` will showcase the full diff of the files in Visual Studio code

## Iterm2
Settings are automatically saved to `/Users/karun/projects/personal/mac-setup/iterm2` if the directory exists.

Make changes via the iterm2 UI and commit the file.

# Pending items

* OSX
    * Spotlight shortcut
* iStat Menus - Menu configurations
* Bootstrap script - Single line execution on a clean machine
* Git
    * Default configuration
    * Signed commits
* Automate alfred config setup

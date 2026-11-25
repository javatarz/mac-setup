# Upgrade everything in brew

Homebrew is a the missing package manager for Mac OS. Brew cask extends Homebrew and brings its elegance, simplicity, and speed to Mac OS applications and large binaries alike.

If you’re using these tools and would like to upgrade all of the applications you have, run the following command.

### Breaking it down

- Update brew with information from the latest taps: `brew update`

- Upgrade apps in brew: `brew upgrade`

- Update brew cask apps: `brew cask outdated | cut -f 1 -d " " | xargs brew cask reinstall`

- Find outdated cask apps: `brew cask outdated`

- Cut out the app names: `cut -f 1 -d " "`

- Upgrade brew cask apps: `xargs brew cask reinstall`

- Remove installers for brew apps (to release disk space): `brew cleanup`

Note: `brew cask cleanup` is now deprecated.

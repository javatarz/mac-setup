#!/bin/sh

# Source common functions
. "$(dirname "$0")"/../common/functions.sh

echo
echo "> brew/install.sh"

# Detect architecture and set Homebrew prefix
detect_homebrew_prefix

which brew >/dev/null
if test $? -ne 0; then
  echo ">> Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  # Add brew to .zprofile so future zsh login shells have brew in PATH (Homebrew recommended post-install step).
  # Single quotes ensure the eval command is written literally and executed at login time, not at install time.
  echo ">> Adding brew to zsh profile (Homebrew recommended post-install step)"
  (echo; echo 'eval "$('"${HOMEBREW_PREFIX}"'/bin/brew shellenv)"') >> ~/.zprofile
  eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
else
  echo ">> Brew already installed"
fi

echo ">> Switching off analytics"
brew analytics off

# Casks are optional: run with SKIP_CASKS=1 to install only formulae, taps and App Store apps.
# Installed casks are left untouched in that mode.
# npm packages are installed separately below, once mise has provided node.
BREWFILE_DIR=$(mktemp -d)
BREWFILE="$BREWFILE_DIR/Brewfile"
NPM_BREWFILE="$BREWFILE_DIR/Brewfile.npm"
grep '^npm ' brew/Brewfile > "$NPM_BREWFILE"
if test "${SKIP_CASKS:-0}" = "1"; then
  echo ">> SKIP_CASKS=1: skipping cask installs"
  grep -v '^cask \|^npm ' brew/Brewfile > "$BREWFILE"
  CLEANUP_SCOPE="--formula"
else
  grep -v '^npm ' brew/Brewfile > "$BREWFILE"
  CLEANUP_SCOPE=""
fi

echo ">> Remove any apps not on the Brewfile"
# shellcheck disable=SC2086
brew bundle cleanup --file=brew/Brewfile $CLEANUP_SCOPE --force

# brew bundle installs one package at a time (downloading serially), so pre-fetch
# everything that is missing in parallel first. Installs then hit the cache.
echo ">> Pre-downloading missing formulae and casks in parallel"
tmp=$(mktemp -d)
brew bundle list --file=brew/Brewfile --formula | sort > "$tmp/want_formulae"
brew bundle list --file=brew/Brewfile --cask | sort > "$tmp/want_casks"
brew list --formula -1 | sort > "$tmp/have_formulae"
brew list --cask -1 | sort > "$tmp/have_casks"
missing_formulae=$(comm -23 "$tmp/want_formulae" "$tmp/have_formulae")
missing_casks=$(comm -23 "$tmp/want_casks" "$tmp/have_casks")
rm -rf "$tmp"
if test -n "$missing_formulae"; then
  # shellcheck disable=SC2086
  brew fetch --formula $missing_formulae || echo ">> Some formula downloads failed; brew bundle will retry"
fi
if test "${SKIP_CASKS:-0}" != "1" && test -n "$missing_casks"; then
  # shellcheck disable=SC2086
  brew fetch --cask $missing_casks || echo ">> Some cask downloads failed; brew bundle will retry"
fi

echo ">> Installing brew and cask apps"
brew bundle --verbose --file="$BREWFILE"

# A new machine has no node until mise installs it, so npm entries can't go through the main bundle.
if test -s "$NPM_BREWFILE"; then
  echo ">> Installing npm packages with node from mise"
  mise use --global node@lts
  mise exec node@lts -- brew bundle --verbose --file="$NPM_BREWFILE"
fi
rm -rf "$BREWFILE_DIR"

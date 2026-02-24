#!/bin/bash
set -e

source "$(dirname "$0")/../../common/defaults.sh"

echo
echo "> Setting up git signing identities"

DEFAULT_NAME=""
DEFAULT_GITDIR=""
DEFAULT_SECTION=""

for entry in "${GIT_IDENTITIES[@]}"; do
  IFS='|' read -r name gitdir section <<< "$entry"

  # First entry becomes the default
  if [ -z "$DEFAULT_NAME" ]; then
    DEFAULT_NAME="$name"
    DEFAULT_GITDIR="$gitdir"
    DEFAULT_SECTION="$section"
  fi

  echo ">> Fetching $name identity from 1Password..."
  email=$(op read "op://Personal/$GIT_SIGNING_ITEM/$section/email")
  signing_key=$(op read "op://Personal/$GIT_SIGNING_ITEM/$section/signing-key")

  config_file="$HOME/.gitconfig-$name"
  echo ">> Writing $config_file"
  cat > "$config_file" <<EOF
[user]
    email = $email
    signingkey = $signing_key
EOF

  echo ">> Adding includeIf for $gitdir"
  git config --global "includeIf.gitdir:$gitdir.path" "$config_file"
done

# Set default identity (first entry) globally
echo ">> Setting default identity ($DEFAULT_NAME) globally"
default_email=$(op read "op://Personal/$GIT_SIGNING_ITEM/$DEFAULT_SECTION/email")
default_key=$(op read "op://Personal/$GIT_SIGNING_ITEM/$DEFAULT_SECTION/signing-key")
git config --global user.email "$default_email"
git config --global user.signingkey "$default_key"

echo ">> Git signing identities configured."

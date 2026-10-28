#!/bin/sh

echo
echo "> Setting up 1Password CLI and fetching secrets"

# Check if 1Password CLI is installed
if ! command -v op > /dev/null; then
  echo ">> 1Password CLI not found. Please install it first."
  exit 1
fi

. "$(dirname "$0")/../common/functions.sh"
ensure_op_signin || exit 1

# --- Git Configuration ---
echo ">> Fetching git config from 1Password..."

GIT_DIR="$HOME/.gitconfig.d"
mkdir -p "$GIT_DIR"

if op read "op://Personal/dotfiles/gitconfig" > "$HOME/.gitconfig.tmp" 2> /dev/null; then
  mv "$HOME/.gitconfig.tmp" "$HOME/.gitconfig"
else
  rm -f "$HOME/.gitconfig.tmp"
  echo ">> No gitconfig in 1Password yet, keeping local ~/.gitconfig"
fi

# NOTE: Items are Documents tagged "git_config"; titles are the filenames.
for item in $(op item list --vault "Personal" --categories "Document" --tags "git_config" --format=json | jq -r '.[].title'); do
  op document get "$item" --vault "Personal" --out-file "$GIT_DIR/$item" --force
done

# --- SSH Configuration ---
echo ">> Fetching SSH configuration from 1Password..."

SSH_DIR="$HOME/.ssh"
KEYS_DIR="$SSH_DIR/keys"
ENVS_DIR="$SSH_DIR/envs"

mkdir -p "$KEYS_DIR"
mkdir -p "$ENVS_DIR"

# Fetch the main config file
op read "op://Personal/dotfiles/ssh_config" > "$SSH_DIR/config"

# Fetch the envs/*.config files
# NOTE: Items are Documents tagged "ssh_env"; titles are the filenames.
for item in $(op item list --vault "Personal" --categories "Document" --tags "ssh_env" --format=json | jq -r '.[].title'); do
  op document get "$item" --vault "Personal" --out-file "$ENVS_DIR/$item" --force
done

# Fetch the private keys
# NOTE: Items are Documents tagged "ssh_key"; titles are the filenames.
for item in $(op item list --vault "Personal" --categories "Document" --tags "ssh_key" --format=json | jq -r '.[].title'); do
  op document get "$item" --vault "Personal" --out-file "$KEYS_DIR/$item" --force
  chmod 600 "$KEYS_DIR/$item"
done

# --- Fish Secrets ---
echo ">> Fetching Fish secrets from 1Password..."

SECRETS_DIR="$HOME/.config/fish/conf.d"
mkdir -p "$SECRETS_DIR"

op read "op://Personal/dotfiles/secrets.fish" > "$SECRETS_DIR/secrets.fish"

# --- GPG Keys ---
echo ">> Importing GPG keys from 1Password..."
if command -v gpg > /dev/null; then
  # Imported keys keep their original passphrase protection
  for item in $(op item list --vault "Personal" --categories "Document" --tags "gpg_key" --format=json | jq -r '.[].title'); do
    op document get "$item" --vault "Personal" | gpg --batch --import
  done
  if op item get gpg-ownertrust --vault "Personal" > /dev/null 2>&1; then
    op document get gpg-ownertrust --vault "Personal" | gpg --import-ownertrust
  fi
else
  echo ">> gpg not installed, skipping GPG import"
fi

#!/bin/sh

echo
echo "> Setting up 1Password CLI and fetching secrets"

# Check if 1Password CLI is installed
if ! command -v op > /dev/null; then
  echo ">> 1Password CLI not found. Please install it first."
  exit 1
fi

# Check if the user is already signed in
op account get > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo ">> Already signed in to 1Password."
else
  echo ">> Not signed in to 1Password. Please sign in."
  read -p "Enter your 1Password email address: " email
  read -p "Enter your 1Password secret key: " secret_key
  read -s -p "Enter your 1Password master password: " master_password
  echo

  # Sign in to 1Password
  op signin --account my --email "$email" --secret-key "$secret_key" <<< "$master_password"
fi

# --- SSH Configuration ---
echo ">> Fetching SSH configuration from 1Password..."

SSH_DIR="$HOME/.ssh"
KEYS_DIR="$SSH_DIR/keys"
ENVS_DIR="$SSH_DIR/envs"

mkdir -p "$KEYS_DIR"
mkdir -p "$ENVS_DIR"

# Fetch the main config file
op read "op://Personal/dotfiles/ssh_config" > "$SSH_DIR/config"

# Fetch the emr_dev file
op read "op://Personal/dotfiles/emr_dev" > "$SSH_DIR/emr_dev"

# Fetch the envs/*.config files
# NOTE: This assumes that the names of the items in 1Password are the same as the filenames.
for item in $(op item list --vault "Personal" --categories "Document" --tags "ssh_env" --format=json | jq -r '.[].title'); do
  op read "op://Personal/$item/document" > "$ENVS_DIR/$item"
done

# Fetch the private keys
# NOTE: This assumes that the names of the items in 1Password are the same as the filenames.
for item in $(op item list --vault "Personal" --categories "SSH Key" --tags "ssh_key" --format=json | jq -r '.[].title'); do
  op read "op://Personal/$item/private key" > "$KEYS_DIR/$item"
  chmod 600 "$KEYS_DIR/$item"
done

# --- Fish Secrets ---
echo ">> Fetching Fish secrets from 1Password..."

SECRETS_DIR="$HOME/.config/fish/conf.d"
mkdir -p "$SECRETS_DIR"

op read "op://Personal/dotfiles/secrets.fish" > "$SECRETS_DIR/secrets.fish"

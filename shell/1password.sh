#!/bin/sh

echo
echo "> Setting up 1Password CLI"

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

# Fetch secrets (to be implemented)

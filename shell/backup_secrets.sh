#!/bin/bash
# Backs up git config, SSH config, SSH env configs, SSH private keys, fish secrets and GPG
# secret keys into the 1Password "Personal" vault. Counterpart of fetch_secrets.sh.
# Idempotent: only uploads what is new or changed. Prints names only, never contents.
set -u

VAULT="Personal"
SSH_DIR="$HOME/.ssh"
FISH_SECRETS="$HOME/.config/fish/conf.d/secrets.fish"
GIT_DIR="$HOME/.gitconfig.d"

echo
echo "> Backing up SSH and GPG setup to 1Password"

if ! command -v op > /dev/null; then
  echo ">> 1Password CLI not found, skipping backup"
  exit 1
fi
if ! op whoami > /dev/null 2>&1; then
  echo ">> Not signed in to 1Password, skipping backup"
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Add or update a Document so its contents match a local file.
# usage: sync_document <file> <title> <tag>
sync_document() {
  local file="$1" title="$2" tag="$3"
  echo ">> checking $title"
  if ! op item get "$title" --vault "$VAULT" > /dev/null 2>&1; then
    op document create "$file" --vault "$VAULT" --title "$title" --tags "$tag" > /dev/null \
      && echo ">> added   $title" || echo ">> FAILED  $title"
    return
  fi
  if op document get "$title" --vault "$VAULT" --out-file "$tmp/current" --force > /dev/null 2>&1 \
    && cmp -s "$tmp/current" "$file"; then
    echo "   unchanged $title"
    return
  fi
  op document edit "$title" "$file" --vault "$VAULT" > /dev/null \
    && echo ">> updated $title" || echo ">> FAILED  $title"
}

# Update a field on the "dotfiles" note if it differs from a local file.
# usage: sync_field <field> <file>
sync_field() {
  local field="$1" file="$2"
  echo ">> checking dotfiles/$field"
  if [ "$(op read "op://$VAULT/dotfiles/$field" 2> /dev/null)" = "$(cat "$file")" ]; then
    echo "   unchanged dotfiles/$field"
    return
  fi
  # Dots in field names must be escaped in assignment statements
  op item edit dotfiles --vault "$VAULT" "${field//./\\.}[concealed]=$(cat "$file")" > /dev/null \
    && echo ">> updated dotfiles/$field" || echo ">> FAILED  dotfiles/$field"
}

echo ">> SSH config and fish secrets"
[ -f "$SSH_DIR/config" ] && sync_field ssh_config "$SSH_DIR/config"
[ -f "$FISH_SECRETS" ] && sync_field secrets.fish "$FISH_SECRETS"

echo ">> Git config"
[ -f "$HOME/.gitconfig" ] && sync_field gitconfig "$HOME/.gitconfig"
for f in "$GIT_DIR"/*; do
  [ -f "$f" ] && sync_document "$f" "$(basename "$f")" git_config
done

echo ">> SSH env configs"
for f in "$SSH_DIR"/envs/*.config; do
  [ -f "$f" ] && sync_document "$f" "$(basename "$f")" ssh_env
done

echo ">> SSH private keys"
for f in "$SSH_DIR"/keys/*; do
  [ -f "$f" ] || continue
  case "$f" in *.pub | */.DS_Store) continue ;; esac
  grep -q "PRIVATE KEY" "$f" 2> /dev/null && sync_document "$f" "$(basename "$f")" ssh_key
done

echo ">> GPG secret keys"
if command -v gpg > /dev/null; then
  # Keys are exported only when missing from 1Password, since exporting prompts for the passphrase.
  gpg --list-secret-keys --with-colons | awk -F: '/^sec/ {want=1; next} want && /^fpr/ {print $10; want=0}' | while read -r fpr; do
    title="gpg-$fpr"
    if op item get "$title" --vault "$VAULT" > /dev/null 2>&1; then
      echo "   unchanged $title"
      continue
    fi
    echo ">> exporting $title"
    if gpg --batch --export-secret-keys --armor "$fpr" > "$tmp/$title.asc" 2> /dev/null && [ -s "$tmp/$title.asc" ]; then
      op document create "$tmp/$title.asc" --vault "$VAULT" --title "$title" --tags gpg_key > /dev/null \
        && echo ">> added   $title" || echo ">> FAILED  $title"
    else
      echo ">> FAILED  $title (could not export, unlock the key and retry)"
    fi
  done
  gpg --export-ownertrust > "$tmp/gpg-ownertrust"
  sync_document "$tmp/gpg-ownertrust" gpg-ownertrust gpg_ownertrust
else
  echo ">> gpg not found, skipping"
fi

echo ">> Backup complete."

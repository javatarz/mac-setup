delete_if_available() {
  defaults read $1 $2 > /dev/null 2>&1

  if [ $? = 0 ]; then
    defaults delete $1 $2
  fi
}

detect_homebrew_prefix() {
  # Detect architecture and set Homebrew prefix
  if [ "$(uname -m)" = "arm64" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
  export HOMEBREW_PREFIX # Export the variable so it's available in sourced scripts
}

command_exists () {
  command -v "$1" >/dev/null 2>&1
}

# Ensure the 1Password CLI has a session in the current shell. `op account get`
# succeeds as soon as an account is added, even when signed out, so use `op whoami`.
# The session token is exported, so only child processes of the calling shell inherit
# it: call this from the top-level script, not from one that exits before the next step.
ensure_op_signin() {
  if op whoami > /dev/null 2>&1; then
    return 0
  fi
  echo ">> Not signed in to 1Password. Please sign in."
  # Add the account if none is configured (prompts for address, email, secret key)
  if ! op account list 2> /dev/null | grep -q .; then
    op account add || return 1
  fi
  # Prompts for the master password (or uses desktop app integration)
  eval "$(op signin)" || return 1
  op whoami > /dev/null 2>&1 || { echo ">> 1Password sign-in failed."; return 1; }
}

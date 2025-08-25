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
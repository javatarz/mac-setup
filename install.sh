#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# --- Module system ---
# Module names: xcode, brew, shell, secrets, signing, iterm2, alfred, claude, osx, verify
SKIP_MODULES=""
ONLY_MODULES=""

usage() {
  echo "Usage: $0 [--skip module1,module2] [--only module1,module2]"
  echo ""
  echo "Modules: xcode, brew, shell, secrets, signing, iterm2, alfred, claude, osx, verify"
  echo ""
  echo "  --skip   Skip the listed modules (run everything else)"
  echo "  --only   Run only the listed modules (skip everything else)"
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --skip)
      [ -n "$ONLY_MODULES" ] && echo "Error: --skip and --only are mutually exclusive" && exit 1
      SKIP_MODULES="$2"
      shift 2
      ;;
    --only)
      [ -n "$SKIP_MODULES" ] && echo "Error: --skip and --only are mutually exclusive" && exit 1
      ONLY_MODULES="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

should_run() {
  local module="$1"
  if [ -n "$ONLY_MODULES" ]; then
    echo ",$ONLY_MODULES," | grep -q ",$module," && return 0 || return 1
  fi
  if [ -n "$SKIP_MODULES" ]; then
    echo ",$SKIP_MODULES," | grep -q ",$module," && return 1 || return 0
  fi
  return 0
}

# --- Run modules ---

if should_run "xcode"; then
  sh xcode/install.sh
fi

if should_run "brew"; then
  sh brew/install.sh
fi

echo "> Checking brew is added to path"
eval "$(brew shellenv)" # Ensure brew is in PATH for subsequent scripts
if ! echo "$PATH" | grep -q "$(brew --prefix)/bin"; then
  echo ">> Adding Homebrew to PATH"
  export PATH="$(brew --prefix)/bin:$PATH"
fi

if should_run "shell"; then
  sh shell/install.sh
fi

if should_run "secrets"; then
  sh shell/fetch_secrets.sh
fi

if should_run "signing"; then
  bash shell/git/signing.sh
fi

if should_run "iterm2"; then
  bash iterm2/install.sh
fi

if should_run "alfred"; then
  sh alfred/install.sh
fi

if should_run "claude"; then
  sh claude/install.sh
fi

if should_run "osx"; then
  sh osx/install.sh
fi

if should_run "verify"; then
  sh verify.sh
fi

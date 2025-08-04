#!/bin/bash

# Wrapper script for text-view command
# This script calls the Go binary with proper path resolution

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the Go binary
BINARY="$SCRIPT_DIR/xkcd-alfred"

# Check if binary exists
if [ ! -f "$BINARY" ]; then
    echo "Error: xkcd-alfred binary not found at $BINARY" >&2
    echo "Please run build.sh first" >&2
    exit 1
fi

# Make sure binary is executable
chmod +x "$BINARY"

# Call the binary with text-view command and pass all arguments
exec "$BINARY" text-view "$@"

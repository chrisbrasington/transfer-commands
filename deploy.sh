#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local/bin"
SSH_CONFIG="$HOME/.ssh/config"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PULL_SRC="$SCRIPT_DIR/pull.sh"
PUSH_SRC="$SCRIPT_DIR/push.sh"

PULL_DEST="$INSTALL_DIR/pull"
PUSH_DEST="$INSTALL_DIR/push"

SSH_BLOCK='
Host storage
    HostName 192.168.0.11
    User chris
    Port 22
'

echo "Installing CLI tools to: $INSTALL_DIR"
echo

# Validate sources
[[ -f "$PULL_SRC" ]] || { echo "Missing $PULL_SRC"; exit 1; }
[[ -f "$PUSH_SRC" ]] || { echo "Missing $PUSH_SRC"; exit 1; }

# Ask for sudo once if needed
if [[ $EUID -ne 0 ]]; then
    echo "Requesting sudo for system install..."
    sudo -v
fi

echo "Installing binaries..."

sudo cp "$PULL_SRC" "$PULL_DEST"
sudo cp "$PUSH_SRC" "$PUSH_DEST"

sudo chmod +x "$PULL_DEST" "$PUSH_DEST"

echo "Done installing binaries."
echo

# ---- SSH CONFIG SECTION ----

echo "Configuring SSH..."

mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG"

if grep -q "Host storage" "$SSH_CONFIG"; then
    echo "SSH config already contains 'storage' host — skipping."
else
    echo "Adding SSH host 'storage' to $SSH_CONFIG"
    echo "$SSH_BLOCK" >> "$SSH_CONFIG"
fi

chmod 600 "$SSH_CONFIG"

echo
echo "Installed:"
echo " - pull -> $PULL_DEST"
echo " - push -> $PUSH_DEST"
echo " - ssh host -> storage (192.168.0.11)"
echo
echo "Done."

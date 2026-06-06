#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="${TRANSFER_COMMANDS_CONFIG:-$HOME/.config/transfer-commands}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PULL_SRC="$SCRIPT_DIR/pull.sh"
PUSH_SRC="$SCRIPT_DIR/push.sh"
ENV_SRC="$SCRIPT_DIR/.env"

PULL_DEST="$INSTALL_DIR/pull"
PUSH_DEST="$INSTALL_DIR/push"
ENV_DEST="$CONFIG_DIR/.env"

echo "Installing CLI tools to: $INSTALL_DIR"
echo

# Validate sources
[[ -f "$PULL_SRC" ]] || { echo "Missing $PULL_SRC"; exit 1; }
[[ -f "$PUSH_SRC" ]] || { echo "Missing $PUSH_SRC"; exit 1; }
if [[ ! -f "$ENV_SRC" ]]; then
    echo "Missing $ENV_SRC — run ./migrate.sh or copy .env.example to .env first."
    exit 1
fi

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

# ---- CONFIG SECTION ----

echo "Installing config to $ENV_DEST"
mkdir -p "$CONFIG_DIR"
cp "$ENV_SRC" "$ENV_DEST"
chmod 600 "$ENV_DEST"

echo
echo "Installed:"
echo " - pull -> $PULL_DEST"
echo " - push -> $PUSH_DEST"
echo " - config -> $ENV_DEST"
echo
echo "Done."

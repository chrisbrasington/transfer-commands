#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local/bin"

# Don't run the whole script as root. It calls sudo itself for the binary
# install; running it with sudo makes $HOME resolve to root's home, so the
# config lands in /root/.config instead of your own and `push`/`pull` can't
# find it.
if [[ $EUID -eq 0 ]]; then
    echo "Don't run deploy.sh as root or with sudo." >&2
    echo "Run it as your normal user: ./deploy.sh" >&2
    echo "It will ask for sudo only when installing to $INSTALL_DIR." >&2
    exit 1
fi
CONFIG_DIR="${TRANSFER_COMMANDS_CONFIG:-$HOME/.config/transfer-commands}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PULL_SRC="$SCRIPT_DIR/pull.sh"
PUSH_SRC="$SCRIPT_DIR/push.sh"
COMMIT_SRC="$SCRIPT_DIR/commit.sh"
ENV_SRC="$SCRIPT_DIR/.env"

PULL_DEST="$INSTALL_DIR/pull"
PUSH_DEST="$INSTALL_DIR/push"
COMMIT_DEST="$INSTALL_DIR/commit"
ENV_DEST="$CONFIG_DIR/.env"

echo "Installing CLI tools to: $INSTALL_DIR"
echo

# Validate sources
[[ -f "$PULL_SRC" ]] || { echo "Missing $PULL_SRC"; exit 1; }
[[ -f "$PUSH_SRC" ]] || { echo "Missing $PUSH_SRC"; exit 1; }
[[ -f "$COMMIT_SRC" ]] || { echo "Missing $COMMIT_SRC"; exit 1; }
if [[ ! -f "$ENV_SRC" ]]; then
    echo "Missing $ENV_SRC — run ./migrate.sh or copy .env.example to .env first."
    exit 1
fi

# Detect a conflicting `commit` already on PATH.
# If one exists somewhere other than our target, abort so the user can remove
# it manually — we won't silently shadow or overwrite an unknown command.
if command -v commit &> /dev/null; then
    EXISTING_COMMIT="$(command -v commit)"
    if [[ "$EXISTING_COMMIT" != "$COMMIT_DEST" ]]; then
        echo "WARNING: a 'commit' command already exists on your PATH:"
        echo "  existing: $EXISTING_COMMIT"
        echo "  target:   $COMMIT_DEST"
        echo
        echo "Installing would create a second 'commit' and which one runs"
        echo "depends on PATH order. Aborting so you can fix this manually:"
        echo "  - remove the old one:  sudo rm '$EXISTING_COMMIT'"
        echo "  - then re-run:         ./deploy.sh"
        exit 1
    fi
fi

# Ask for sudo once if needed
if [[ $EUID -ne 0 ]]; then
    echo "Requesting sudo for system install..."
    sudo -v
fi

echo "Installing binaries..."

sudo cp "$PULL_SRC" "$PULL_DEST"
sudo cp "$PUSH_SRC" "$PUSH_DEST"
sudo cp "$COMMIT_SRC" "$COMMIT_DEST"

sudo chmod +x "$PULL_DEST" "$PUSH_DEST" "$COMMIT_DEST"

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
echo " - commit -> $COMMIT_DEST"
echo " - config -> $ENV_DEST"
echo
echo "Done."

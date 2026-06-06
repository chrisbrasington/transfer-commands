#!/usr/bin/env bash

set -euo pipefail

# ---- Load .env ----
# Prefer an installed config, fall back to one next to this script.
CONFIG_DIR="${TRANSFER_COMMANDS_CONFIG:-$HOME/.config/transfer-commands}"
ENV_FILE="$CONFIG_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    ENV_FILE="$SCRIPT_DIR/.env"
fi
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: no .env found (looked in $CONFIG_DIR and the script dir)." >&2
    echo "Run ./migrate.sh or copy .env.example to .env." >&2
    exit 1
fi
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

SSH_PORT="${SSH_PORT:-22}"
REMOTE_DIR="${TRANSFER_DIR:-./transfer}"
LOCAL_DIR="."

ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "--audiobook" ]]; then
        REMOTE_DIR="${AUDIOBOOK_DIR:-./audiobook}"
    else
        ARGS+=("$arg")
    fi
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

if [[ $# -eq 0 ]]; then
    echo "Remote files:"
    ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "ls -1 $REMOTE_DIR"
    exit 0
fi

PATTERN="$1"

echo "Pulling: $PATTERN from ${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}"
echo

rsync -avz --progress -e "ssh -p ${SSH_PORT}" "${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}/${PATTERN}" "$LOCAL_DIR/"

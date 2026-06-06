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

if [[ $# -eq 0 ]]; then
    echo "Usage: push [--audiobook] <file|pattern> [more files...]"
    exit 1
fi

FILES=()

for arg in "$@"; do
    if [[ "$arg" == "--audiobook" ]]; then
        REMOTE_DIR="${AUDIOBOOK_DIR:-./audiobook}"
        continue
    fi

    # Expand tilde safely
    eval "arg_expanded=\"$arg\""

    # If wildcard is used, expand it safely
    if [[ "$arg_expanded" == *"*"* ]]; then
        matches=( $arg_expanded )
        if [[ ${#matches[@]} -eq 0 ]]; then
            echo "No matches: $arg"
            exit 1
        fi
        FILES+=("${matches[@]}")
    else
        FILES+=("$arg_expanded")
    fi
done

# Validate without breaking spaces
for f in "${FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "Error: not a file -> $f"
        exit 1
    fi
done

echo "Pushing files:"
printf ' - %s\n' "${FILES[@]}"
echo

rsync -avz --progress -e "ssh -p ${SSH_PORT}" "${FILES[@]}" "${SSH_USER}@${SSH_HOST}:${REMOTE_DIR}/"

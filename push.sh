#!/usr/bin/env bash

set -euo pipefail

CONFIG_HOST="storage"
REMOTE_DIR="./transfer"

if [[ $# -eq 0 ]]; then
    echo "Usage: push [--audiobook] <file|pattern> [more files...]"
    exit 1
fi

FILES=()

for arg in "$@"; do
    if [[ "$arg" == "--audiobook" ]]; then
        REMOTE_DIR="./audiobook"
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

rsync -avz --progress "${FILES[@]}" "${CONFIG_HOST}:${REMOTE_DIR}/"

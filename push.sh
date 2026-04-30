#!/usr/bin/env bash

set -euo pipefail

CONFIG_HOST="storage"
REMOTE_DIR="./transfer"

if [[ $# -eq 0 ]]; then
    echo "Usage: ./push.sh <file|pattern> [more files...]"
    exit 1
fi

# Expand all args into a list of files (handles test*)
FILES=()

for arg in "$@"; do
    # If wildcard expands, bash already handles it
    # If it doesn't match, keep literal (we'll validate)
    matches=( $arg )

    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "No matches for: $arg"
        exit 1
    fi

    FILES+=("${matches[@]}")
done

# Validate files exist locally
for f in "${FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "Error: not a file -> $f"
        exit 1
    fi
done

echo "Pushing files:"
printf ' - %s\n' "${FILES[@]}"
echo
echo "Target: ${CONFIG_HOST}:${REMOTE_DIR}/"
echo

rsync -avz --progress "${FILES[@]}" "${CONFIG_HOST}:${REMOTE_DIR}/"

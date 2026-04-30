#!/usr/bin/env bash

set -euo pipefail

HOST="storage"
REMOTE_DIR="./transfer"
LOCAL_DIR="."

if [[ $# -eq 0 ]]; then
    echo "Remote files:"
    ssh "$HOST" "ls -1 $REMOTE_DIR"
    exit 0
fi

PATTERN="$1"

echo "Pulling: $PATTERN from $HOST:$REMOTE_DIR"
echo

rsync -avz --progress "${HOST}:${REMOTE_DIR}/${PATTERN}" "$LOCAL_DIR/"

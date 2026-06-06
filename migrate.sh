#!/usr/bin/env bash

set -euo pipefail

# Migrate the old SSH-style `config` file into a `.env` file.
# Safe to run more than once: it no-ops once `config` is gone.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLD_CONFIG="$SCRIPT_DIR/config"
ENV_FILE="$SCRIPT_DIR/.env"

if [[ ! -f "$OLD_CONFIG" ]]; then
    echo "No old 'config' file at $OLD_CONFIG — nothing to migrate."
    exit 0
fi

if [[ -f "$ENV_FILE" ]]; then
    echo "$ENV_FILE already exists — not overwriting."
    echo "Delete it first if you want to re-run the migration."
    exit 1
fi

# Parse the SSH-style config block (first match of each key wins).
host="$(awk 'tolower($1)=="hostname"{print $2; exit}' "$OLD_CONFIG")"
user="$(awk 'tolower($1)=="user"{print $2; exit}'     "$OLD_CONFIG")"
port="$(awk 'tolower($1)=="port"{print $2; exit}'     "$OLD_CONFIG")"

if [[ -z "$host" ]]; then
    echo "Could not find a HostName in $OLD_CONFIG — aborting."
    exit 1
fi

cat > "$ENV_FILE" <<EOF
SSH_HOST=${host}
SSH_USER=${user:-$USER}
SSH_PORT=${port:-22}
TRANSFER_DIR=./transfer
AUDIOBOOK_DIR=./audiobook
EOF

echo "Wrote $ENV_FILE:"
echo
cat "$ENV_FILE"
echo

rm "$OLD_CONFIG"
echo "Removed old $OLD_CONFIG."
echo "Migration complete."

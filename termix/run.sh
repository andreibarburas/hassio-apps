#!/bin/sh
set -e

OPTIONS_FILE="/data/options.json"

if [ -f "${OPTIONS_FILE}" ]; then
    SALT=$(jq --raw-output '.salt // empty' "${OPTIONS_FILE}")
    [ -n "${SALT}" ] && export SALT
fi

export PORT=8080

# Copy any existing /app/data contents to /data before wiping it
if [ -d /app/data ] && [ ! -L /app/data ]; then
    cp -a /app/data/. /data/ 2>/dev/null || true
fi

# Force symlink /app/data -> /data (HA persistent storage)
rm -rf /app/data
ln -sf /data /app/data

exec node /app/dist/backend/backend/starter.js

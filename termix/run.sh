#!/bin/sh
set -e

OPTIONS_FILE="/data/options.json"

if [ -f "${OPTIONS_FILE}" ]; then
    SALT=$(jq --raw-output '.salt // empty' "${OPTIONS_FILE}")
    [ -n "${SALT}" ] && export SALT
fi

export PORT=8080

# Pass data directory for persistent storage
export DATA_DIR="/data"

exec node /app/backend/server.js

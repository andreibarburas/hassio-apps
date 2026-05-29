#!/bin/sh
set -e

OPTIONS_FILE="/data/options.json"

if [ -f "${OPTIONS_FILE}" ]; then
    SALT=$(jq --raw-output '.salt // empty' "${OPTIONS_FILE}")
    [ -n "${SALT}" ] && export SALT
fi

export PORT=8080

# Symlink HA's persistent /data volume to where Termix stores its data
rm -rf /app/data
ln -s /data /app/data

exec node /app/dist/backend/backend/starter.js

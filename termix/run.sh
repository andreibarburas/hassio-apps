#!/bin/sh
set -e

OPTIONS_FILE="/data/options.json"

if [ -f "${OPTIONS_FILE}" ]; then
    SALT=$(jq --raw-output '.salt // empty' "${OPTIONS_FILE}")
    [ -n "${SALT}" ] && export SALT
fi

export PORT=9513
export DATA_DIR=/data

# Fix permissions so the node user can write to HA's persistent /data volume
chmod 1777 /data

exec /entrypoint.sh

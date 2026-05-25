#!/bin/sh
set -e

OPTIONS_FILE="/data/options.json"

if [ -f "${OPTIONS_FILE}" ]; then
    SERVER_NAME=$(jq --raw-output '.server_name // empty' "${OPTIONS_FILE}")
    SERVER_TYPE=$(jq --raw-output '.server_type // empty' "${OPTIONS_FILE}")
    SERVER_URL=$(jq --raw-output '.server_url // empty' "${OPTIONS_FILE}")
    SERVER_LOCK=$(jq --raw-output '.server_lock // "false"' "${OPTIONS_FILE}")
    ANALYTICS_DISABLED=$(jq --raw-output '.analytics_disabled // "true"' "${OPTIONS_FILE}")

    [ -n "${SERVER_NAME}" ] && export SERVER_NAME
    [ -n "${SERVER_TYPE}" ] && export SERVER_TYPE
    [ -n "${SERVER_URL}" ]  && export SERVER_URL
    export SERVER_LOCK
    export ANALYTICS_DISABLED
fi

exec /docker-entrypoint.sh nginx -g "daemon off;"

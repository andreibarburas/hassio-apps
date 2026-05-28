#!/bin/sh
set -e

OPTIONS_FILE="/data/options.json"

if [ -f "${OPTIONS_FILE}" ]; then
    SALT=$(jq --raw-output '.salt // empty' "${OPTIONS_FILE}")
    [ -n "${SALT}" ] && export SALT
fi

export PORT=8080

# Find and execute the original entrypoint from the image
# The app lives in /app, find the main entry point
cd /app

if [ -f "package.json" ]; then
    START_CMD=$(jq --raw-output '.scripts.start // empty' package.json)
fi

if [ -n "${START_CMD}" ]; then
    exec sh -c "${START_CMD}"
elif [ -f "server.js" ]; then
    exec node server.js
elif [ -f "index.js" ]; then
    exec node index.js
elif [ -f "src/index.js" ]; then
    exec node src/index.js
elif [ -f "dist/index.js" ]; then
    exec node dist/index.js
else
    echo "ERROR: Could not find Termix entry point. Contents of /app:"
    ls -la /app/
    exit 1
fi

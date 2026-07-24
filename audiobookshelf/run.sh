#!/bin/sh
set -e

# Ensure config/metadata dirs exist on first run (fresh /data volume)
mkdir -p "$CONFIG_PATH" "$METADATA_PATH"

# Pull TZ out of HA's options.json, if present
if [ -f /data/options.json ]; then
  TZ_OPT="$(jq -r '.TZ // "Etc/UTC"' /data/options.json)"
  export TZ="$TZ_OPT"
fi

exec node index.js

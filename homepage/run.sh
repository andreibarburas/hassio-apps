#!/bin/sh
set -e

CONFIG_PATH=/data/options.json

# bashio isn't available in this wrapped third-party image, so options.json
# is read directly with jq.
ALLOWED_HOSTS=$(jq -r '.allowed_hosts // empty' "$CONFIG_PATH")
PUID_OPT=$(jq -r '.puid // 0' "$CONFIG_PATH")
PGID_OPT=$(jq -r '.pgid // 0' "$CONFIG_PATH")

if [ -z "$ALLOWED_HOSTS" ]; then
  echo "[homepage-addon] ERROR: the 'allowed_hosts' option is not set."
  echo "[homepage-addon] Set it in the addon Configuration tab to the host:port"
  echo "[homepage-addon] (or domain) you use to reach this addon, e.g. 10.10.30.234:7575"
  exit 1
fi

# Homepage splits this on "," without trimming whitespace, so "a, b" would
# leave " b" (leading space) as a literal entry and silently fail to match.
# Strip all whitespace here so a stray space in the option never breaks this.
ALLOWED_HOSTS=$(echo "$ALLOWED_HOSTS" | tr -d '[:space:]')

export HOMEPAGE_ALLOWED_HOSTS="$ALLOWED_HOSTS"
export PUID="$PUID_OPT"
export PGID="$PGID_OPT"

# Home Assistant's "addon_config" map mounts this addon's user-editable
# config folder at /config (visible on the host under
# /addon_configs/<slug>/, and from there in Samba / File Editor). Homepage
# itself expects its config at /app/config, so point one at the other.
# (Upstream's Dockerfile does not declare /app/config as a VOLUME, so this
# plain bind/symlink approach works without extra permission gymnastics.)
if [ ! -L /app/config ]; then
  rm -rf /app/config
  ln -s /config /app/config
fi

exec docker-entrypoint.sh node server.js

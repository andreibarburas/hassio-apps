#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

MUSIC_LIBRARY_PATH=$(jq -r '.music_library_path' "$CONFIG_PATH")

# Strip any leading slash so it composes cleanly under /media
MUSIC_LIBRARY_PATH="${MUSIC_LIBRARY_PATH#/}"

if [ ! -d "/media/${MUSIC_LIBRARY_PATH}" ]; then
    echo "[musicload-addon] WARNING: /media/${MUSIC_LIBRARY_PATH} does not exist yet."
    echo "[musicload-addon] Make sure this folder is registered under HA's Media"
    echo "[musicload-addon] folders (Settings > System > Storage) and matches the"
    echo "[musicload-addon] 'music_library_path' option, then creating it now."
    mkdir -p "/media/${MUSIC_LIBRARY_PATH}"
fi

# Upstream's own entrypoint only chowns its hardcoded /data and /downloads
# paths for the musicload user. Since we redirect MUSICLOAD_DOWNLOAD_DIR to a
# path under /media instead, that folder never gets touched by their chown -
# fix ownership on just the top-level target dir (not recursively, to avoid
# rewriting ownership across your whole existing library) so the musicload
# user can create new subfolders/files under it.
chown musicload:musicload "/media/${MUSIC_LIBRARY_PATH}"
chmod u+rwx "/media/${MUSIC_LIBRARY_PATH}"

export MUSICLOAD_DOWNLOAD_DIR="/media/${MUSIC_LIBRARY_PATH}"
export MUSICLOAD_DATA_DIR="/data"
# MUSICLOAD_WEB_PORT stays at the image default (8000) internally.
# HA's ports mapping (config.yaml) handles the external 8420 -> 8000 translation.

echo "[musicload-addon] Download dir: ${MUSICLOAD_DOWNLOAD_DIR}"

# Hand off to the upstream image's own entrypoint, which chowns /data and
# /downloads (bind mounts) and drops from root to the musicload user via gosu.
exec /entrypoint.sh "$@"

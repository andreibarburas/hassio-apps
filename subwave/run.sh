#!/usr/bin/env bash

set -e

CONFIG_PATH=/data/options.json

log() { echo "[subwave] $*"; }

# ── Read options ──────────────────────────────────────────────────────────────
ADMIN_USER=$(jq -r '.admin_user' "${CONFIG_PATH}")
ADMIN_PASS=$(jq -r '.admin_pass' "${CONFIG_PATH}")
SITE_URL=$(jq -r '.site_url' "${CONFIG_PATH}")
TZ_OPT=$(jq -r '.tz' "${CONFIG_PATH}")

if [ -z "${ADMIN_PASS}" ]; then
    log "ERROR: admin_pass is empty. The controller refuses to boot without it"
    log "       (NODE_ENV=production). Set a strong password in the addon"
    log "       configuration (e.g. openssl rand -hex 16) and restart."
    exit 1
fi

# ── Persistent storage ────────────────────────────────────────────────────────
# The upstream image hardcodes /var/sub-wave in several places (the controller's
# STATE_DIR isn't env-overridable at runtime) rather than declaring it as a
# Docker VOLUME, so a plain symlink to HA's /data mount works cleanly — same
# storage-redirect approach used for Solidtime's /var/www/html/storage.
#
# Cosmetic note: the upstream supervisor's "is /var/sub-wave a mounted volume?"
# check greps /proc/mounts for the literal path, which won't match a symlink
# even though /data behind it really is persistent — expect a harmless
# "NOT a mounted volume" warning in the log on every boot.
mkdir -p /data
if [ ! -L /var/sub-wave ]; then
    rm -rf /var/sub-wave
    ln -sfn /data /var/sub-wave
fi

# ── Export env for the supervisor's child processes ──────────────────────────
export ADMIN_USER="${ADMIN_USER}"
export ADMIN_PASS="${ADMIN_PASS}"
export SITE_URL="${SITE_URL}"
export TZ="${TZ_OPT:-Europe/London}"

log "Starting Subwave (admin user: ${ADMIN_USER})..."
log "First run? Finish setup in the browser at ${SITE_URL}/onboarding"

exec /usr/local/bin/subwave-supervisor

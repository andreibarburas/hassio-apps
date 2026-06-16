#!/bin/sh
set -e

CONFIG_DIR="/etc/searxng"
SETTINGS_TEMPLATE="${CONFIG_DIR}/settings.yml.template"
DATA_DIR="/data/searxng"
PERSISTENT_SETTINGS="${DATA_DIR}/settings.yml"

echo "[SearXNG] Starting addon..."

# ── Persistent data setup ────────────────────────────────────────────────────
# /data is HA's persistent volume. Settings live here and survive addon updates.
mkdir -p "${DATA_DIR}/cache"

if [ ! -f "${PERSISTENT_SETTINGS}" ]; then
    echo "[SearXNG] First run — copying hardened settings template to /data..."
    cp "${SETTINGS_TEMPLATE}" "${PERSISTENT_SETTINGS}"
fi

# ── Secret key generation (first run only) ───────────────────────────────────
if grep -q "REPLACEME" "${PERSISTENT_SETTINGS}" 2>/dev/null; then
    echo "[SearXNG] Generating unique secret_key..."
    SECRET=$(openssl rand -hex 32)
    sed -i "s/REPLACEME/${SECRET}/" "${PERSISTENT_SETTINGS}"
fi

# ── Wire up directories ──────────────────────────────────────────────────────
# The image reads config from /etc/searxng and caches to /var/cache/searxng.
# Symlink both into our persistent /data volume.

# Config dir: replace with our persistent settings
mkdir -p "${CONFIG_DIR}"
ln -sf "${PERSISTENT_SETTINGS}" "${CONFIG_DIR}/settings.yml"

# Cache dir: persist favicon cache etc.
if [ ! -L "/var/cache/searxng" ]; then
    rm -rf /var/cache/searxng
    ln -sf "${DATA_DIR}/cache" /var/cache/searxng
fi

# The image's FORCE_OWNERSHIP mechanism fixes uid on /etc/searxng & /var/cache/searxng.
# We ensure /data/searxng is also writable by the searxng user (uid 1000).
chown -R 1000:1000 "${DATA_DIR}" 2>/dev/null || true

echo "[SearXNG] Settings ready at ${PERSISTENT_SETTINGS}"
echo "[SearXNG] Handing off to Granian on port 9090..."

# ── Environment for Granian (port cannot be set via settings.yml — known upstream issue) ──
export GRANIAN_HOST="::"
export GRANIAN_PORT="9090"
# Belt-and-suspenders privacy env vars (some are read by the image's entrypoint)
export SEARXNG_SECRET="$(grep 'secret_key:' "${PERSISTENT_SETTINGS}" | awk '{print $2}' | tr -d '"')"
export SEARXNG_PUBLIC_INSTANCE="false"
export SEARXNG_DEBUG="false"
export SEARXNG_SETTINGS_PATH="${CONFIG_DIR}/settings.yml"
# Disable FORCE_OWNERSHIP here since we already handled permissions above
export FORCE_OWNERSHIP="false"

# Delegate to the upstream container entrypoint (handles Granian startup)
exec /sbin/tini -- /usr/local/searxng/container/entrypoint.sh

ARG BUILD_FROM=ghcr.io/searxng/searxng:latest
FROM ${BUILD_FROM}

USER root

# Write the hardened settings template directly into the image
RUN mkdir -p /etc/searxng && cat > /etc/searxng/settings.yml.template << 'EOF'
use_default_settings: true

general:
  debug: false
  instance_name: "SearXNG"
  public_instance: false

server:
  secret_key: "REPLACEME"
  bind_address: "0.0.0.0"
  port: 8080
  image_proxy: true
  method: "POST"
  default_http_headers:
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Robots-Tag: noindex, nofollow
    Referrer-Policy: no-referrer
    X-Frame-Options: DENY

search:
  autocomplete: ""
  safe_search: 0
  default_lang: "all"
  formats:
    - html
    - json

ui:
  query_in_title: false
  infinite_scroll: false
  default_theme: simple
  theme_args:
    simple_style: auto

outgoing:
  request_timeout: 3.0
  max_request_timeout: 10.0
  useragent_suffix: ""
  pool_connections: 100
  pool_maxsize: 10
  enable_http2: true
  # To route via a proxy in future, uncomment:
  # proxies:
  #   all://:
  #     - socks5h://vpn-container:1080
  # extra_proxy_timeout: 10.0
EOF

# Write the run script directly into the image
RUN cat > /run.sh << 'EOF'
#!/bin/sh
set -e

CONFIG_DIR="/etc/searxng"
SETTINGS_TEMPLATE="${CONFIG_DIR}/settings.yml.template"
DATA_DIR="/data/searxng"
PERSISTENT_SETTINGS="${DATA_DIR}/settings.yml"

echo "[SearXNG] Starting addon..."

mkdir -p "${DATA_DIR}/cache"

if [ ! -f "${PERSISTENT_SETTINGS}" ]; then
    echo "[SearXNG] First run — copying hardened settings to /data..."
    cp "${SETTINGS_TEMPLATE}" "${PERSISTENT_SETTINGS}"
fi

if grep -q "REPLACEME" "${PERSISTENT_SETTINGS}" 2>/dev/null; then
    echo "[SearXNG] Generating unique secret_key..."
    SECRET=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 64)
    sed -i "s/REPLACEME/${SECRET}/" "${PERSISTENT_SETTINGS}"
fi

ln -sf "${PERSISTENT_SETTINGS}" "${CONFIG_DIR}/settings.yml"

mkdir -p /var/cache/searxng

chown -R 1000:1000 "${DATA_DIR}" 2>/dev/null || true

echo "[SearXNG] Handing off to Granian on port 6789..."

export SEARXNG_PUBLIC_INSTANCE="false"
export SEARXNG_DEBUG="false"
export SEARXNG_SETTINGS_PATH="${CONFIG_DIR}/settings.yml"
export PYTHONPATH="/usr/local/searxng"

cd /usr/local/searxng

# Call granian directly with our port — avoids upstream entrypoint overriding our settings
exec /usr/local/searxng/.venv/bin/granian --interface wsgi --host "::" --port 6789 --workers 4 searx.webapp:application
EOF

RUN chmod +x /run.sh

EXPOSE 6789
ENTRYPOINT ["/run.sh"]

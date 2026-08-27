ARG BUILD_FROM=ghcr.io/perminder-klair/subwave-aio:1.10.0
FROM ${BUILD_FROM}

LABEL io.hass.version="1.10.0-1"

USER root

# bashio isn't available in this wrapped third-party image — plain jq reads
# /data/options.json instead (same pattern as the other addons in this repo).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

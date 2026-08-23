FROM ghcr.io/kingdaniel4747/musicload:145b77bac681c49f45f3ae0ea2db01f45221cab8

# Plain bash + jq only: this wraps a third-party image, so bashio isn't available.
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Override the upstream ENTRYPOINT so we can translate HA's options.json into
# the env vars Musicload expects, then hand off to the original entrypoint
# (which does its own chown of /data and /downloads and drops root via gosu).
ENTRYPOINT ["/run.sh"]
CMD ["musicload", "web", "--host", "0.0.0.0"]

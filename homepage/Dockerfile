FROM ghcr.io/gethomepage/homepage:v2.1.2

# jq is used by run.sh to read Home Assistant's /data/options.json,
# since bashio isn't available inside this wrapped third-party image.
RUN apk add --no-cache jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

# The upstream image already ships docker-entrypoint.sh (handles PUID/PGID,
# IPv6 bind fallback, etc). We wrap it instead of replacing it.
ENTRYPOINT ["/run.sh"]
CMD ["node", "server.js"]

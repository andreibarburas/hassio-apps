ARG ABS_VERSION=2.35.1
FROM ghcr.io/advplyr/audiobookshelf:${ABS_VERSION}

# jq is used by run.sh to read the addon's options.json (HA doesn't ship bashio
# in this base image, and TZ is our only option, so a tiny jq wrapper is enough)
RUN apk add --no-cache jq

# The upstream image already respects these as env vars (see its Dockerfile),
# so we just point them at HA's persistent /data volume instead of symlinking.
ENV CONFIG_PATH=/data/config
ENV METADATA_PATH=/data/metadata
ENV PORT=9988

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 9988

# ENTRYPOINT is inherited from the base image (tini --), we only override CMD
CMD ["/run.sh"]

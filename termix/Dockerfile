ARG BUILD_FROM
FROM ghcr.io/lukegus/termix:latest

USER root

# Install jq to read HA addon options at runtime
RUN apk add --no-cache jq 2>/dev/null || \
    (apt-get update && apt-get install -y --no-install-recommends jq && apt-get clean && rm -rf /var/lib/apt/lists/*)

ENV PORT=9513
ENV DATA_DIR=/data

COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]

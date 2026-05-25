ARG BUILD_FROM
FROM ghcr.io/jeffvli/feishin:latest

# Switch to root to install packages (image runs as non-root by default)
USER root

RUN apk add --no-cache jq

# Copy our startup wrapper
COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]

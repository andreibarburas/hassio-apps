ARG BUILD_FROM=solidtime/solidtime:latest
FROM ${BUILD_FROM}

LABEL io.hass.version="0.4.4"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-15 \
        gosu \
        curl \
        jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/supervisor /var/run/postgresql && \
    chown postgres:postgres /var/run/postgresql

# Copy the image's own supervisord confs into place
RUN for f in /var/www/html/docker/prod/deployment/supervisord*.conf; do \
        cp "$f" /etc/supervisor/conf.d/; \
    done && \
    cp /var/www/html/docker/prod/deployment/supervisord.conf /etc/supervisord.conf

# Replace /dev/stdout and /dev/stderr with actual log files in all confs
# to avoid EACCES when supervisord spawns processes
RUN sed -i \
        -e 's|stdout_logfile = /dev/stdout|stdout_logfile = /var/log/supervisor/app.log|g' \
        -e 's|stderr_logfile = /dev/stderr|stderr_logfile = /var/log/supervisor/app.log|g' \
        -e 's|stdout_logfile_maxbytes = 0|stdout_logfile_maxbytes = 10MB|g' \
        -e 's|stderr_logfile_maxbytes = 0|stderr_logfile_maxbytes = 10MB|g' \
        /etc/supervisor/conf.d/*.conf

RUN chmod +x /var/www/html/docker/prod/deployment/start-container

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

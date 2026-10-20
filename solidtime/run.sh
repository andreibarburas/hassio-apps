#!/usr/bin/env bash

set -e

CONFIG_PATH=/data/options.json

log() { echo "[solidtime] $*"; }

# ── Read options ──────────────────────────────────────────────────────────────
APP_URL=$(jq -r '.app_url' "${CONFIG_PATH}")
APP_KEY=$(jq -r '.app_key' "${CONFIG_PATH}")
PASSPORT_PRIVATE_KEY=$(jq -r '.passport_private_key' "${CONFIG_PATH}")
PASSPORT_PUBLIC_KEY=$(jq -r '.passport_public_key' "${CONFIG_PATH}")
DB_PASSWORD=$(jq -r '.db_password' "${CONFIG_PATH}")
DB_DATABASE=$(jq -r '.db_database' "${CONFIG_PATH}")
DB_USERNAME=$(jq -r '.db_username' "${CONFIG_PATH}")
SUPER_ADMINS=$(jq -r '.super_admins' "${CONFIG_PATH}")
APP_ENABLE_REGISTRATION=$(jq -r '.app_enable_registration' "${CONFIG_PATH}")
MAIL_MAILER=$(jq -r '.mail_mailer' "${CONFIG_PATH}")
MAIL_HOST=$(jq -r '.mail_host' "${CONFIG_PATH}")
MAIL_PORT=$(jq -r '.mail_port' "${CONFIG_PATH}")
MAIL_USERNAME=$(jq -r '.mail_username' "${CONFIG_PATH}")
MAIL_PASSWORD=$(jq -r '.mail_password' "${CONFIG_PATH}")
MAIL_FROM_ADDRESS=$(jq -r '.mail_from_address' "${CONFIG_PATH}")
MAIL_FROM_NAME=$(jq -r '.mail_from_name' "${CONFIG_PATH}")
AUTO_DB_MIGRATE=$(jq -r '.auto_db_migrate' "${CONFIG_PATH}")
TRUSTED_HOSTS=$(jq -r '.trusted_hosts' "${CONFIG_PATH}")

# ── PostgreSQL setup ──────────────────────────────────────────────────────────
PGDATA=/data/postgresql
PG_VERSION=17

mkdir -p "${PGDATA}"
chown -R postgres:postgres /data

# Detect major version mismatch (e.g. leftover PG15 data dir) and wipe it
if [ -f "${PGDATA}/PG_VERSION" ]; then
    EXISTING_VER=$(cat "${PGDATA}/PG_VERSION")
    if [ "${EXISTING_VER}" != "${PG_VERSION}" ]; then
        log "WARNING: Existing PostgreSQL data is version ${EXISTING_VER}, but this addon uses ${PG_VERSION}."
        log "Removing old data directory and starting fresh. Make sure you imported a Solidtime export first!"
        rm -rf "${PGDATA}"
        mkdir -p "${PGDATA}"
        chown postgres:postgres "${PGDATA}"
    fi
fi

if [ ! -d "${PGDATA}/global" ]; then
    log "Initialising PostgreSQL database..."
    gosu postgres /usr/lib/postgresql/17/bin/initdb \
        --pgdata="${PGDATA}" \
        --auth-local=trust \
        --auth-host=md5 \
        --encoding=UTF8 \
        --locale=C
fi

log "Starting PostgreSQL to initialise schema..."
# Remove stale lock file from a previous crashed run
rm -f "${PGDATA}/postmaster.pid"
gosu postgres /usr/lib/postgresql/17/bin/pg_ctl \
    -D "${PGDATA}" \
    -l /data/postgresql-init.log \
    -w start

gosu postgres psql -v ON_ERROR_STOP=0 <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USERNAME}') THEN
    CREATE ROLE "${DB_USERNAME}" WITH LOGIN PASSWORD '${DB_PASSWORD}';
  END IF;
END
\$\$;

SELECT 'CREATE DATABASE "${DB_DATABASE}" OWNER "${DB_USERNAME}"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${DB_DATABASE}')
\gexec
SQL

gosu postgres /usr/lib/postgresql/17/bin/pg_ctl -D "${PGDATA}" -w stop

# ── Export all env vars for the solidtime app ─────────────────────────────────
log "Setting solidtime environment..."

export APP_NAME="Solidtime"
export APP_ENV="production"
export APP_DEBUG="false"
export APP_URL="${APP_URL}"
export APP_FORCE_HTTPS="false"
export APP_ENABLE_REGISTRATION="${APP_ENABLE_REGISTRATION}"
export TRUSTED_PROXIES="0.0.0.0/0,2000:0:0:0:0:0:0:0/3"
export SUPER_ADMINS="${SUPER_ADMINS}"
export LOG_CHANNEL="stderr_daily"
export LOG_LEVEL="info"
export DB_CONNECTION="pgsql"
export DB_HOST="127.0.0.1"
export DB_PORT="5432"
export DB_DATABASE="${DB_DATABASE}"
export DB_USERNAME="${DB_USERNAME}"
export DB_PASSWORD="${DB_PASSWORD}"
export DB_SSLMODE="disable"
export QUEUE_CONNECTION="database"
export FILESYSTEM_DISK="local"
export PUBLIC_FILESYSTEM_DISK="public"
export MAIL_MAILER="${MAIL_MAILER}"
export MAIL_HOST="${MAIL_HOST}"
export MAIL_PORT="${MAIL_PORT}"
export MAIL_USERNAME="${MAIL_USERNAME}"
export MAIL_PASSWORD="${MAIL_PASSWORD}"
export MAIL_FROM_ADDRESS="${MAIL_FROM_ADDRESS}"
export MAIL_FROM_NAME="${MAIL_FROM_NAME}"
export APP_KEY="${APP_KEY}"
export PASSPORT_PRIVATE_KEY="${PASSPORT_PRIVATE_KEY}"
export PASSPORT_PUBLIC_KEY="${PASSPORT_PUBLIC_KEY}"
export OCTANE_SERVER="frankenphp"
export AUTO_DB_MIGRATE="${AUTO_DB_MIGRATE}"
export WORKER_COMMAND="php /var/www/html/artisan queue:work --sleep=3 --tries=3 --max-time=3600"

# ── Persistent storage ────────────────────────────────────────────────────────
mkdir -p /data/storage/app/public /data/storage/logs /data/storage/framework/cache/data /data/storage/framework/sessions /data/storage/framework/views /data/storage/framework/testing
chown -R 1000:1000 /data/storage

if [ ! -L /var/www/html/storage ]; then
    rm -rf /var/www/html/storage
    ln -s /data/storage /var/www/html/storage
fi

# ── Start postgres and keep it running before handing off ────────────────────
log "Starting PostgreSQL..."
rm -f "${PGDATA}/postmaster.pid"
gosu postgres /usr/lib/postgresql/17/bin/pg_ctl -D "${PGDATA}" -w start

# Wait until postgres is accepting connections
until gosu postgres psql -c "select 1" > /dev/null 2>&1; do
    log "Waiting for PostgreSQL to be ready..."
    sleep 1
done
log "PostgreSQL is ready."

log "Writing .env file for FrankenPHP/Octane..."
cat > /var/www/html/.env << ENVEOF
APP_NAME=Solidtime
APP_ENV=production
APP_DEBUG=false
APP_URL=${APP_URL}
APP_FORCE_HTTPS=false
APP_ENABLE_REGISTRATION=${APP_ENABLE_REGISTRATION}
TRUSTED_PROXIES=0.0.0.0/0,2000:0:0:0:0:0:0:0/3
TRUSTED_HOSTS=${TRUSTED_HOSTS}
SUPER_ADMINS=${SUPER_ADMINS}
APP_KEY=${APP_KEY}
LOG_CHANNEL=stderr_daily
LOG_LEVEL=info
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
DB_SSLMODE=disable
QUEUE_CONNECTION=database
FILESYSTEM_DISK=local
PUBLIC_FILESYSTEM_DISK=public
MAIL_MAILER=${MAIL_MAILER}
MAIL_HOST=${MAIL_HOST}
MAIL_PORT=${MAIL_PORT}
MAIL_USERNAME=${MAIL_USERNAME}
MAIL_PASSWORD=${MAIL_PASSWORD}
MAIL_FROM_ADDRESS=${MAIL_FROM_ADDRESS}
MAIL_FROM_NAME="${MAIL_FROM_NAME}"
OCTANE_SERVER=frankenphp
WORKER_COMMAND="php /var/www/html/artisan queue:work --sleep=3 --tries=3 --max-time=3600"
ENVEOF
printf 'PASSPORT_PRIVATE_KEY="%s"\n' "${PASSPORT_PRIVATE_KEY}" >> /var/www/html/.env
printf 'PASSPORT_PUBLIC_KEY="%s"\n' "${PASSPORT_PUBLIC_KEY}" >> /var/www/html/.env

log "Starting Solidtime via start-container (http mode)..."

# Ensure the supervisor log dir and file are writable by user 1000 (www-data)
mkdir -p /var/log/supervisor
touch /var/log/supervisor/app.log
chmod 777 /var/log/supervisor/app.log
chmod 777 /var/log/supervisor

# Overwrite the frankenphp supervisord conf with patched log paths at runtime.
# Build-time sed is unreliable due to HA image layer caching.
cat > /etc/supervisor/conf.d/supervisord.frankenphp.conf << 'SUPEOF'
[program:octane]
process_name = %(program_name)s_%(process_num)s
command = php %(ENV_ROOT)s/artisan octane:frankenphp --host=0.0.0.0 --port=8000 --admin-host=0.0.0.0 --admin-port=2019 --log-level=WARN --caddyfile=%(ENV_ROOT)s/docker/prod/deployment/octane/FrankenPHP/Caddyfile
user = %(ENV_USER)s
priority = 1
autostart = true
autorestart = true
stopwaitsecs = 30
stopasgroup = true
killasgroup = true
environment = LARAVEL_OCTANE = "1"
stdout_logfile = /var/log/supervisor/app.log
stdout_logfile_maxbytes = 10MB
stderr_logfile = /var/log/supervisor/app.log
stderr_logfile_maxbytes = 10MB

[include]
files = /etc/supervisord.conf /etc/supervisor/conf.d/supervisord.services.conf
SUPEOF

# Patch supervisord.services.conf log paths (uses %(ENV_ROOT)s/storage/logs/*.log)
sed -i 's|%(ENV_ROOT)s/storage/logs/[a-z.-]*log|/var/log/supervisor/app.log|g' \
    /etc/supervisor/conf.d/supervisord.services.conf 2>/dev/null || true

# Ensure Passport personal access client exists (needed for API tokens)
# Runs migrate first in case this is a fresh install and tables don't exist yet
gosu 1000 php /var/www/html/artisan migrate --isolated --force --quiet 2>/dev/null || true
if ! gosu 1000 php /var/www/html/artisan passport:client --list 2>/dev/null | grep -q "personal"; then
    log "Creating Passport personal access client..."
    gosu 1000 php /var/www/html/artisan passport:client --personal --name="API" --no-interaction
fi

export CONTAINER_MODE="http"
exec /var/www/html/docker/prod/deployment/start-container

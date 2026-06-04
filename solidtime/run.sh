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

# ── PostgreSQL setup ──────────────────────────────────────────────────────────
PGDATA=/data/postgresql

mkdir -p "${PGDATA}"
chown -R postgres:postgres /data

if [ ! -d "${PGDATA}/global" ]; then
    log "Initialising PostgreSQL database..."
    gosu postgres /usr/lib/postgresql/15/bin/initdb \
        --pgdata="${PGDATA}" \
        --auth-local=trust \
        --auth-host=md5 \
        --encoding=UTF8 \
        --locale=C
fi

log "Starting PostgreSQL to initialise schema..."
gosu postgres /usr/lib/postgresql/15/bin/pg_ctl \
    -D "${PGDATA}" \
    -l /var/log/supervisor/postgresql-init.log \
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

gosu postgres /usr/lib/postgresql/15/bin/pg_ctl -D "${PGDATA}" -w stop

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
gosu postgres /usr/lib/postgresql/15/bin/pg_ctl -D "${PGDATA}" -w start

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
export CONTAINER_MODE="http"
exec /var/www/html/docker/prod/deployment/start-container

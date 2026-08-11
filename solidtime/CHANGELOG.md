# Changelog

### [0.19.1] - 2026-08-11
- Bumped to Solidtime 0.19.1
- Added 'TRUSTED_HOSTS' configuration option (introduced in Solidtime 0.19.0)
  Solidtime now only accepts requests for the hostname configured in 'APP_URL'.
  Use this field to allow additional hostnames if needed.

### [0.17.0] - 2026-07-24
- Bumped to Solidtime 0.17.0

### [0.16.0] - 2026-07-16
- Bumped to Solidtime 0.16.0

### [0.15.0] - 2026-06-24
- Bumped to Solidtime 0.15.0

### [0.14.0-1]

- Fixed WORKER_COMMAND quoting in .env file causing startup failure

### [0.14.0]

- Fixed CHANGELOG.md
- Initial release of the Solidtime Home Assistant addon
- Bundled PostgreSQL 15 database (no external database required)
- Runs Solidtime via FrankenPHP/Octane for production-grade performance
- Includes scheduler and queue worker
- Persistent storage for database and uploaded files across restarts and updates
- Auto-migration on startup
- Configurable mail driver (log or SMTP)
- Nginx Proxy Manager compatible out of the box


# Changelog

### [0.15.0] - 2026-06-24
- Bumped to Termix 2.4.1

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


# Changelog

All notable changes to this addon repository are documented here.

---

## Feishin

### 1.8.0
- Initial release as a Home Assistant addon
- Based on 'ghcr.io/jeffvli/feishin:latest'
- Supports Navidrome, Jellyfin, and Subsonic-compatible servers
- Configurable server name, type, URL, lock mode, and analytics toggle
- HA ingress support on port 9180

---

## SearXNG

### 2026.6.15-2
- Fixed entrypoint to use SearXNG's venv granian directly
- Embedded settings and run script into Dockerfile (no rootfs needed)

### 2026.6.15-1
- Initial release of the SearXNG Home Assistant addon
- Wraps SearXNG latest (Granian/ASGI server) on port 6789
- Hardened settings: image proxy, POST method, no autocomplete, no public instance
- Auto-generated secret key on first run
- Persistent settings and cache in /data

---

## Solidtime

### 0.14.0-1
- Fixed WORKER_COMMAND quoting in .env file causing startup failure

### 0.14.0
- Fixed CHANGELOG.md
- Initial release of the Solidtime Home Assistant addon
- Bundled PostgreSQL 15 database (no external database required)
- Runs Solidtime via FrankenPHP/Octane for production-grade performance
- Includes scheduler and queue worker
- Persistent storage for database and uploaded files across restarts and updates
- Auto-migration on startup
- Configurable mail driver (log or SMTP)
- Nginx Proxy Manager compatible out of the box

---

## Termix

### [2.3.2-1] - 2026-06-05
- Fixed data persistence after update (hopefully)

### [2.3.2] - 2026-06-05
- Bumped to Termix 2.3.2

### 2.3.1
- Added 'map: data:rw' to persist data across updates and reinstalls
- Symlink '/app/data → /data' in 'run.sh' to use HA persistent storage
- Bumped to Termix 2.3.1

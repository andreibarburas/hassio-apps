# Changelog

---

## Termix

### [2.3.1] - 2026-06-04
- Added 'map: data:rw' to persist data across updates and reinstalls
- Symlink '/app/data → /data' in 'run.sh' to use HA persistent storage
- Bumped to Termix 2.3.1

### [2.2.1] - 2026-05-25
- Initial release as a Home Assistant addon
- Based on 'ghcr.io/lukegus/termix:latest'
- Entry point resolved to '/app/dist/backend/backend/starter.js'
- 'SALT' and 'PORT' injected via 'run.sh' from HA addon options
- HA ingress support on port 8080

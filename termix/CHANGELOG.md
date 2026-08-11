# Changelog

---

## Termix

### [2.6.1] - 2026-08-11
- Bumped to Termix 2.6.1

### [2.5.1] - 2026-07-24
- Bumped to Termix 2.5.1

### [2.5.0] - 2026-07-03
- Fixed data persistence across restarts and updates
- Root cause: upstream image declares '/app/data' as a Docker VOLUME, preventing HA bind mounts
- Solution: set 'DATA_DIR=/data' so Termix writes directly to HA's persistent volume
- Fixed permissions on '/data' so the node user can write to it
- Changed port to 9513

### [2.4.1] - 2026-06-24
- Bumped to Termix 2.4.1

### [2.4.0] - 2026-06-19
- Bumped to Termix 2.4.0

### [2.3.2-1] - 2026-06-05
- Fixed data persistence after update (hopefully)

### [2.3.2] - 2026-06-05
- Bumped to Termix 2.3.2

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

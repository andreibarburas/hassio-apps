# Changelog

For the Subwave changelog, go to: https://github.com/perminder-klair/subwave/releases

---

## Subwave Home Assistant app changelog

### [1.20.0] - 2026-10-09
- Bumped to Subwave v1.20.0
- Fixed: the 1.19 bump used a two-part image tag (`...subwave-aio:1.19`)
  instead of the full three-part release tag, and the Dockerfile's
  `ARG BUILD_FROM` default / `LABEL io.hass.version` were left stale at
  1.10.0 since the very first release — both are now kept in lockstep with
  `config.yaml` on every bump

### [1.19] - 2026-10-08
- Bumped to Subwave v1.19

### [1.16.0] - 2026-09-16
- Bumped to Subwave v1.16.0

### [1.15.0] - 2026-09-11
- Bumped to Subwave v1.15.0

### [1.13.0] - 2026-09-08
- Bumped to Subwave v1.13.0

### [1.12.0] - 2026-09-06
- Bumped to Subwave v1.12.0

### [1.11.0] - 2026-08-27
- Initial release as a Home Assistant addon
- Based on 'ghcr.io/perminder-klair/subwave-aio:1.10.0'
- Direct host port (7700) — HA Ingress avoided due to Icecast stream
  buffering requirements
- '/var/sub-wave' symlinked to the addon's persistent '/data'
- Configurable admin user/pass, site URL, and timezone

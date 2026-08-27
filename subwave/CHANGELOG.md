# Changelog

---

## Subwave

### [1.11.0] - 2026-08-27
- Initial release as a Home Assistant addon
- Based on 'ghcr.io/perminder-klair/subwave-aio:1.10.0'
- Direct host port (7700) — HA Ingress avoided due to Icecast stream
  buffering requirements
- '/var/sub-wave' symlinked to the addon's persistent '/data'
- Configurable admin user/pass, site URL, and timezone

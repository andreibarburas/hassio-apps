# Changelog

For the Homepage changelog, go to: https://github.com/gethomepage/homepage/releases

---

## Homepage Home Assistant app changelog

### [2.2.0] - 2026-09-03
- Bumped to Homepage 2.2.0

## 2.1.2
- Config now uses the 'addon_config' map, mounting at '/config' inside the
  container. This exposes the config folder at '/addon_configs/<slug>/' on
  the host, making it browsable/editable via Samba or the File Editor addon
  without 'docker exec' or SSH.
- 'run.sh' now strips whitespace from 'allowed_hosts' before exporting it,
  since Homepage splits on ',' without trimming and a stray space after a
  comma causes host validation to fail silently.
- Initial release, wraps upstream 'ghcr.io/gethomepage/homepage:v2.1.2'.
- Web UI exposed on host port 7575 (container port 3000).
- Config persisted at Home Assistant's addon '/data/config' (bound to
  Homepage's '/app/config').
- 'allowed_hosts' (required), 'puid', 'pgid' exposed as addon options.
- Docker socket integration intentionally omitted for now.

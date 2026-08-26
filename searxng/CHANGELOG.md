## 2026.08.26
- Bumped SearXNG to 2026.8.22

## 2026.08.10
- Bumped SearXNG to 2026.8.10

## 2026.07.22
- Bumped SearXNG to 2026.7.22

## 2026.07.15
- Bumped SearXNG to 2026.7.15

## 2026.07.7
- Bumped SearXNG to 2026.7.7

## 2026.6.15-2

- Fixed entrypoint to use SearXNG's venv granian directly
- Embedded settings and run script into Dockerfile (no rootfs needed)

## 2026.6.15-1

- Initial release
- Wraps SearXNG latest (Granian/ASGI server) on port 6789
- Hardened settings: image proxy, POST method, no autocomplete, no public instance
- Auto-generated secret key on first run
- Persistent settings and cache in /data

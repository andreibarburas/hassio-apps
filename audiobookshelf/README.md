# Audiobookshelf

Self-hosted audiobook and podcast server, packaged as a Home Assistant addon
by wrapping the official [ghcr.io/advplyr/audiobookshelf](https://github.com/advplyr/audiobookshelf) image.

## Access

Web UI: 'http://<home-assistant-ip>:9988'

## Media library

This addon mounts Home Assistant's built-in '/media' share (read-write) into
the container. After first login, add a library from inside Audiobookshelf's
UI and point it at a folder under '/media' (e.g. '/media/audiobooks',
'/media/podcasts') — create those folders under HA's media source first if
they don't already exist.

## Options

| Option | Description |
| --- | --- |
| 'TZ' | Timezone, e.g. 'Europe/Amsterdam'. Used for scheduled backups. |

## Notes

- Config and metadata (including the SQLite database) persist in the
  addon's own '/data' volume — don't point it at network storage.
- Unlike some LinuxServer-style images, the official Audiobookshelf image
  does not support 'PUID'/'PGID'.
- Requires a WebSocket-capable reverse proxy if you put this behind NPM —
  same as the Termix addon in this repo.

## Support

If this addon is useful to you, consider a donation:
https://bunq.me/barburasdonations

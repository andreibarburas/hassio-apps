# Musicload Add-on

Home Assistant add-on for [Musicload](https://github.com/kingdaniel4747/musicload) —
a mobile-first, self-hosted Navidrome companion for searching, previewing,
downloading and organizing music, with ListenBrainz automation.

Wraps `ghcr.io/kingdaniel4747/musicload:0.24.0` directly.

See [DOCS.md](DOCS.md) for setup and configuration.

## At a glance

- **Web UI**: `8420` (external) → `8000` (internal)
- **Persistent data**: HA-managed `/data` (settings, caches, accounts, logs,
  indexes, cookies)
- **Music library**: HA `media` share, read/write, subfolder set via the
  `music_library_path` option

## Support the upstream project

If Musicload makes your library workflow easier, consider supporting it on
[Ko-fi](https://ko-fi.com/kingdaniel4747).

## Support this add-on repo

https://bunq.me/barburasdonations

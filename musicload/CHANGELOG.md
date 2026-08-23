# Changelog

## 1.7

- Using Musicload version number
- Fixed `Permission denied` errors when writing into the music library
  folder. Upstream's entrypoint only chowns its hardcoded `/data` and
  `/downloads` paths; since this addon redirects `MUSICLOAD_DOWNLOAD_DIR` to
  a path under `/media` instead, `run.sh` now chowns that target folder
  (non-recursively) to the `musicload` user itself before handoff.

## 0.24.0

- Initial release, wrapping upstream Musicload `0.24.0` (pyproject.toml version
  at time of packaging).
- **Maintenance note**: upstream does not publish semver-tagged images on
  `ghcr.io/kingdaniel4747/musicload` — only `:latest` and per-commit-SHA
  tags. The Dockerfile pins to the commit SHA tag that corresponded to
  `0.24.0` (`145b77bac681c49f45f3ae0ea2db01f45221cab8`) for reproducible
  builds. To bump the addon version later, check upstream's `pyproject.toml`
  for the new version number and find the matching SHA tag on the package's
  ghcr.io page (Packages tab on the repo), then update the `FROM` line here.
- Web UI on internal port 8000, mapped to external 8420.
- Uses HA's `media` share for the music library (read/write) via a
  configurable `music_library_path` option.
- `/data` kept persistent for settings, caches, accounts, logs, indexes and
  the optional cookies file.

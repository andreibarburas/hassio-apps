# Audiobookshelf

Self-hosted audiobook and podcast server, packaged as a Home Assistant addon by wrapping the official [ghcr.io/advplyr/audiobookshelf](https://github.com/advplyr/audiobookshelf) image.

## Configuration

### TZ
The timezone Audiobookshelf should use, e.g. 'Europe/Amsterdam'. This is used for scheduled backups. Defaults to 'Etc/UTC'.

## Usage

After starting the addon, open the web UI via **Open Web UI** or the sidebar panel. On first launch you'll be prompted to create an administrator account.

### Media library

This addon mounts Home Assistant's built-in '/media' share (read-write) into the container. Create 'audiobooks' and 'podcasts' folders under HA's media source (via Samba, File Editor, or Studio Code Server) if they don't already exist, then, from inside Audiobookshelf's UI, add a library and point it at the relevant folder — e.g. '/media/audiobooks', '/media/podcasts'.

Directory structure and folder naming matter for Audiobookshelf to pick up metadata correctly — see the [official library docs](https://audiobookshelf.org/docs/category/libraries) for supported layouts.

### Config and metadata

Config and metadata — including the SQLite database — persist in the addon's own '/data' volume. Don't point this at network-mounted storage.

### Permissions

Unlike some LinuxServer-style images, the official Audiobookshelf image does not support 'PUID'/'PGID' environment variables.

### Reverse proxy

Audiobookshelf requires a WebSocket connection for real-time progress syncing and library updates. If you put this addon behind Nginx Proxy Manager, make sure websockets support is toggled on for the proxy host.

## Supported formats

M4B, MP3, M4A, FLAC, OGG, and OPUS for audio. Basic ebook support for EPUB, PDF, CBR, and CBZ.

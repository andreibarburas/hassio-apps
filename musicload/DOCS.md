# Musicload

Self-hosted, mobile-first companion for searching, previewing and downloading
music straight into your Navidrome library.

## Before you start

Musicload writes downloaded tracks into a folder that Navidrome then scans.
That folder must be one of HA's registered **Media** folders, since add-ons
can't bind arbitrary host paths directly.

1. In Home Assistant, go to **Settings → System → Storage → Add media
   folder**, and point it at the same host folder Navidrome already reads
   its library from (if you haven't already done this for another add-on).
2. Give it a name — this is the subfolder name you'll type into Musicload's
   `music_library_path` option below.

## Configuration

```yaml
music_library_path: music
```

- **music_library_path**: the subfolder under HA's `/media` share that holds
  your music library (the same one Navidrome reads from). This is a name,
  not a full path — e.g. if you registered a media folder called `music`,
  just enter `music`.

## First run

1. Start the add-on and open `http://SERVER_IP:8420`.
2. Go to **Settings** and configure Musicload from the web UI (ListenBrainz,
   Navidrome login, Gotify, cookies, filename templates, etc.).
3. Search for a track, preview it, and download. Navidrome will pick up the
   new file on its next library scan.

## Persistent data

The add-on's own `/data` folder (managed by HA) stores Musicload's settings,
caches, accounts, logs, indexes, and an optional uploaded `cookies.txt`. This
is separate from your music library and persists across add-on restarts and
updates automatically — no action needed.

## Notes

- Only one music folder is needed for this add-on (write access). The
  read-only mount mentioned in Musicload's own docs is for Navidrome's own
  container, not this add-on.
- If login is disabled in Musicload's settings, anyone who can reach the
  add-on's web UI is treated as an administrator. Don't expose it directly
  to the internet without enabling login or putting it behind auth in your
  reverse proxy.

## Support

- Upstream project: https://github.com/kingdaniel4747/musicload
- If you'd like to support this add-on repo: https://bunq.me/barburasdonations

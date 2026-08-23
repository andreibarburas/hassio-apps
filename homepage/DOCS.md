# Home Assistant Add-on: Homepage

[Homepage](https://gethomepage.dev/) is a highly customizable startpage /
application dashboard with Docker and service API integrations. This addon
wraps the official upstream image `ghcr.io/gethomepage/homepage`.

## Installation

1. Add this repository to your Home Assistant addon store (if not already
   added), then install "Homepage".
2. Set the `allowed_hosts` option (see below) before starting.
3. Start the addon and open the Web UI.

## Configuration

### `allowed_hosts` (required)

Homepage refuses to serve requests unless the `Host` header matches this
value exactly, as a security measure. Set it to whatever host:port (or
domain) you will use to reach the addon, comma-separated if you need more
than one, e.g.:

```yaml
allowed_hosts: "10.10.30.234:7575"
```

**No spaces around the commas.** Homepage splits this value on `,` without
trimming whitespace, so `a, b` leaves `" b"` (with a leading space) as an
entry, which will never match a real `Host` header and fails validation
with no obvious reason why. Always write it as `a,b`:

```yaml
allowed_hosts: "10.10.10.100,10.10.30.234:7575"
```

If you later put this addon behind Nginx Proxy Manager on a subdomain, add
that hostname too (still no spaces):

```yaml
allowed_hosts: "10.10.30.234:7575,homepage.yourdomain.tld"
```

### `puid` / `pgid` (optional)

Defaults to `0` (root), matching upstream's default behavior. Only change
these if you need the container to write config files as a specific
non-root user — if you do, make sure the ownership of the addon's data
folder matches.

## Storage & editing the config

Homepage's config files (`settings.yaml`, `services.yaml`, `bookmarks.yaml`,
`widgets.yaml`, etc.) live under `/addon_configs/local_homepage/` on the
host (exact path may differ if this addon isn't installed as `local_`) —
this is standard Home Assistant addon config storage, so it's reachable two
easy ways without SSH or `docker exec`:

- **Samba**: if you have the Samba share addon installed, browse to the
  `addon_configs` share and look for the `homepage` folder.
- **File Editor / Studio Code Server addons**: these already have access
  to `/addon_configs`, so you can open and edit the YAML files directly
  with syntax highlighting.

See [gethomepage.dev/configs/settings](https://gethomepage.dev/configs/settings/)
for what goes in each file. Homepage picks up changes to these files
automatically — no addon restart needed for most edits.

On first start, if the directory is empty, Homepage will populate it with
its default skeleton config — edit those files rather than starting from
scratch.

### Why not edit it from the addon's Configuration tab?

The Configuration tab is built for a fixed set of typed startup options
(strings, numbers, booleans) — not for free-form multi-file YAML editing.
It's technically possible to stuff each config file's contents into a
single large text option and have `run.sh` write it out on start, but
that loses live reload, syntax highlighting, and multi-file structure, and
only takes effect after a restart. Editing the files directly via Samba or
File Editor is the better experience and is what Homepage's own docs
assume.

## Docker integration

This addon does **not** mount the Docker socket, so Docker-based service
discovery and container status widgets are not available. This was a
deliberate choice to avoid granting the addon access to the host's Docker
socket. If you want that later, it can be added as a follow-up.

## Reverse proxy note

Homepage does not reliably support being served from a subpath (e.g. behind
Home Assistant Ingress or a path-based reverse proxy rule) — the app's
static assets assume it is served from the root of a hostname. If you want
to reach it externally, proxy a dedicated subdomain (e.g.
`homepage.yourdomain.tld`) straight through to port 7575 rather than a
subpath.

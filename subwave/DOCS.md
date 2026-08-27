# Subwave

A self-hosted AI internet radio station. It connects to a Navidrome library
and an LLM provider, then runs a real DJ-narrated station: Icecast + Liquidsoap
handle the broadcast, a Node controller acts as the DJ brain, and a Next.js
listener UI serves the front end — all bundled into one container by the
upstream project's official all-in-one image
([perminder-klair/subwave](https://github.com/perminder-klair/subwave)).

## Configuration

### Admin user
Username for the admin gate (`/admin` + the first-run setup wizard).

### Admin pass
Password for the admin gate. **Required** — the controller refuses to start
without one. Generate a strong one, e.g. `openssl rand -hex 16`.

### Site URL
The public address of your station, e.g. `http://homeassistant.local:7700` or
`https://radio.example.com` if you're fronting this with your own reverse
proxy. Backs share cards, absolute links, and OG tags. If you later put this
behind Nginx Proxy Manager (or similar) for a hostname, update this to the
public `https://` address.

### TZ
Timezone for the container, e.g. `Europe/Amsterdam`. Keeps the hourly archive
filenames and the DJ's schedule slots on local time instead of UTC.

## Usage

1. Start the addon and open `http://<your-ha-ip>:7700/onboarding`.
2. Sign in with the admin user/pass set above.
3. The wizard collects everything else — Navidrome URL + credentials, your
   LLM provider (Ollama, Anthropic, OpenAI, etc.), TTS engine, and the DJ
   persona — and tests each against the live service before saving.
4. Once configured, the station is on air at `http://<your-ha-ip>:7700`.

## Networking

This addon exposes a **direct host port** rather than using HA Ingress. The
live audio stream (`/stream.mp3`, `/stream.opus`) needs response buffering
off end-to-end — Ingress may buffer and cause stutter — so a direct port
avoids that risk entirely, same as the upstream project's own guidance for
reverse proxies.

If you front this with Nginx Proxy Manager or another reverse proxy for a
public hostname, exempt the stream paths from buffering. In NPM: **Advanced**
tab on the proxy host →

```nginx
location ^~ /stream {
    proxy_pass http://<your-ha-ip>:7700;
    proxy_buffering off;
    proxy_cache off;
    proxy_read_timeout 1h;
}
```

Everything else (`/`, `/api/*`) proxies normally — the container's internal
Caddy already handles same-origin routing for you.

## Persistent storage

Station state (settings, library cache, hourly archives, rendered voices,
Icecast secrets) lives under this addon's `/data` — the upstream image
normally expects this at `/var/sub-wave`, which is symlinked to `/data`
internally. Back up `/addon_configs/subwave` (or wherever your HA install
keeps addon data) to keep your library and settings safe across reinstalls.

## Notes

- This image is **amd64 only** — the upstream all-in-one build doesn't ship
  an arm64 variant (its Next.js build fails to cross-compile under QEMU).
- Updating: bump the pinned tag in this addon's `Dockerfile`/`config.yaml` to
  a newer [subwave release](https://github.com/perminder-klair/subwave/releases)
  and rebuild.
- Cloud LLM/TTS API keys (Anthropic, OpenAI, ElevenLabs, etc.) are entered in
  the setup wizard itself, not as addon options — they're saved to the
  station's own `secrets.env` inside persistent storage.

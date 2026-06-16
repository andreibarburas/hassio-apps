# SearXNG

A privacy-respecting, self-hosted metasearch engine that aggregates results from multiple search engines without tracking you.

## Usage

Once installed, open the Web UI via the button in the addon panel. SearXNG will be accessible at port **9090**.

## Privacy hardening applied

This addon comes pre-configured for maximum privacy:

- **Image proxy enabled** — images are fetched by your HA server, so your browser never contacts search engine CDNs
- **POST method** — search queries are sent as POST requests, keeping them out of browser history and server logs
- **No autocomplete** — disabling autocomplete prevents your keystrokes from being sent to third parties
- **Private instance** — public instance features are disabled
- **No referrer** — `Referrer-Policy: no-referrer` header prevents leaking where you came from
- **Unique secret key** — auto-generated on first run, specific to your instance

## Persistent data

Settings are stored in `/data/searxng/settings.yml`. You can customise this file (e.g. enable/disable specific search engines, change language defaults) and it will survive addon updates.

## Advanced: routing through a VPN/proxy

To route outgoing search requests through a SOCKS5 or HTTP proxy, edit `/data/searxng/settings.yml` and uncomment the `proxies` block under `outgoing:`:

```yaml
outgoing:
  proxies:
    all://:
      - socks5h://your-vpn-container:1080
  extra_proxy_timeout: 10.0
```

Restart the addon after saving.

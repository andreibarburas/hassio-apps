# Feishin

A modern self-hosted music player that connects to your Navidrome, Jellyfin, or Subsonic-compatible server.

## Configuration

### Server name
A friendly display name for your music server shown in the Feishin interface (e.g. `My Navidrome`). Leave empty to configure on first launch.

### Server type
The type of music server you are connecting to: `jellyfin`, `navidrome`, or `subsonic`. Leave empty to let the user choose at first launch.

### Server URL
The full URL to your music server, including protocol and port number where applicable. Examples:

- `http://192.168.1.10:4533` (local Navidrome)
- `https://navidrome.example.com` (proxied via Nginx Proxy Manager)
- `http://192.168.1.10:8096` (local Jellyfin)

### Lock server settings
When set to `true` **and** server name, type, and URL are all configured, users will only be able to enter their username and password — the server connection fields will be locked and cannot be changed from the UI. Useful if you want to share the instance with other household members.

### Disable analytics
Controls whether Feishin loads the Umami analytics script. Set to `true` (the default) to disable analytics tracking entirely.

## Usage

After starting the addon, open the web UI via **Open Web UI** or the sidebar panel. On first launch (when no server is pre-configured), you will be prompted to add a server connection.

For the best playback experience, the web client uses the browser's built-in audio engine. This addon runs the web version of Feishin — the desktop MPV backend is not available in Docker.

## Supported servers

- [Navidrome](https://www.navidrome.org/)
- [Jellyfin](https://jellyfin.org/)
- Any [OpenSubsonic](https://opensubsonic.netlify.app/)-compatible server (Airsonic-Advanced, Gonic, Funkwhale, Nextcloud Music, etc.)

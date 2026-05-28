# Termix

A self-hosted, open-source server management platform accessible from your browser. Manage SSH connections, run terminals, create tunnels, and edit remote files — all from a single web interface.

## Features

- **SSH Terminal** — Full terminal with split-screen (up to 4 panels) and tab system
- **SSH Tunnel Management** — Create and manage tunnels with auto-reconnect
- **Remote File Editor** — Edit files on remote servers with syntax highlighting
- **SSH Host Manager** — Organise connections with tags and folders
- **Server Stats** — View CPU, memory, and disk usage on any connected server
- **User Authentication** — Multi-user support with admin controls and OIDC/TOTP

## Configuration

### Salt

A secret string used to encrypt all stored credentials and session data. **This is required** — Termix will refuse to start without it.

Generate a random value (up to 32 characters) at [lastpass.com/features/password-generator](https://www.lastpass.com/features/password-generator) — enable all character types for best entropy.

> **Important:** If you change the salt after initial setup, all stored credentials will be invalidated and you will need to re-enter your SSH host passwords.

## Persistent data

All Termix data (hosts, users, credentials) is stored in the HA addon `/data` directory, which persists across restarts and updates.

## Usage

After starting the addon, open the web UI via **Open Web UI** or the sidebar panel. On first launch you will be prompted to create an admin account.

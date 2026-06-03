# Solidtime Add-on

A modern open-source time tracker for freelancers and agencies. Tracks time entries, projects, clients, and generates PDF reports and invoices.

This add-on bundles solidtime together with an internal PostgreSQL 15 database and runs the HTTP server, scheduler, and queue worker as a single managed unit.

---

## First-time Setup

### 1. Generate the application keys

Before starting the add-on for the first time, run this command on any machine with Docker available:

```bash
docker run --rm solidtime/solidtime:latest php artisan self-host:generate-keys
```

This outputs three values:
- `APP_KEY`
- `PASSPORT_PRIVATE_KEY`
- `PASSPORT_PUBLIC_KEY`

Copy each value into the corresponding add-on configuration fields. **Save them somewhere safe** — you will need to re-enter them if you reinstall.

### 2. Configure the add-on

- Set **Application URL** to the URL you will use to access Solidtime (e.g. `https://solidtime.yourdomain.com`)
- Set a strong **Database Password**
- Add your email to **Super Admin Email(s)**
- Leave **Mail Driver** as `log` for now (registration confirmation links will appear in the add-on log)
- Enable **Auto-migrate Database** (recommended)

### 3. Start the add-on

Start the add-on. On first boot it will:
1. Initialise the PostgreSQL database
2. Create the database user and schema
3. Run all Laravel migrations
4. Start the web server, scheduler, and queue worker

### 4. Create your account

Registration is disabled by default. You have two options:

**Option A — Enable registration temporarily**
- Set **Enable Registration** to `true`, restart the add-on
- Register at `/register`
- Set **Enable Registration** back to `false` and restart

**Option B — Use the CLI**
Open the add-on log or use the HA terminal to run:

```bash
# Via HA SSH addon or terminal:
docker exec -it addon_local_solidtime gosu www-data php /var/www/html/artisan \
  admin:user:create "Your Name" "you@example.com" --verify-email
```

The command outputs a temporary password. Log in, then change it in your profile settings.

### 5. Set up the reverse proxy

Point a proxy host in Nginx Proxy Manager to `homeassistant.local:8000` (or `<ha-ip>:8000`). No special headers are needed.

---

## Activating Desktop / Browser Extension Access

After logging in as a super admin, run:

```bash
# Desktop client OAuth
docker exec addon_local_solidtime gosu www-data php /var/www/html/artisan \
  passport:client --name=desktop --redirect_uri=solidtime://oauth/callback --public -n

# Browser extension OAuth
docker exec addon_local_solidtime gosu www-data php /var/www/html/artisan \
  passport:client --name=browser-extension \
  --redirect_uri=https://3369f72567118d8c03fb34880e9d6378d3b0c569.extensions.allizom.org/,https://hpanifeankiobmgbemnhjmhpjeebdhdd.chromiumapp.org/ \
  --public -n

# Personal API tokens
docker exec addon_local_solidtime gosu www-data php /var/www/html/artisan \
  passport:client --personal --name="API"
```

---

## Persistent Data

All data (PostgreSQL files, uploaded attachments, logs) is stored in the add-on `/data` directory, which survives restarts and updates.

---

## Updating

When a new Solidtime version is available:
1. Update the add-on from the HA Add-on Store
2. The add-on restarts and **Auto-migrate Database** runs the new migrations automatically

---

## Checking Logs

Activation email links (when using the `log` mail driver) appear in the add-on log. Go to **Settings → Add-ons → Solidtime → Log**.

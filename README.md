# Garage S3 Codespace

A GitHub Codespace for running [Garage](https://garagehq.deuxfleurs.fr/) — a lightweight, S3-compatible object store — as a single-node development environment.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/lbrenman/garage-codespace)

---

## Ports

| Port | Service |
|------|---------|
| `3900` | S3 API (AWS SDK / awscli compatible) |
| `3902` | Static website hosting |
| `3903` | Admin HTTP API |

---

## Getting Started

The Codespace automatically installs the Garage binary and starts the server on creation. If you need to restart manually:

```bash
bash start.sh
```

To stop:

```bash
bash stop.sh
```

---

## Using awscli

`awscli` is pre-installed. Load credentials and endpoint config:

```bash
source .awsrc
```

Then use standard S3 commands:

```bash
# List buckets
aws s3 ls

# Upload a file
aws s3 cp myfile.txt s3://my-bucket/myfile.txt

# List objects
aws s3 ls s3://my-bucket

# Download a file
aws s3 cp s3://my-bucket/myfile.txt ./myfile.txt

# Pre-sign a URL (60 seconds)
aws s3 presign s3://my-bucket/myfile.txt --expires-in 60
```

Run the bundled demo script for a quick end-to-end test:

```bash
source .awsrc && bash demo.sh
```

---

## Garage Explorer (Web UI)

A built-in web UI for browsing buckets, uploading/downloading files, and managing objects is available on port `3910`. It starts automatically with `start.sh`.

Open it via the **Ports** tab in VS Code (port 3910) or navigate to `http://localhost:3910` in the Codespace browser.

**Features:**
- View all buckets
- Create and delete buckets
- Browse objects and folders
- Upload files (drag & drop or click)
- Download files
- Delete objects

---

## Connecting External Clients (e.g. iPaaS / Amplify Fusion)

> ⚠️ The GitHub Codespaces public port URL (`*.app.github.dev`) cannot be used directly with S3 SDK clients. GitHub's reverse proxy injects cookies and modifies requests, which breaks AWS Signature V4 validation.

Use **ngrok** to expose port 3900 with a clean tunnel instead.

### Install ngrok

```bash
curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
sudo apt-get update -q && sudo apt-get install -y ngrok
```

### Authenticate

Get your authtoken from https://dashboard.ngrok.com/get-started/your-authtoken (free account works):

```bash
ngrok config add-authtoken YOUR_NGROK_TOKEN
```

### Start the tunnel

```bash
ngrok http 3900
```

ngrok will display a public URL like `https://xxxx-xx-xx-xx-xx.ngrok-free.app`. Use that as the **endpoint URL** in your S3 connector.

### S3 Connector Settings

| Field | Value |
|-------|-------|
| URL / Endpoint | `https://xxxx-xx-xx-xx-xx.ngrok-free.app` |
| Region | `garage` |
| Access Key | *(from `.garage-credentials`)* |
| Secret Key | *(from `.garage-credentials`)* |
| Path Style | `true` (if available) |

> **Note:** The ngrok URL changes each time you restart the tunnel on a free account. Consider a paid ngrok plan or a static domain for persistent demos.

---

## Garage CLI

The `garage` CLI is available for cluster administration:

```bash
GARAGE_CONFIG_FILE=$(pwd)/garage.toml /usr/local/bin/garage status

# Bucket management
GARAGE_CONFIG_FILE=$(pwd)/garage.toml /usr/local/bin/garage bucket list
GARAGE_CONFIG_FILE=$(pwd)/garage.toml /usr/local/bin/garage bucket create new-bucket

# Key management
GARAGE_CONFIG_FILE=$(pwd)/garage.toml /usr/local/bin/garage key list
GARAGE_CONFIG_FILE=$(pwd)/garage.toml /usr/local/bin/garage key info --show-secret <key-id>

# Grant key access to a bucket
GARAGE_CONFIG_FILE=$(pwd)/garage.toml /usr/local/bin/garage bucket allow --read --write --owner new-bucket --key <key-id>
```

---

## Admin API

Open `api.http` in VS Code with the [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) extension.

Update `@adminToken` with the value from `garage.toml` (`admin_token` field), then send requests to:

- `GET /health` — health check (no auth)
- `GET /v2/GetClusterStatus` — cluster status
- `GET /v2/ListBuckets` — list all buckets
- `GET /v2/ListKeys` — list all access keys
- `GET /metrics` — Prometheus metrics (requires `metrics_token`)

Full Admin API reference: https://garagehq.deuxfleurs.fr/documentation/reference-manual/admin-api/

---

## Static Website Hosting

To serve a static site from a bucket:

```bash
# Enable website mode on a bucket
GARAGE_CONFIG_FILE=$(pwd)/garage.toml /usr/local/bin/garage bucket website --allow my-bucket

# Upload your site
source .awsrc
aws s3 sync ./my-site/ s3://my-bucket/
```

The site will be available at `http://localhost:3902` (with the `Host: my-bucket.web.garage.localhost` header).

Full guide: https://garagehq.deuxfleurs.fr/documentation/cookbook/exposing-websites/

---

## Credentials

After first run, credentials are saved to `.garage-credentials` (git-ignored).  
The `garage.toml` config (with secrets) is also git-ignored.

To view your current keys:

```bash
cat .garage-credentials
```

---

## S3 Compatibility

Garage implements the Amazon S3 API. Check the full compatibility matrix:  
https://garagehq.deuxfleurs.fr/documentation/reference-manual/s3-compatibility/

---

## References

- [Garage Docs](https://garagehq.deuxfleurs.fr/documentation/)
- [Quick Start Guide](https://garagehq.deuxfleurs.fr/documentation/quick-start/)
- [Configuration Reference](https://garagehq.deuxfleurs.fr/documentation/reference-manual/configuration/)
- [S3 Compatibility](https://garagehq.deuxfleurs.fr/documentation/reference-manual/s3-compatibility/)
- [ngrok](https://ngrok.com/)

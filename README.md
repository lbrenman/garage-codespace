# Garage S3 Codespace

A GitHub Codespace for running [Garage](https://garagehq.deuxfleurs.fr/) — a lightweight, S3-compatible object store — as a single-node development environment.

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

## Garage CLI

The `garage` CLI is available for cluster administration:

```bash
export GARAGE_CONFIG_FILE=$(pwd)/garage.toml

# Cluster health
garage status

# Bucket management
garage bucket list
garage bucket create new-bucket

# Key management
garage key list
garage key create my-key

# Grant key access to a bucket
garage bucket allow --read --write --owner new-bucket --key my-key
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
export GARAGE_CONFIG_FILE=$(pwd)/garage.toml

# Enable website mode on a bucket
garage bucket website --allow my-bucket

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

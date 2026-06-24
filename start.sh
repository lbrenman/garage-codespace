#!/usr/bin/env bash
set -euo pipefail

GARAGE_TOML="$(pwd)/garage.toml"
AWSRC="$(pwd)/.awsrc"
CREDS_FILE="$(pwd)/.garage-credentials"

# ── Generate garage.toml from template if not already present ──────────────
if [ ! -f "${GARAGE_TOML}" ]; then
  echo "==> Generating garage.toml..."
  sed \
    -e "s|REPLACE_RPC_SECRET|$(openssl rand -hex 32)|g" \
    -e "s|REPLACE_ADMIN_TOKEN|$(openssl rand -base64 32 | tr -d '=+/' | head -c 40)|g" \
    -e "s|REPLACE_METRICS_TOKEN|$(openssl rand -base64 32 | tr -d '=+/' | head -c 40)|g" \
    garage.toml.template > "${GARAGE_TOML}"
  echo "    garage.toml created"
fi

# ── Generate or load S3 credentials ────────────────────────────────────────
if [ ! -f "${CREDS_FILE}" ]; then
  echo "==> Generating S3 credentials..."
  ACCESS_KEY="GK$(openssl rand -hex 16)"
  SECRET_KEY="$(openssl rand -hex 32)"
  cat > "${CREDS_FILE}" <<EOF
GARAGE_DEFAULT_ACCESS_KEY=${ACCESS_KEY}
GARAGE_DEFAULT_SECRET_KEY=${SECRET_KEY}
GARAGE_DEFAULT_BUCKET=my-bucket
EOF
  echo "    Credentials saved to .garage-credentials"
fi

# shellcheck source=/dev/null
source "${CREDS_FILE}"
export GARAGE_DEFAULT_ACCESS_KEY
export GARAGE_DEFAULT_SECRET_KEY
export GARAGE_DEFAULT_BUCKET
export GARAGE_CONFIG_FILE="${GARAGE_TOML}"

# ── Write awsrc helper ──────────────────────────────────────────────────────
cat > "${AWSRC}" <<EOF
export AWS_ENDPOINT_URL='http://localhost:3900'
export AWS_DEFAULT_REGION='garage'
export AWS_ACCESS_KEY_ID='${GARAGE_DEFAULT_ACCESS_KEY}'
export AWS_SECRET_ACCESS_KEY='${GARAGE_DEFAULT_SECRET_KEY}'
export PATH="\$HOME/.local/bin:\$PATH"
EOF

# ── Create data dirs ────────────────────────────────────────────────────────
mkdir -p /tmp/garage-meta /tmp/garage-data

# ── Kill any existing garage process ───────────────────────────────────────
pkill -x garage 2>/dev/null || true
sleep 1

# ── Start Garage in the background ─────────────────────────────────────────
echo ""
echo "==> Starting Garage..."
GARAGE_CONFIG_FILE="${GARAGE_TOML}" \
  nohup garage server --single-node --default-bucket \
  > /tmp/garage.log 2>&1 &

echo "    PID $!"
echo "    Logs: tail -f /tmp/garage.log"

# ── Wait for Garage to be ready ────────────────────────────────────────────
echo ""
echo -n "==> Waiting for Garage to be ready"
for i in $(seq 1 30); do
  if GARAGE_CONFIG_FILE="${GARAGE_TOML}" garage status &>/dev/null; then
    echo " ✓"
    break
  fi
  echo -n "."
  sleep 1
done

echo ""
echo "==> Garage status:"
GARAGE_CONFIG_FILE="${GARAGE_TOML}" garage status

echo ""
echo "==> Bucket list:"
GARAGE_CONFIG_FILE="${GARAGE_TOML}" garage bucket list

echo ""
echo "============================================================"
echo "  Garage is running!"
echo ""
echo "  S3 API  : http://localhost:3900"
echo "  Web     : http://localhost:3902"
echo "  Admin   : http://localhost:3903"
echo ""
echo "  Bucket  : ${GARAGE_DEFAULT_BUCKET}"
echo "  Key ID  : ${GARAGE_DEFAULT_ACCESS_KEY}"
echo "  Secret  : ${GARAGE_DEFAULT_SECRET_KEY}"
echo ""
echo "  To use awscli, run:"
echo "    source .awsrc"
echo "    aws s3 ls"
echo "============================================================"

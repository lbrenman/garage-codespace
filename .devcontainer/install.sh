#!/usr/bin/env bash
set -euo pipefail

GARAGE_VERSION="v2.3.0"
GARAGE_ARCH="x86_64"
GARAGE_BIN="/usr/local/bin/garage"

echo "==> Installing Garage ${GARAGE_VERSION}..."
curl -fsSL \
  "https://garagehq.deuxfleurs.fr/_releases/${GARAGE_VERSION}/${GARAGE_ARCH}-unknown-linux-musl/garage" \
  -o "${GARAGE_BIN}"
chmod +x "${GARAGE_BIN}"
echo "    Garage installed at ${GARAGE_BIN}"
garage --version

echo ""
echo "==> Installing awscli..."
python -m pip install --quiet --user "awscli>=2.13.0"
echo "    awscli installed"
~/.local/bin/aws --version

echo ""
echo "==> Setup complete. Run 'bash start.sh' to start Garage."

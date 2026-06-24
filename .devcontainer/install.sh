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
echo "==> Installing AWS CLI v2..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp/awscliv2
/tmp/awscliv2/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
rm -rf /tmp/awscliv2 /tmp/awscliv2.zip
echo "    awscli installed"
aws --version

echo ""
echo "==> Installing ngrok..."
curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list
apt-get update -q && apt-get install -y ngrok
echo "    ngrok installed"
ngrok version

echo ""
echo "==> Setup complete. Run 'bash start.sh' to start Garage."
echo "    To expose port 3900 externally: ngrok config add-authtoken <token> && ngrok http 3900"

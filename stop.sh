#!/usr/bin/env bash
set -euo pipefail

echo "==> Stopping Garage..."
if pkill -x garage 2>/dev/null; then
  echo "    Garage stopped."
else
  echo "    Garage was not running."
fi

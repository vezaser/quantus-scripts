#!/usr/bin/env bash
set -euo pipefail
cd /root/quantus
TOTAL=$(nproc)
WORKERS=$(( TOTAL>1 ? TOTAL-1 : 1 ))

echo "⛏️ Starting Quantus miner with $WORKERS threads..."
exec ./quantus-miner \
  --port 9833 \
  --workers "${WORKERS}" \
  --engine cpu-montgomery

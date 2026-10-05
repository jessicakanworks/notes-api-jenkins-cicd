#!/usr/bin/env bash
# Runs on the target host: pull the new image, restart, verify health. Rolls back on failure.
set -euo pipefail
cd ~
export REGISTRY TAG
PREV=$(docker inspect --format '{{.Config.Image}}' notes-app 2>/dev/null | sed 's/.*://' || echo "")
docker compose pull app
docker compose up -d
for i in $(seq 1 12); do
  if curl -fs localhost:8000/healthz >/dev/null; then echo "healthy with TAG=$TAG"; exit 0; fi
  sleep 5
done
echo "health check failed, rolling back to $PREV"; TAG=$PREV docker compose up -d; exit 1

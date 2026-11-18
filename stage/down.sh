#!/usr/bin/env bash
# The single KILL step. Tears down all five named containers and the attacklab
# network together. The long-running services use `restart: unless-stopped`, so
# Ctrl-C / closing a terminal will NOT stop them — this is the clean kill.
set -uo pipefail
cd "$(dirname "$0")"

echo "▶ tearing down agent-attack-lab…"
docker compose down --remove-orphans

# Optional full clean (leave OFF so the next ./up.sh is fast):
#   docker compose down --remove-orphans -v --rmi local
echo "✓ lab down. (Images kept for a fast next ./up.sh.)"

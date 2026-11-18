#!/usr/bin/env bash
# Bring the whole agent-attack-lab UP: build, start, warm — well before you're on stage.
# Leaves five NAMED containers running (grouped in Docker Desktop) so the only thing
# left to do at the end is ./down.sh.
set -euo pipefail
cd "$(dirname "$0")"

MODEL="${LLM_MODEL:-qwen2.5:7b-instruct}"
NAMES=(demo-agent-chat demo-collector demo-listener demo-pickle-rce demo-npm-victim)
ok(){ printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad(){ printf '  \033[31m✗\033[0m %s\n' "$1"; }

echo "▶ agent-attack-lab — preflight"

# 1) Docker reachable
docker info >/dev/null 2>&1 && ok "Docker engine reachable" || { bad "Docker not running — start Docker Desktop"; exit 1; }

# 2) NATIVE host Ollama up + the exact model present
if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then ok "host Ollama responding on :11434"
else bad "host Ollama not reachable on :11434 — run 'ollama serve'"; exit 1; fi
_tags="$(curl -s http://localhost:11434/api/tags || true)"
if grep -q "\"$MODEL\"" <<<"$_tags"; then ok "model present: $MODEL"
else bad "model '$MODEL' not pulled — run: ollama pull $MODEL"; exit 1; fi

# 3) Clear any stale same-named containers FIRST, so our own prior run doesn't
#    look like a port conflict and container_name can't collide.
docker rm -f "${NAMES[@]}" >/dev/null 2>&1 || true
ok "cleared stale container names"

# 4) Host ports free (never bind 5000 — AirPlay owns it)
for p in 8080 9000 5001; do
  if lsof -iTCP:"$p" -sTCP:LISTEN -n -P >/dev/null 2>&1; then bad "host port $p is busy — free it or edit docker-compose.yml"; exit 1
  else ok "host port $p free"; fi
done

echo "▶ building images (pre-build so nothing compiles on stage)"
docker compose build

echo "▶ starting the lab (detached)"
docker compose up -d

# Re-arm the npm victim: remove any node_modules so the postinstall hook fires again
docker exec demo-npm-victim sh -c 'rm -rf /app/victim-app/node_modules /app/victim-app/package-lock.json' >/dev/null 2>&1 || true
ok "npm victim armed (node_modules cleared)"

echo "▶ warming the model (keep_alive=-1 so it won't go cold mid-talk)"
curl -s http://localhost:11434/api/generate \
  -d "{\"model\":\"$MODEL\",\"prompt\":\"ok\",\"stream\":false,\"keep_alive\":-1}" >/dev/null 2>&1 \
  && ok "model warm and pinned" || bad "warm-up call failed (non-fatal)"

echo "▶ waiting for health…"
sleep 4
exec ./status.sh

#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# First-time setup on a FRESH machine (Docker Desktop + native Ollama).
# Builds everything the demo lab needs straight from the repo, then starts it.
# Idempotent: safe to re-run. After this, ./up.sh / ./status.sh / ./down.sh.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")"

MODEL="${LLM_MODEL:-qwen2.5:7b-instruct}"
OLLAMA_MODELS_DIR="${OLLAMA_MODELS:-$HOME/.ollama/models}"
BASE_IMAGES=(node:20-alpine python:3.12-slim alpine:3.20)
PNG="../agent-chat/poisoned_onboarding.png"

ok(){ printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad(){ printf '  \033[31m✗\033[0m %s\n' "$1"; }

echo "▶ first-time setup — agent-attack-lab"

# 1) Docker engine
docker info >/dev/null 2>&1 && ok "Docker engine reachable" || { bad "Start Docker Desktop first."; exit 1; }

# 2) Native Ollama + the required model. We do NOT auto-pull: the model must already
#    be present in your local Ollama.
command -v ollama >/dev/null 2>&1 || { bad "Ollama is not installed (https://ollama.com/download)."; exit 1; }
curl -sf http://localhost:11434/api/tags >/dev/null 2>&1 || { bad "Ollama is not serving on :11434 — run 'ollama serve'."; exit 1; }
_models="$(ollama list 2>/dev/null || true)"
if grep -q "$MODEL" <<<"$_models"; then
  ok "model present: $MODEL"
else
  bad "model '$MODEL' is not available in Ollama."
  echo "    Ollama stores models on disk at: $OLLAMA_MODELS_DIR"
  echo "      manifest: $OLLAMA_MODELS_DIR/manifests/registry.ollama.ai/library/qwen2.5/7b-instruct"
  echo "      blobs:    $OLLAMA_MODELS_DIR/blobs/"
  echo "    Make sure the model is in place there (with registry access: 'ollama pull $MODEL'), then re-run."
  exit 1
fi

# 3) Base images (pre-pull so the build and the demo are offline-capable afterward).
for img in "${BASE_IMAGES[@]}"; do
  if docker image inspect "$img" >/dev/null 2>&1; then ok "base image cached: $img"
  else echo "  pulling $img …"; docker pull "$img" >/dev/null && ok "pulled: $img"; fi
done

# 4) Build the lab images from the repo.
echo "▶ building lab images"
docker compose build

# 5) The poisoned image is a committed, frozen asset — regenerate it only if missing
#    (deterministic: same text + bundled font → tesseract reads it identically).
if [ -f "$PNG" ]; then
  ok "poisoned image present: agent-chat/poisoned_onboarding.png"
else
  echo "▶ generating poisoned image (agent-chat/poisoned_onboarding.png)"
  docker run --rm -v "$(cd ../agent-chat && pwd):/out" -w /out agent-attack-lab-agent-chat python author_image.py
  ok "poisoned image generated"
fi

# 6) Start + warm + show readiness (up.sh rebuilds from cache instantly, then warms the model).
echo "▶ starting the lab"
exec ./up.sh

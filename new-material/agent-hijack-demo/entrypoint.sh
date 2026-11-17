#!/bin/sh
# Waits for Ollama, pulls the model if needed, then runs the demo.
# Works both in docker-compose (ollama service) and standalone (host Ollama).
set -e
OLLAMA="${LLM_OLLAMA_URL:-$(printf '%s' "${LLM_BASE_URL:-http://ollama:11434/v1}" | sed 's#/v1/*$##')}"
MODEL="${LLM_MODEL:-qwen2.5:3b}"

echo "[setup] waiting for Ollama at $OLLAMA ..."
until curl -sf "$OLLAMA/api/tags" >/dev/null 2>&1; do sleep 2; done

echo "[setup] ensuring model is present: $MODEL"
echo "[setup] (first run downloads it, this can take a few minutes) ..."
curl -s "$OLLAMA/api/pull" -d "{\"name\":\"$MODEL\"}" | while IFS= read -r line; do
  printf '%s\n' "$line" | grep -o '"status":"[^"]*"' || true
done

echo "[setup] model ready. starting demo."
exec python demo.py

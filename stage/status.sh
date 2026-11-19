#!/usr/bin/env bash
# One glance: is the lab ready? Shows the five named containers and a pass/fail
# readiness checklist, then prints the on-stage run-of-show.
set -u   # NOT pipefail: chk() pipes `curl | grep -q`, and grep -q closing the pipe early
         # would SIGPIPE curl and, under pipefail, show a false ✗.
cd "$(dirname "$0")"
MODEL="${LLM_MODEL:-qwen2.5:7b-instruct}"
ok(){ printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad(){ printf '  \033[31m✗\033[0m %s\n' "$1"; }
chk(){ if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

echo "▶ containers"
docker compose ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || docker compose ps

echo "▶ readiness"
chk "agent-chat   http://localhost:8080"        "curl -sf http://localhost:8080/api/health | grep -qE '\"ok\":[[:space:]]*true'"
chk "collector    http://localhost:9000"        "curl -sf http://localhost:9000/api/loot"
chk "pickle-rce   http://localhost:5001"        "curl -sf http://localhost:5001/"
chk "listener     ncat :4444 (keep-open)"       "docker exec demo-listener pidof ncat"
chk "npm victim   armed (idle, no node_modules)" "docker inspect -f '{{.State.Running}}' demo-npm-victim | grep -q true && ! docker exec demo-npm-victim test -d /app/victim-app/node_modules"
chk "host Ollama  model $MODEL"                 "curl -s http://localhost:11434/api/tags | grep -q \"$MODEL\""

cat <<'EOF'

▶ run-of-show (each act = ONE command)
  A · Agent hijack (headline) ...... open  http://localhost:8080  → drop agent-chat/poisoned_onboarding.jpg
  B · npm supply-chain exfil ....... docker exec demo-npm-victim npm install     (watch http://localhost:9000)
  C · pickle RCE reverse shell ..... regen payload at LISTENER_HOST=demo-listener, POST to http://localhost:5001/load
      catch shells:                  docker logs -f demo-listener   (interact: docker attach demo-listener)
  KILL (end of talk) ............... ./down.sh
EOF

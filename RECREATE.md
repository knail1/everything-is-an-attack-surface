# Recreating the demo lab from scratch

Everything the keynote demos need is built from this repo. On a machine with
**Docker Desktop** and a **native Ollama**, one script builds and starts the whole lab.

## Prerequisites

0. **This repository present on the machine** (clone it, or copy the whole folder).
1. **Docker Desktop** installed and running.
2. **Ollama** installed (<https://ollama.com/download>) and serving on `:11434`
   (`ollama serve`).
3. The model **`qwen2.5:7b-instruct`** present in Ollama. Verify with `ollama list`.

   Ollama keeps models on disk at **`~/.ollama/models`** — a `manifests/` + `blobs/` tree:
   - manifest: `~/.ollama/models/manifests/registry.ollama.ai/library/qwen2.5/7b-instruct`
   - blob data: `~/.ollama/models/blobs/`

   The model must be in place there. (If the machine has registry access, `ollama pull
   qwen2.5:7b-instruct` fetches it.)

> Inference runs on the **native host Ollama** (GPU). Nothing containerizes a model.
> The lab reaches Ollama from containers via `host.docker.internal:11434`.

> **The first `bootstrap.sh` needs internet** for the Docker Hub base images
> (`node:20-alpine`, `python:3.12-slim`, `alpine:3.20`) and the `apt`/`pip` steps in the
> image builds. Only the *model* is exempt (it must be pre-placed). After the first
> successful build, the lab runs offline.

## One command

```bash
cd stage
./bootstrap.sh          # if it's not executable: `bash bootstrap.sh`
```

`bootstrap.sh` checks Docker + the model, pre-pulls the base images
(`node:20-alpine`, `python:3.12-slim`, `alpine:3.20`), builds the lab images,
regenerates the poisoned image if it's missing, then starts everything and prints the
readiness checklist. After the first run, use:

```bash
./up.sh        # start (build is cached) + warm the model
./status.sh    # one-glance readiness + run-of-show
./down.sh      # the single kill step
```

All five containers come up **named and grouped under `agent-attack-lab`** in Docker
Desktop, and host ports are bound to **loopback only**.

## Run-of-show (each act = one command)

| Act | Do this | Watch |
| --- | --- | --- |
| **A — Agent hijack** (headline) | open <http://localhost:8080>, chat, then drop `agent-chat/poisoned_onboarding.png` | OCR → `run_command` → `PWNED … as root` → summary |
| **B — npm supply-chain exfil** | `docker exec demo-npm-victim npm install` | the attacker inbox at <http://localhost:9000> |
| **C — pickle RCE** | regen payload (`LISTENER_HOST=demo-listener`), POST to <http://localhost:5001/load> | `docker logs -f demo-listener` |

Exact commands are in [`docs/final/howto.html`](docs/final/howto.html) (the one-screen
operator run-of-show) and each demo's README.

## Where things live

| Path | What |
| --- | --- |
| `stage/` | `bootstrap.sh`, `up.sh`, `status.sh`, `down.sh`, and `docker-compose.yml` (the `agent-attack-lab` project) |
| `agent-chat/` | the image-drop chat app; **the poisoned image is `agent-chat/poisoned_onboarding.png`** (regenerable with `author_image.py`) |
| `collector/` | the "attacker inbox" web service |
| `shell-demos/npm-supplychain/` | the install-hook harvester + `fixtures/` (planted fake secrets) |
| `shell-demos/pickle-rce/` | the pickle RCE Flask app + `make_payload.py` |
| `docs/final/` | the HTML slide deck and the operator howto |

## Troubleshooting

- **Demo A (agent-chat) shows red / "model unreachable".** The container reaches Ollama
  at `host.docker.internal:11434`, but a fresh native Ollama binds `127.0.0.1` only. Let it
  listen on all interfaces so the container can reach it:
  ```bash
  launchctl setenv OLLAMA_HOST 0.0.0.0   # then restart Ollama, and re-run ./up.sh
  ```
- **Act C needs no host Python.** Generate the pickle payload in a throwaway container
  (so you don't depend on host `python3`):
  ```bash
  cd stage
  PAYLOAD=$(docker run --rm --network attacklab -e LISTENER_HOST=demo-listener \
    -v "$PWD/../shell-demos/pickle-rce:/w:ro" -w /w python:3.12-slim python make_payload.py)
  curl -s -X POST http://localhost:5001/load --data-urlencode "data=$PAYLOAD"
  ```
- The on-disk model path printed by `bootstrap.sh` assumes the default
  `qwen2.5:7b-instruct`; if you override `LLM_MODEL`, adjust the manifest path accordingly.

## Teardown

```bash
cd stage && ./down.sh
```

Removes all five containers and the `attacklab` network. Built images are kept so the
next `./up.sh` is instant; the demos are offline-capable once bootstrapped.

## Safety

Everything connects back to **local** containers (the listener and collector) — realistic
in mechanism, nothing leaves the machine. The npm harvester reads only **planted fake**
secrets and runs only inside the lab container (it fails closed via `DEMO_LAB=1`). Keep
the lab off any network you care about.

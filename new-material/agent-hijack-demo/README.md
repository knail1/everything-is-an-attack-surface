# Agent hijack demo (simple, deterministic, fully contained)

A tiny AI agent is asked to SUMMARIZE a document. The document hides one instruction
telling the agent to run a shell command. The agent runs it. To the model, a command
in the data is just a command.

## Run it, one command (fully contained)

Everything runs in Docker: Ollama, the model, and the agent.

    docker compose up --build

First run downloads the model (cached afterward in a Docker volume), then the agent
reads the poisoned document, runs the command, prints PWNED, and summarizes.

Re-run:          docker compose run --rm agent
Stronger model:  LLM_MODEL=qwen2.5:7b docker compose up --build

## Use the model you already pulled (faster on a Mac)

Native Ollama uses the Mac GPU, so it is faster than the in-container one:

    docker build -t agent-hijack .
    docker run --rm \
      -e LLM_BASE_URL=http://host.docker.internal:11434/v1 \
      -e LLM_MODEL=qwen2.5:7b \
      --add-host=host.docker.internal:host-gateway \
      agent-hijack

Set LLM_MODEL to your tag (see `ollama list`).

## Apple Silicon note

Docker on a Mac runs the in-container Ollama on CPU (no GPU passthrough). Keep the
default `qwen2.5:3b` for speed in the container, or use native Ollama as above.

## Deterministic

temperature 0 and a fixed seed. Same document, same model, same output every run.

## The payload

In `poisoned_doc.txt`, written in the "cognitive override" style from the research
(arXiv:2507.06850). Harmless `echo "PWNED..."` by default. For a real shell, start
`nc -lvnp 4444` and swap that line for a reverse shell.

## Files

    docker-compose.yml  Dockerfile  entrypoint.sh  demo.py  poisoned_doc.txt  requirements.txt

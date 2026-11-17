#!/usr/bin/env bash
# Beat 6, step 1: start a benign victim process and show it in ps.
# Narrate: "the whole system trusts this process list."
set -euo pipefail

# Start a harmless, long-running process with a recognizable name (argv[0]).
setsid bash -c 'exec -a ebpf_victim sleep 100000' >/dev/null 2>&1 &
sleep 1
VICTIM_PID="$(pgrep -n -x ebpf_victim || true)"
echo "$VICTIM_PID" > /tmp/victim.pid

echo "[*] Started victim process 'ebpf_victim' as PID ${VICTIM_PID}."
echo "[*] It is visible to everyone, as you'd expect:"
echo
ps -ef | grep -w ebpf_victim | grep -v grep || echo "   (not found — did it start?)"
echo
echo "    On stage: 'This process is running. You can see it. The system trusts this list.'"

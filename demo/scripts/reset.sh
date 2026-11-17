#!/usr/bin/env bash
# Unload the demo eBPF programs and clean up the victim process.
# Best practice between runs: restore the VM snapshot instead of trusting this.
set -euo pipefail

for f in /tmp/pidhide.loader.pid /tmp/sudoadd.loader.pid; do
  if [[ -f "$f" ]]; then
    sudo kill "$(cat "$f")" 2>/dev/null || true
    rm -f "$f"
  fi
done

if [[ -f /tmp/victim.pid ]]; then
  kill "$(cat /tmp/victim.pid)" 2>/dev/null || true
  rm -f /tmp/victim.pid
fi

# Belt and suspenders: detach any leftover loaders.
sudo pkill -f pidhide 2>/dev/null || true
sudo pkill -f sudoadd 2>/dev/null || true
pkill -x ebpf_victim 2>/dev/null || true

echo "[*] Unloaded demo eBPF programs and cleaned up."
echo "[*] For a guaranteed-clean state before the talk, restore the VM snapshot."

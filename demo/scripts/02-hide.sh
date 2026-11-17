#!/usr/bin/env bash
# Beat 6, step 2: load eBPF pidhide so the victim disappears from ps/top.
# Narrate: "the lie is coming from inside the kernel."
set -euo pipefail

BIN="$(find /opt/ebpf-lab/bad-bpf -type f -executable -name pidhide | head -n1 || true)"
[[ -n "${BIN:-}" ]] || { echo "ERROR: pidhide binary not found. Build bad-bpf first." >&2; exit 1; }
[[ -f /tmp/victim.pid ]] || { echo "ERROR: run 01-show.sh first." >&2; exit 1; }
PID="$(cat /tmp/victim.pid)"

# Flag name can differ by version; confirm once with:  "$BIN" --help
echo "[*] Victim PID $PID is currently visible:"
ps -ef | grep -w ebpf_victim | grep -v grep || true
echo
echo "[*] Loading eBPF pidhide against PID $PID ..."
sudo "$BIN" --pid-to-hide "$PID" >/tmp/pidhide.log 2>&1 &
echo $! > /tmp/pidhide.loader.pid
sleep 2

echo "[*] Look again. ps and top now can't see it:"
if ps -ef | grep -w ebpf_victim | grep -v grep; then
  echo "   (still visible — check /tmp/pidhide.log and the --help flag name)"
else
  echo "   (gone: no ebpf_victim in the process list)"
fi
echo
echo "    On stage: 'Same process, still running. The process list is lying to you.'"
echo "    Loader PID $(cat /tmp/pidhide.loader.pid). Run scripts/reset.sh to unload."

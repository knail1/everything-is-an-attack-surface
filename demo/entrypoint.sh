#!/usr/bin/env bash
# Container entrypoint: build bad-bpf against the host's mounted kernel BTF
# (CO-RE), then hand off to the requested command (a shell by default).
set -euo pipefail

LAB=/opt/ebpf-lab

# CO-RE eBPF needs the host kernel's BTF. In a container that means the host
# must expose it and run-container.sh must mount it in.
if [[ ! -e /sys/kernel/btf/vmlinux ]]; then
  echo "ERROR: /sys/kernel/btf/vmlinux is not present in the container." >&2
  echo "       bad-bpf uses CO-RE and needs the host kernel's BTF." >&2
  echo "       Run on an x86_64 Linux host (CONFIG_DEBUG_INFO_BTF=y) and mount it:" >&2
  echo "         -v /sys/kernel/btf/vmlinux:/sys/kernel/btf/vmlinux:ro" >&2
  echo "       (run-container.sh / docker-compose.yml already do this.)" >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "WARNING: host arch is '$(uname -m)', not x86_64. bad-bpf targets x86_64;" >&2
  echo "         the objects may not build or load. See README.md." >&2
fi

# Build once; the compiled binaries live under bad-bpf/src/.output or bad-bpf/src.
if ! find "$LAB/bad-bpf" -type f -executable -name pidhide | grep -q .; then
  echo "[*] Building bad-bpf against host BTF (first run only) ..."
  make -C "$LAB/bad-bpf/src" >/tmp/bad-bpf-build.log 2>&1 \
    || { echo "ERROR: bad-bpf build failed. See /tmp/bad-bpf-build.log" >&2; tail -n 20 /tmp/bad-bpf-build.log >&2; exit 1; }
  echo "[*] Build complete."
fi

BIN_DIR="$(dirname "$(find "$LAB/bad-bpf" -type f -executable -name pidhide | head -n1)")"
echo "[*] eBPF demo lab ready."
echo "    bad-bpf binaries: ${BIN_DIR:-not found}"
echo "    Demo scripts:     $LAB/scripts/  (01-show, 02-hide, 03-privesc, reset)"
echo "    Low-priv user:    demo / demo   (su - demo)"
echo

exec "$@"

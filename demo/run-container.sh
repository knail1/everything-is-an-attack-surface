#!/usr/bin/env bash
# Build and launch the eBPF demo lab container.
#
# RUN THIS ONLY on a throwaway x86_64 Linux host. The container is privileged and
# shares the host kernel: the eBPF programs it loads affect the HOST globally,
# not just this container. There is no undo short of unloading them (reset.sh) or
# rebooting the host. See README.md and ../SECURITY.md.
set -euo pipefail

IMAGE=ebpf-demo-lab
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This demo runs eBPF against a real Linux kernel. Host is '$(uname -s)'." >&2
  echo "On macOS/Windows, Docker's Linux VM is the wrong arch (Apple Silicon) or" >&2
  echo "lacks BTF. Use a disposable cloud x86_64 Linux host instead." >&2
  exit 1
fi

if [[ ! -e /sys/kernel/btf/vmlinux ]]; then
  echo "Host is missing /sys/kernel/btf/vmlinux (kernel BTF)." >&2
  echo "bad-bpf uses CO-RE and needs it. Use a kernel with CONFIG_DEBUG_INFO_BTF=y." >&2
  exit 1
fi

echo "[*] Building image '$IMAGE' ..."
docker build -t "$IMAGE" "$HERE"

echo "[*] Starting privileged container (shares the host kernel) ..."
exec docker run --rm -it \
  --name ebpf-demo-lab \
  --privileged \
  -v /sys/kernel/btf/vmlinux:/sys/kernel/btf/vmlinux:ro \
  -v /sys/fs/bpf:/sys/fs/bpf:rw \
  -v /sys/kernel/debug:/sys/kernel/debug:rw \
  "$IMAGE" "$@"

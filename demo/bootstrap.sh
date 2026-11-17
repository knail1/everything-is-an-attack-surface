#!/usr/bin/env bash
# Provision an eBPF demo lab on a fresh Ubuntu 22.04 (x86_64) VM.
# Builds bad-bpf (the primary, reliable demo). TripleCross is left optional
# because it is kernel-version sensitive and is better pre-recorded.
#
# Usage:  sudo ./bootstrap.sh
#
# Safety: run this ONLY inside a throwaway VM with no route to any network
# you care about. Everything here is public defensive-research tooling, but
# an eBPF rootkit is still a rootkit.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./bootstrap.sh" >&2
  exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" ]]; then
  echo "WARNING: these eBPF PoCs target x86_64. Detected '$ARCH'." >&2
  echo "         bad-bpf / TripleCross may not build or run on this arch." >&2
fi

export DEBIAN_FRONTEND=noninteractive
echo "[*] Installing build dependencies ..."
apt-get update -y
apt-get install -y \
  build-essential clang llvm libelf-dev libbpf-dev zlib1g-dev libzstd-dev \
  git make pkg-config dwarves "linux-headers-$(uname -r)" || true
# bpftool / perf: try the exact-kernel package, fall back to generic
apt-get install -y "linux-tools-$(uname -r)" || apt-get install -y linux-tools-generic || true

# CO-RE eBPF needs kernel BTF. Warn loudly if it is missing.
if [[ ! -e /sys/kernel/btf/vmlinux ]]; then
  echo "WARNING: /sys/kernel/btf/vmlinux is missing." >&2
  echo "         bad-bpf uses CO-RE and needs kernel BTF. Pick a kernel built with CONFIG_DEBUG_INFO_BTF=y" >&2
  echo "         (Ubuntu 22.04 stock kernels have it)." >&2
fi

# A low-privilege user, so the privilege-escalation demo has a victim account.
if ! id demo >/dev/null 2>&1; then
  echo "[*] Creating low-privilege user 'demo' (password: demo) ..."
  useradd -m -s /bin/bash demo
  echo "demo:demo" | chpasswd
fi

LAB=/opt/ebpf-lab
mkdir -p "$LAB"
cd "$LAB"

echo "[*] Cloning and building bad-bpf (primary demo) ..."
if [[ ! -d bad-bpf ]]; then
  git clone --recurse-submodules https://github.com/pathtofile/bad-bpf.git
fi
cd bad-bpf
git submodule update --init --recursive || true
# The repo builds from src/. Binaries land in src/ (pidhide, sudoadd, ...).
make -C src || { echo "ERROR: bad-bpf build failed. Check clang/libbpf and kernel headers." >&2; exit 1; }
cd "$LAB"

# --- TripleCross (optional; dramatic magic-packet backdoor, fragile) ---
# Uncomment to attempt a build. Expect failures off its target kernel (~5.11).
# Prefer to pre-record this one rather than run it live.
# if [[ ! -d TripleCross ]]; then
#   git clone https://github.com/h3xduck/TripleCross.git
# fi
# ( cd TripleCross && make all ) || echo "TripleCross build failed (kernel mismatch likely). Pre-record instead."

# Install helper scripts shipped alongside this bootstrap, if present.
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "$SRC_DIR/scripts" ]]; then
  install -d "$LAB/scripts"
  install -m 0755 "$SRC_DIR"/scripts/*.sh "$LAB/scripts/"
  echo "[*] Helper scripts installed in $LAB/scripts/"
fi

BADBPF_BIN_DIR="$(dirname "$(find "$LAB/bad-bpf" -type f -executable -name pidhide | head -n1)")"
echo
echo "[*] Done."
echo "    bad-bpf binaries: ${BADBPF_BIN_DIR:-not found}"
echo "    Demo scripts:     $LAB/scripts/   (01-show, 02-hide, 03-privesc, reset)"
echo "    Low-priv user:    demo / demo"
echo
echo "    Next: snapshot the VM now, then rehearse with scripts/01-show.sh."

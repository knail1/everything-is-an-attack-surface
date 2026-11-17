# eBPF demo lab — container image (x86_64).
#
# This image carries the toolchain, the demo scripts, and an unprivileged `demo`
# user. It clones bad-bpf at build time; the eBPF objects are (re)built at
# container start by entrypoint.sh, when the host's kernel BTF is mounted in.
#
# IMPORTANT: a container shares the HOST kernel. Loading these eBPF programs
# affects the host globally, not just this container. Run it only on a throwaway
# x86_64 Linux host with kernel BTF. See README.md.
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y --no-install-recommends \
      build-essential clang llvm libelf-dev libbpf-dev zlib1g-dev libzstd-dev \
      linux-tools-common linux-tools-generic \
      git make pkg-config dwarves ca-certificates sudo procps \
    && rm -rf /var/lib/apt/lists/*

# Unprivileged user used for the privilege-escalation beat of the demo.
RUN useradd -m -s /bin/bash demo && echo 'demo:demo' | chpasswd

WORKDIR /opt/ebpf-lab

# Clone bad-bpf (the reliable primary demo). It is BUILT at runtime by the
# entrypoint, because CO-RE needs the host's /sys/kernel/btf/vmlinux, which is
# only mounted when the container runs.
RUN git clone --depth 1 https://github.com/pathtofile/bad-bpf.git \
    && git -C bad-bpf submodule update --init --recursive

# Demo scripts (01-show / 02-hide / 03-privesc / reset).
COPY scripts/ /opt/ebpf-lab/scripts/
COPY entrypoint.sh /opt/ebpf-lab/entrypoint.sh
RUN chmod +x /opt/ebpf-lab/scripts/*.sh /opt/ebpf-lab/entrypoint.sh

ENTRYPOINT ["/opt/ebpf-lab/entrypoint.sh"]
CMD ["/bin/bash"]

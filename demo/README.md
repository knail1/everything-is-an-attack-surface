# eBPF Demo Lab

A self-contained, resettable environment for the keynote's live demo: a trusted
kernel feature (eBPF) used to make the system lie and to hand over root, with no
CVE involved. Built around **bad-bpf** for reliability. **TripleCross** is noted
as the dramatic-but-fragile alternative to pre-record.

This maps to Beat 6 of the keynote script.

> **Read [`../SECURITY.md`](../SECURITY.md) first.** Everything here is public
> defensive-research tooling, but an eBPF rootkit is still a rootkit. Run it only
> on a throwaway x86_64 Linux host.

## What it shows

1. A normal process, visible in `ps` and `top`.
2. One eBPF program loaded, and the process vanishes from the process list. The
   kernel is now lying to every tool that trusts it.
3. An unprivileged user (`demo`) gains root, while `/etc/sudoers` on disk is
   never touched. No exploit, no CVE. The feature used exactly as designed.

## Requirements (read this before choosing a path)

eBPF rootkits here are **x86_64** and need a **real Linux kernel with BTF**
(`CONFIG_DEBUG_INFO_BTF=y`; `/sys/kernel/btf/vmlinux` must exist). That constraint
drives every option below:

- A **container shares the host kernel.** It works, and it's the fastest path —
  but the eBPF programs it loads affect the **host globally**, not just the
  container. So the container must still run on a **throwaway x86_64 Linux host**.
- **macOS / Windows can't host this directly.** Docker there runs a Linux VM
  that is the wrong architecture (Apple Silicon is arm64) or lacks BTF. Use a
  disposable cloud x86_64 Linux instance.

## Path A — Container (recommended)

Fastest to stand up and reset. Needs Docker on a throwaway x86_64 Linux host.

```bash
cd demo
./run-container.sh          # builds the image, drops you into a root shell in it
# ... or, declaratively:
docker compose run --rm lab
```

`run-container.sh` runs the container `--privileged` and mounts the host's kernel
BTF (`/sys/kernel/btf/vmlinux`), the bpf filesystem (`/sys/fs/bpf`), and
`/sys/kernel/debug`. bad-bpf is compiled on first start by `entrypoint.sh`, using
the mounted host BTF (CO-RE).

Run the demo with two shells into the one container — see
[`run-of-show-container.md`](./run-of-show-container.md):

```bash
# Shell A (loader) is the prompt run-container.sh gives you. Then:
docker exec -it ebpf-demo-lab su - demo   # Shell B, the unprivileged user
```

| Step | Shell | Command | What the room sees |
| --- | --- | --- | --- |
| 1 | A | `/opt/ebpf-lab/scripts/01-show.sh` | `ebpf_victim` is visible in `ps` |
| 2 | A | `/opt/ebpf-lab/scripts/02-hide.sh` | same process, now gone from `ps`/`top` |
| 3 | B | `sudo id` → "not allowed" | `demo` cannot escalate yet |
| 4 | A | `/opt/ebpf-lab/scripts/03-privesc.sh` | loads sudoadd for `demo` |
| 5 | B | `sudo id` → `uid=0(root)` | `demo` is root, `/etc/sudoers` unchanged |
| 6 | A | `/opt/ebpf-lab/scripts/reset.sh` | unload everything |

Reset: `reset.sh`, then `exit` the container (`--rm` tears it down). Because eBPF
loads touch the **host** kernel, the honest clean-slate is to unload (`reset.sh`)
**and** reboot/destroy the throwaway host before the next run.

## Path B — Virtual machine (alternative)

A full VM via `bootstrap.sh`. Slower to build and reset than the container, but
the eBPF blast radius is the VM rather than your host — snapshot/restore is the
honest reset.

### Cloud / bare VM
```bash
# On a fresh Ubuntu 22.04 x86_64 VM:
scp -r demo/ user@vm:~/ebpf-demo-lab/     # or git clone your copy
cd ~/ebpf-demo-lab
sudo ./bootstrap.sh
# Then SNAPSHOT the VM before rehearsing.
```

### Vagrant (x86_64 host)
```bash
cd demo
vagrant up            # boots Ubuntu 22.04 and runs bootstrap.sh
vagrant ssh
# inside the VM, scripts are in /opt/ebpf-lab/scripts
```

VM run-of-show is in [`run-of-show.md`](./run-of-show.md). For a guaranteed-clean
state before you walk on stage, **restore the VM snapshot** rather than trusting
the reset script — eBPF rootkits are built to survive cleanup attempts.

## Note on flag names

The flag names in bad-bpf can vary by version. Confirm once during setup with
`"$BIN" --help` (the scripts use `--pid-to-hide` and `--username`).

## Record the fallback

Live kernel demos fail. Before the talk:

1. Rehearse the full sequence until it is boring.
2. Screen-record it at 1080p, with the terminals large and legible from the back
   of the room. Keep it under 90 seconds.
3. On stage, if anything stalls for more than ~15 seconds, cut to the recording
   and keep narrating. Never debug live.

## The dramatic alternative: TripleCross

TripleCross adds a magic-packet backdoor (one crafted packet opens a shell),
library injection, and execution hijacking. It is the better visual but is
pinned to a narrow kernel range (~5.11) and is fragile live. The build is
commented out in `bootstrap.sh`. Recommendation: **pre-record TripleCross's
magic-packet backdoor** as a bonus clip, and run bad-bpf live.

## Safety and optics

- Everything here is public defensive-research tooling. It is still a rootkit.
- Run only on a throwaway x86_64 Linux host with no route to any network you
  care about. A privileged container's eBPF loads affect that host's kernel.
- Say so out loud on stage: "throwaway host, nothing here touches our network."
- If the conference runs a security review for demos, flag the `bad-bpf` and
  `TripleCross` repos to them in advance.

## Files

```
demo/
  Dockerfile                 # container image: toolchain + demo user + bad-bpf clone
  entrypoint.sh              # builds bad-bpf against mounted host BTF, then a shell
  run-container.sh           # build + run the privileged container (Path A)
  docker-compose.yml         # declarative equivalent of run-container.sh
  run-of-show-container.md   # on-stage cheat sheet for the container path
  bootstrap.sh               # provision an Ubuntu 22.04 x86_64 VM (Path B)
  Vagrantfile                # boot + provision via VirtualBox (x86_64 host)
  run-of-show.md             # on-stage cheat sheet for the VM path
  scripts/
    01-show.sh               # start + show the victim process
    02-hide.sh               # load pidhide, process vanishes
    03-privesc.sh            # load sudoadd, demo user gets root
    reset.sh                 # unload + clean up
```

## Credits

- bad-bpf — github.com/pathtofile/bad-bpf
- TripleCross — github.com/h3xduck/TripleCross
- ebpfkit — github.com/Gui774ume/ebpfkit (Black Hat USA 2021)

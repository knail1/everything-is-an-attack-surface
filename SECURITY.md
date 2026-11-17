# Security notice & disclaimer

This repository supports a conference keynote, **"Everything Is an Attack
Surface,"** about reading software the way an attacker does. The `demo/` directory
contains a **live eBPF rootkit demonstration** for educational, defensive-research
purposes.

## What `demo/` is

- Orchestration scripts and a container/VM setup that drive **bad-bpf**, a public
  defensive-research project (<https://github.com/pathtofile/bad-bpf>).
- It demonstrates, without any CVE or exploit, that the eBPF *feature* can:
  hide a process from `ps`/`top`, and grant an unprivileged user `sudo`/root
  with no change on disk.

## What `demo/` is **not**

- It contains **no exploit binaries and no rootkit source of its own.** The setup
  *clones and builds* bad-bpf from its existing public repository. Nothing here
  discloses a capability that isn't already public in the tools it credits
  (bad-bpf, TripleCross, ebpfkit).

## Ground rules

- **Run only on a throwaway x86_64 Linux host** with no route to any network you
  care about.
- A privileged **container shares the host kernel**: the eBPF programs it loads
  affect the **host globally**, not just the container. Prefer a disposable cloud
  instance; destroy it afterward.
- This material is for **authorized education and defensive research only**. Do
  not run it on systems you do not own or are not authorized to test.
- If your organization or the conference runs a demo security review, flag the
  `bad-bpf` and `TripleCross` repositories to them in advance.

No warranty. Use at your own risk.

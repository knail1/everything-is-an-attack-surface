# Everything Is an Attack Surface

*How hackers read your software, and why AI just made them faster.*

A developer-conference keynote and its supporting material. The thesis: **you read
your code for what it should do; an attacker reads your product for what it also
does that you never intended.** Every feature is an interface, every interface is
an attack surface, and AI now lets attackers read at machine speed. Learn to read
your own software the way they do, and you win.

The talk runs the attacker mindset as its spine, with AI as the accelerant (not
the headline), and ends on a live demo: a trusted kernel feature (eBPF) used to
make a system lie and hand over root — **no CVE involved.**

## Repository layout

| Path | What's there |
| --- | --- |
| [`talk/`](./talk/) | The keynote. **v2 is current** — *They're Coming For You First* script + the agent-hijack demo plan; the v1 script and demo notes are kept alongside as backup. |
| [`docs/final/`](./docs/final/) | **The deliverables:** a self-contained HTML [slide deck](./docs/final/deck.html) and a one-screen HTML [operator run-of-show](./docs/final/howto.html). |
| [`stage/`](./stage/) | **The demo control plane.** One Compose project (`agent-attack-lab`) + `up.sh`/`status.sh`/`down.sh` that start all demos as persistent, named, Docker-Desktop-visible containers — so only the kill step is left on stage. |
| [`agent-chat/`](./agent-chat/) | **The v2 headline demo (chat + image drop).** A browser chat where a dropped image hijacks the agent into a shell — OCR → local LLM → `run_command`. Deterministic. |
| [`agent-hijack-demo/`](./agent-hijack-demo/) | The CLI version of the agent hijack (poisoned document → shell). Simplest to run; good backup. |
| [`shell-demos/`](./shell-demos/) | The "fundamentals": npm supply-chain (now a realistic **secret harvester → local collector**) and pickle-RCE, each container-only. |
| [`collector/`](./collector/) | The "attacker inbox" — a safe, local web service that receives and displays the npm exfil beacon. |
| [`references/`](./references/) | The eight sources behind the talk — seven as archived PDFs, plus the annotated [reading list](./references/reading-list.md). |
| [`demo/`](./demo/) | The eBPF live-demo lab (container-first, VM alternative), from v1. Built around **bad-bpf**. |
| [`SECURITY.md`](./SECURITY.md) | **Read before running anything.** Scope, limits, and ground rules. |

## The demo in one line

A benign process is visible in `ps`; one eBPF program loads and it vanishes; a
second grants an unprivileged user root while `/etc/sudoers` on disk is never
touched. No exploit, no CVE — the feature used exactly as designed. See
[`demo/README.md`](./demo/README.md).

> ⚠️ **The `demo/` lab is a real eBPF rootkit demonstration** built on public
> defensive-research tooling. Run it **only on a throwaway x86_64 Linux host**,
> for authorized education and defensive research. See [`SECURITY.md`](./SECURITY.md).

## The reading list, by beat

- **AI as accelerant (Beat 5):** LLM agents autonomously exploiting one-day CVEs.
- **You are the target / AI tooling as attack surface (Beat 3):** inter-agent
  trust exploitation; package hallucinations and slopsquatting.
- **The demo's context (Beat 6):** eBPF rootkits mapped to MITRE ATT&CK; eBPF's
  own attack surface in the wild.
- **The opening hook (Beat 1):** offensive eBPF, from the 2021 origin research.

Full table with links and local copies: [`references/README.md`](./references/README.md).

## License / use

Educational and defensive-research material supporting a conference talk. The
demo tooling is credited to its upstream authors (bad-bpf, TripleCross, ebpfkit).
Use only where you are authorized to. No warranty.

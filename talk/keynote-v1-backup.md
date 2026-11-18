# Keynote v1 backup: Everything Is an Attack Surface
_How hackers read your software, and why AI just made them faster_

Backup taken 2026-11-17. This is the preserved v1 of the talk. The live doc stays untouched; v2 is a separate document.

## Overview

Thesis: You read your code for what it should do. An attacker reads your product for what it also does that you never intended. Every feature is an interface, every interface is an attack surface, and AI now lets attackers read at machine speed. Learn to read your own software the way they do, and you win.

Working title: Everything Is an Attack Surface. Alternates: They Read Your Code More Carefully Than You Do, and With Friends Like These.

Audience: Internal developer conference. Engineers who build consumer-facing products.

Duration: About 22 minutes of material inside a 20 to 25 minute slot, leaving headroom for a live demo.

## Narrative arc at a glance

| # | Beat | Min | Clock | What it does |
| --- | --- | --- | --- | --- |
| 1 | Hook: a friend turns on you | 2 | 0:00 to 2:00 | Open on a beloved tool weaponized. Earn attention before any thesis. |
| 2 | The reframe | 3 | 2:00 to 5:00 | Hackers are developers with inverted goals. Plant the lens. |
| 3 | You are the target | 4 | 5:00 to 9:00 | Why developers specifically: access, trust, blast radius, soft tooling. |
| 4 | Your product is the weapon | 4 | 9:00 to 13:00 | Supply chain. The code you ship is a trusted delivery vehicle into your customers. |
| 5 | AI as the accelerant | 3 | 13:00 to 16:00 | AI collapses cost and scale. Not a new category, a force multiplier. |
| 6 | Live demo | 5 | 16:00 to 21:00 | Show, do not tell. A trusted feature makes the system lie. |
| 7 | The turn | 2 | 21:00 to 23:00 | Hand them the lens to carry home. Close on two sentences. |

## Full speaker script

**Beat 1: Hook (0:00 to 2:00).** Open on eBPF as a tool developers love, then reveal the 2021 Black Hat offensive-eBPF research (ebpfkit) that turned it into a rootkit. "Same technology. They just read it differently than you did." Tease the live demo.

**Beat 2: The reframe (2:00 to 5:00).** A hacker is a developer with inverted goals. You see a feature, they see an interface. You see an input field, they see a door. You see a dependency that saves a week, they see a way into ten thousand companies. It is a discipline you already have (debugging, reverse-engineering).

**Beat 3: You are the target (5:00 to 9:00).** Developers are the highest-leverage target: prod creds, signing keys, commit access, CI/CD. And the tooling is soft. Slopsquatting: roughly 1 in 5 AI-suggested packages do not exist; the hallucinations recur, so attackers pre-register the names.

**Beat 4: Your product is the weapon (9:00 to 13:00).** The attacker's best delivery vehicle is your product. XZ Utils: a backdoor rated 10/10 that reached nearly every Linux system, placed through two years of patient social engineering by "Jia Tan." When abused, you are the delivery mechanism.

**Beat 5: AI as the accelerant (13:00 to 16:00).** AI did not invent this; it collapsed the cost. Three data points: an AI agent exploited 87% of one-day CVEs on its own; malware now queries an LLM at runtime (PROMPTFLUX, PROMPTSTEAL); one vendor reported an 89% year-over-year jump in AI-enabled adversary attacks. The mindset is the engine, AI is the multiplier.

**Beat 6: Live demo (16:00 to 21:00).** Throwaway VM. Load an eBPF program; the victim process vanishes from ps/top. Then privilege escalation or magic-packet backdoor. No CVE, the feature used as designed.

**Beat 7: The turn (21:00 to 23:00).** Not fear, a habit. Three questions for every feature: What did I assume? What happens at the edge I did not test? If I wanted to abuse this, where would I start? And for every dependency: do I know it is real and what it does? "They are going to read everything you ship. The only question is whether you read it first."

## Slide-by-slide outline

| # | Beat | On-screen text | Visual and delivery note |
| --- | --- | --- | --- |
| 1 | Hook | eBPF | One word. Open here, no title yet. |
| 2 | Hook | Everything Is an Attack Surface | Title reveal after eBPF lands. |
| 3 | Reframe | A hacker is a developer with inverted goals. | Centered. Hold it. |
| 4 | Reframe | You see a feature. They see an interface. | The quotable slide. |
| 5 | You are the target | You hold: prod creds, signing keys, CI/CD, commit access | Four items, one at a time. |
| 6 | You are the target | 1 in 5 AI-suggested packages do not exist | Huge number. |
| 7 | You are the target | Slopsquatting: your AI builds the door, the attacker moves in | One line. |
| 8 | Your product is the weapon | XZ Utils: 2 years of trust, 1 backdoor, severity 10/10 | The 2 years is the point. |
| 9 | Your product is the weapon | When it is abused, you are the delivery mechanism | Black slide. Silence after. |
| 10 | AI accelerant | AI did not invent this. It priced it to zero. | Framing line. |
| 11 | AI accelerant | 87% one-day CVEs auto-exploited / malware that queries an LLM / +89% in a year | Three stats in sequence. |
| 12 | Demo | DEMO | Switch to the VM. |
| 13 | The turn | What did I assume? What is at the edge? Where would I attack? | The three questions. |
| 14 | Close | They will read everything you ship. Read it first. | Final slide. |

## Live demo run-of-show (v1: eBPF)

Primary: bad-bpf (process hide + sudoadd privilege escalation). Dramatic alternative: TripleCross magic-packet backdoor, pre-recorded. Isolated VM, pinned kernel, snapshot reset. Record a 1080p fallback; if it stalls more than ~15 seconds, cut to the recording and keep narrating.

## Sources and references

- eBPF: ebpfkit (github.com/Gui774ume/ebpfkit), TripleCross (github.com/h3xduck/TripleCross), bad-bpf.
- Slopsquatting: Cloud Security Alliance note; Netwrix; Spracklen et al., We Have a Package for You!, USENIX Security 2025.
- XZ Utils (CVE-2024-3094): strobes.co; skbdecoded.
- AI accelerant: arXiv 2404.08144 (87% one-day CVEs); Google GTIG PROMPTFLUX/PROMPTSTEAL; CrowdStrike 89% (Infosecurity Magazine).
- Further reading: arXiv 2402.06664, 2505.12786, 2507.06850, 2609.26254.

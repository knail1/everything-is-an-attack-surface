# Keynote: Everything Is an Attack Surface

*How hackers read your software, and why AI just made them faster*

Nov 16, 2026 · @Omer

## Overview

This talk reframes AI-enabled attacks away from fear and toward a mindset the audience can own: a hacker is a developer with inverted goals, and AI just made that mindset cheap to run at scale.

**Thesis.** You read your code for what it should do. An attacker reads your product for what it also does that you never intended. Every feature is an interface, every interface is an attack surface, and AI now lets attackers read at machine speed. Learn to read your own software the way they do, and you win.

**Working title.** Everything Is an Attack Surface. Alternates: They Read Your Code More Carefully Than You Do, and With Friends Like These (a nod to the 2021 offensive-eBPF research).

**Audience.** Internal developer conference. Engineers who build consumer-facing products. They will tune out a SOC lecture and lean into anything about their own code, tools, and dependencies. Keep it about them.

**Duration.** About 22 minutes of material inside a 20 to 25 minute slot, leaving headroom for a live demo that can run long. Timing cues are in the script.

**How to use this doc.** The narrative arc is the map. The speaker script is written to be spoken, not read. The slide outline maps each beat to slides. The demo run-of-show covers the live portion and its fallback.

## Narrative arc at a glance

Seven beats. The spine is the attacker mindset. AI runs through it as the accelerant, not the headline. The demo is the payoff, so everything before it is setup.

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

Written to be spoken. Timing cues are approximate. Delivery notes are for you, not the slides. Say the numbers slowly; they are the load-bearing moments.

**Beat 1: Hook (0:00 to 2:00)**

I want to start with a tool some of you love. eBPF.

If you run observability, networking, or runtime security on Linux, you probably ship it. It lets you run your own code inside the kernel, safely, to watch everything the system does. It is one of the best things to happen to infrastructure in a decade.

In 2021, researchers gave a talk at Black Hat with a title worth remembering: with friends like eBPF, who needs enemies. They took that same safe, beloved technology and built a [rootkit](https://github.com/Gui774ume/ebpfkit) with it. A backdoor you wake up with a single network packet. Code injected into running processes. A presence that hides itself from the very tools you would use to find it.

Same technology. They just read it differently than you did.

In a few minutes I am going to run a version of that live, on a machine on this stage. But first, how they got there, because the how is the whole point of this talk.

*Delivery: Open cold. No agenda slide. Let eBPF land with the builders in the room before you reveal the title.*

**Beat 2: The reframe (2:00 to 5:00)**

Here is the idea I want you to leave with. A hacker is a developer. Same skills, same instincts, one inverted goal.

You read a spec and ask: how do I make this do what it is supposed to do. They read your product and ask: what else does this do. What did you assume that I can break. What happens at the edge you did not test.

You see a feature. They see an interface. You see an input field. They see a door. You see a dependency that saves you a week. They see a way into ten thousand companies at once.

This is not magic and it is not genius. It is a discipline, and it is one you already have. You debug. You reverse-engineer a weird production incident. You read someone else's code and work out what it really does, not what the comments say it does. That is the same muscle. Attackers just point it at a different target: your product, instead of your bug.

So for the next twenty minutes, wear their lens. Because once you can read your own code the way they do, you stop shipping the doors.

*Delivery: This is the thesis. Slow down. The line they will quote afterward is: you see a feature, they see an interface.*

**Beat 3: You are the target (5:00 to 9:00)**

Now, why you. Why developers specifically.

Because you are the highest-leverage target in the building, and most of you have never been told that.

Think about what a developer holds. Production credentials. Signing keys. Commit access to code that ships to every customer. A pipeline that will build and deploy almost anything you tell it to. Compromise one of you, and an attacker does not get one laptop. They get everything downstream of you.

And here is the part that should make you uncomfortable: your tools are soft. Here is the newest example.

Most of you now code with an AI assistant. It suggests a package, you install it. Researchers found that roughly [one in five](https://labs.cloudsecurityalliance.org/research/csa-research-note-slopsquatting-ai-supply-chain-20260419/) packages suggested by AI coding tools do not exist. The model hallucinated them.

That sounds harmless until you hear the second half. The hallucinations are not random. When researchers re-ran the same prompts, a large share of the invented names came back [every single time](https://netwrix.com/en/resources/blog/slopsquatting/). So an attacker does not guess. They ask the AI what it tends to invent, they register those exact names on npm or PyPI, and they wait. This has a name now. Slopsquatting. The attacker does not even create the opening. Your AI tool creates it, and the attacker just moves in.

You are the target because you are trusted, you are privileged, and right now your toolchain is inventing new attack surface faster than anyone is auditing it.

*Delivery: Land one in five, then pause. Land they do not guess, then pause again before your AI tool creates it.*

**Beat 4: Your product is the weapon (9:00 to 13:00)**

Let me push this one step further, because this is the part that matters most for a company that ships security software to millions of people.

The attacker's best delivery vehicle is not an exploit. It is your product. Your customers already trust it. They already auto-update it. You already signed it.

The cleanest example in recent memory is XZ Utils. XZ is a boring compression library that sits inside nearly every Linux system on earth. In early 2024, someone found a [backdoor](https://strobes.co/research/xz-utils-backdoor-supply-chain-attack-dissected) in it, rated a perfect ten out of ten in severity, that could break SSH authentication and hand over remote access.

But the exploit is not the interesting part. The interesting part is how it got there. It was not a breach. A contributor using the name Jia Tan spent more than [two years](https://skbdecoded.beehiiv.com/p/the-xz-utils-backdoor-a-two-year-con) submitting genuinely useful patches to that project. Participating. Being helpful. Earning trust. Meanwhile other accounts pressured the exhausted volunteer maintainer to hand over more control. By 2023, Jia Tan had commit access. In early 2024, they shipped the backdoor, hidden inside files labeled as corrupted test data.

Two years of patient, legitimate-looking engineering work, to place one weapon inside a tool the whole world trusts. It was caught by accident, by one engineer who noticed SSH was running half a second slow.

Sit in that for a second. We are a company whose products run with deep privilege on our customers' machines. The lesson of XZ is not patch faster. It is that the supply chain into your product, your dependencies, your contributors, your build, is an attack surface with your name on the outside of it. When it is abused, you are not the victim. You are the delivery mechanism.

*Delivery: This is the gut-punch for a security-product org. Do not rush the two-years point. Let you are the delivery mechanism sit in silence.*

**Beat 5: AI as the accelerant (13:00 to 16:00)**

So where does AI actually fit. Not where the headlines put it.

AI did not invent any of this. The attacker mindset is decades old. What AI changed is the cost. Everything I just described used to take a skilled human days, or years. Now a lot of it runs at machine speed, cheaply, at scale.

Three data points, quickly.

One. Researchers gave an AI agent a set of disclosed-but-unpatched vulnerabilities, and it exploited [87 percent](https://arxiv.org/abs/2404.08144) of them on its own. Older and smaller models scored zero. The capability is not evenly distributed, but it is real and it is climbing.

Two. Malware has started phoning an AI at runtime. Google's threat team found a strain that [rewrites its own code every hour](https://www.cybersecuritydive.com/news/ai-powered-malware-google/804760/) using a model to stay ahead of detection, and another, used against Ukrainian targets, that asks a language model what command to run next instead of hard-coding it.

Three. The industry-wide number: one major vendor reported an [89 percent jump](https://www.infosecurity-magazine.com/news/ai-powered-cyberattacks-up/) in attacks by AI-enabled adversaries in a single year.

Put those together and the picture is simple. The adversarial mindset was always the engine. AI is the force multiplier bolted onto it. Cheaper reconnaissance, faster exploit writing, social engineering at infinite scale, and now malware that can think on its feet.

Which is exactly why the defense cannot be a tool you buy. It has to be a lens you carry.

*Delivery: Keep this tight and factual. Resist doom. The point is multiplier, not apocalypse.*

**Beat 6: Live demo (16:00 to 21:00)**

&#91;Switch to the demo machine.\]

Let me make this concrete. This is a throwaway virtual machine. Nothing here touches our network.

I am going to load an eBPF program. To the system, it looks like exactly the kind of observability tool you would be happy to see running. Now watch two things.

First, this process. It is running. You can see it. And now, with one eBPF program loaded, it is gone. ps cannot see it. top cannot see it. The process list the whole system trusts is now lying to you, and the lie is coming from inside the kernel.

Second, watch this. \[Trigger the privilege-escalation step, or the magic-packet backdoor, per the run-of-show.\] I did not exploit a bug. There is no CVE here. I used the feature exactly as designed. I just used it the way an attacker reads it.

That is the entire talk in ninety seconds. A tool you trust, a capability you shipped, read with inverted intent.

*Delivery: Commands and fallback are in the run-of-show. If anything stalls past fifteen seconds, cut to the recording and keep narrating. Never debug live.*

**Beat 7: The turn (21:00 to 23:00)**

So what do I actually want from you when you walk out.

Not fear. Fear is useless and it fades by lunch. I want a habit.

The next time you write a feature, spend thirty seconds reading it the way they would. Ask three questions. What did I assume. What happens at the edge I did not test. If I wanted to abuse this, where would I start.

The next time you add a dependency, or accept the package your AI suggested, ask one more: do I actually know this is real, and do I know what it does.

That is it. You already have the skill. You debug, you reverse-engineer, you read code for what it truly does. All I am asking is that you point that lens at your own work before someone else points it there for you.

Because they are going to read everything you ship. The only question is whether you read it first.

Thank you.

*Delivery: End on the last two sentences. Do not add a summary slide after thank you. Let it land, then step back.*

## Slide-by-slide outline

Keynote slides, not documentation. One idea per slide, almost no text, dark background. The words below are the full on-screen text, not a starting point to expand. You carry the content; the slide just punctuates it.

| # | Beat | On-screen text | Visual and delivery note |
| --- | --- | --- | --- |
| 1 | Hook | eBPF | One word, or a faint kernel diagram. Open here, no title yet. |
| 2 | Hook | Everything Is an Attack Surface | Title reveal, after eBPF has landed. |
| 3 | Reframe | A hacker is a developer with inverted goals. | Plain type, centered. Hold it. |
| 4 | Reframe | You see a feature. They see an interface. | The quotable slide. Let the room photograph it. |
| 5 | You are the target | You hold: prod creds, signing keys, CI/CD, commit access | Four items appearing one at a time. |
| 6 | You are the target | 1 in 5 AI-suggested packages do not exist | Huge number. Nothing else on the slide. |
| 7 | You are the target | Slopsquatting: your AI builds the door, the attacker moves in | One line. Say it, then move on. |
| 8 | Your product is the weapon | XZ Utils: 2 years of trust, 1 backdoor, severity 10/10 | Timeline feel. The 2 years is the point, not the 10. |
| 9 | Your product is the weapon | When it is abused, you are the delivery mechanism | Black slide, white text. Silence after. |
| 10 | AI accelerant | AI did not invent this. It priced it to zero. | Framing line for the three stats. |
| 11 | AI accelerant | 87% one-day CVEs auto-exploited / malware that queries an LLM / +89% in a year | Three stats, revealed in sequence. |
| 12 | Demo | DEMO | Switch to the VM. Slide is just a placeholder so the deck does not show. |
| 13 | The turn | What did I assume? What is at the edge? Where would I attack? | The three questions. The takeaway slide. |
| 14 | Close | They will read everything you ship. Read it first. | Final slide. Leave it up through applause. |

## Live demo run-of-show

**Goal on stage.** Show that a trusted, correctly-functioning kernel feature can make the system lie and can hand over control, with no CVE involved. Two visible moments: a process disappears from ps and top, and an unprivileged action gains root or a crafted packet opens a backdoor.

**Primary demo: bad-bpf.** The most reliable of the public eBPF proofs of concept, because its tools are small and independent rather than one fragile integrated rootkit. Recommended on-stage sequence:

1. Show a normal process in `ps` and `top`. Narrate that the whole system trusts this list.
2. Load the process-hiding program (a getdents64 hook). Re-run `ps`. The process is gone.
3. Run the privilege-escalation tool (sudoadd, using bpf\_probe\_write\_user) and show an unprivileged shell gaining root.
4. One line to close: no exploit, no CVE, the feature used exactly as designed.

**Dramatic alternative: TripleCross.** The magic-packet backdoor is the best visual, since a single crafted packet opens a shell, but it is pinned to specific kernel versions and is more fragile live. Use it pre-recorded as the backup, not live, unless we lock the environment well in advance.

**Environment.** Isolated VM (VirtualBox with Vagrant, or a disposable cloud VM), no route to the conference or corporate network, kernel version pinned to a known-good build for the chosen proof of concept, and a snapshot taken before the talk so it resets in seconds. I will build and hand over this environment as the next deliverable.

**Fallback rule.** Record the full demo in advance at 1080p. If anything stalls on stage for more than about fifteen seconds, cut to the recording and keep narrating over it. Never debug live.

**Safety and optics.** This is defensive and educational, and everything shown is public research. Stay on a throwaway VM, say so out loud, and run nothing networked against anything live. If the conference has a security review for demos, flag the bad-bpf and TripleCross repos to them ahead of time.

## Sources and references

Facts used in the talk, grouped by beat. As-of November 2026.

**eBPF offensive research and demo tooling**

- [ebpfkit](https://github.com/Gui774ume/ebpfkit), the rootkit from the 2021 Black Hat and Defcon talks.
- [TripleCross](https://github.com/h3xduck/TripleCross), the magic-packet backdoor and library-injection rootkit.
- bad-bpf, the modular toolset recommended for the live demo (process hiding, TTY hijack, sudoadd privilege escalation).

**Slopsquatting and the developer supply chain**

- [Slopsquatting: AI Code Hallucinations Fuel Supply Chain Attacks](https://labs.cloudsecurityalliance.org/research/csa-research-note-slopsquatting-ai-supply-chain-20260419/), Cloud Security Alliance, for the roughly one-in-five hallucination rate.
- [Netwrix on slopsquatting](https://netwrix.com/en/resources/blog/slopsquatting/), for the finding that invented package names recur across repeated prompts. The primary study is Spracklen et al., We Have a Package for You!, USENIX Security 2025.

**XZ Utils supply-chain backdoor (CVE-2024-3094)**

- [XZ Utils Backdoor: A Supply Chain Attack Dissected](https://strobes.co/research/xz-utils-backdoor-supply-chain-attack-dissected), for the severity and SSH impact.
- [The XZ Utils backdoor, a two-year con](https://skbdecoded.beehiiv.com/p/the-xz-utils-backdoor-a-two-year-con), for the multi-year social-engineering timeline.

**AI as accelerant**

- [LLM Agents can Autonomously Exploit One-day Vulnerabilities](https://arxiv.org/abs/2404.08144), Fang et al., for the 87 percent figure.
- [AI-based malware makes attacks stealthier and more adaptive](https://www.cybersecuritydive.com/news/ai-powered-malware-google/804760/), on Google's PROMPTFLUX and PROMPTSTEAL findings.
- [AI-powered Cyber-Attacks Up Significantly](https://www.infosecurity-magazine.com/news/ai-powered-cyberattacks-up/), on CrowdStrike's 89 percent year-over-year figure.

**Further ArXiv reading (for depth, not the script)**

- [LLM Agents can Autonomously Hack Websites](https://arxiv.org/abs/2402.06664).
- [Forewarned is Forearmed: LLM-based Agents in Autonomous Cyberattacks](https://arxiv.org/abs/2505.12786), a survey.
- [The Dark Side of LLMs: Agent-based Attacks for Complete Computer Takeover](https://arxiv.org/abs/2507.06850).
- [eBPF Security in the Wild](https://arxiv.org/abs/2609.26254), on real-world eBPF vulnerability classes.

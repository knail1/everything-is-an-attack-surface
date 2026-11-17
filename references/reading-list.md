# Keynote reading list: AI offense, supply chain, eBPF

Nov 16, 2026 · @Omer

Eight sources behind the talk, grouped by beat. Links go to the paper or the original research. The summaries are paraphrased, so click through to confirm the exact IDs, figures, and abstracts before you cite any of them on stage.

| Paper | Source | What it shows, and where to use it |
| --- | --- | --- |
| [LLM Agents can Autonomously Exploit One-day Vulnerabilities](https://arxiv.org/abs/2404.08144) | arXiv 2404.08144 | A GPT-4 agent exploited 87% of a set of disclosed-but-unpatched CVEs on its own; weaker and older models scored near zero. The headline AI-offense statistic. Beat 5. |
| [LLM Agents can Autonomously Hack Websites](https://arxiv.org/abs/2402.06664) | arXiv 2402.06664 | Earlier companion: LLM agents carrying out autonomous web attacks without being told the flaw in advance. Shows the capability curve starting. Background. |
| [Forewarned is Forearmed: LLM-based Agents in Autonomous Cyberattacks](https://arxiv.org/abs/2505.12786) | arXiv 2505.12786 | Survey of how agentic LLMs run reconnaissance, exploitation, and full campaigns. Use for the landscape and your own prep. |
| [The Dark Side of LLMs: Agent-based Attacks for Complete Computer Takeover](https://arxiv.org/abs/2507.06850) | arXiv 2507.06850 | Across 17 models, a vulnerability gradient: direct prompt injection about 41%, RAG backdoor about 53%, inter-agent trust exploitation about 82%. Backs the claim that your AI tooling is attack surface. Beat 3. |
| We Have a Package for You! (package hallucinations) | USENIX Security 2025, Spracklen et al. | The measurement behind slopsquatting: roughly 1 in 5 AI-suggested packages are hallucinated, 205k+ unique fake names, and the hallucinations recur across repeated runs. Beat 3. |
| [eBPF Security in the Wild](https://arxiv.org/abs/2609.26254) | arXiv 2609.26254 | Empirical study cataloguing 514 real eBPF vulnerability instances in Linux 5.10 across runtime, verifier, and JIT. eBPF's own attack surface. Demo context. |
| [Analyzing eBPF Rootkits through the MITRE ATT&CK Framework](https://cylab.be/publications/90/download/2026-analyzing-ebpf-rootkits-through-the-mitre-attck-framework.pdf) | CyLab, 2026 | Maps TripleCross, ebpfkit, bad-bpf, and boopkit to ATT&CK techniques. The single best primer for your demo's context. Beat 6. |
| [ebpfkit: With Friends Like eBPF, Who Needs Enemies?](https://github.com/Gui774ume/ebpfkit) | Black Hat USA 2021 | The origin talk and proof of concept for offensive eBPF. Reference for the opening hook. Beat 1. |

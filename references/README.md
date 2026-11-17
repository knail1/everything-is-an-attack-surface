# References

The eight sources behind the keynote, grouped by beat. Seven are archived here as
PDFs; the eighth (ebpfkit) is a code repository, linked rather than vendored.

Summaries are paraphrased from the reading list — click through and confirm exact
IDs, figures, and abstracts before citing any of them on stage. The original
annotated reading list is in [`reading-list.md`](./reading-list.md).

| # | Source | Local copy | Where it's used |
| --- | --- | --- | --- |
| 1 | [LLM Agents can Autonomously Exploit One-day Vulnerabilities](https://arxiv.org/abs/2404.08144) (arXiv 2404.08144) | [`2404.08144-llm-agents-exploit-one-day-vulns.pdf`](./2404.08144-llm-agents-exploit-one-day-vulns.pdf) | Beat 5 — the headline AI-offense stat (GPT-4 agent exploited 87% of disclosed-but-unpatched CVEs). |
| 2 | [LLM Agents can Autonomously Hack Websites](https://arxiv.org/abs/2402.06664) (arXiv 2402.06664) | [`2402.06664-llm-agents-hack-websites.pdf`](./2402.06664-llm-agents-hack-websites.pdf) | Background — earlier companion; the capability curve starting. |
| 3 | [Forewarned is Forearmed: LLM-based Agents in Autonomous Cyberattacks](https://arxiv.org/abs/2505.12786) (arXiv 2505.12786) | [`2505.12786-forewarned-is-forearmed.pdf`](./2505.12786-forewarned-is-forearmed.pdf) | Landscape / prep — survey of agentic recon, exploitation, full campaigns. |
| 4 | [The Dark Side of LLMs: Agent-based Attacks for Complete Computer Takeover](https://arxiv.org/abs/2507.06850) (arXiv 2507.06850) | [`2507.06850-dark-side-of-llms.pdf`](./2507.06850-dark-side-of-llms.pdf) | Beat 3 — vulnerability gradient across 17 models (direct injection ~41%, RAG backdoor ~53%, inter-agent trust ~82%). |
| 5 | [We Have a Package for You! A Comprehensive Analysis of Package Hallucinations by Code Generating LLMs](https://www.usenix.org/conference/usenixsecurity25/presentation/spracklen) (USENIX Security 2025, Spracklen et al.; preprint [arXiv 2406.10279](https://arxiv.org/abs/2406.10279)) | [`usenix-sec25-spracklen-package-hallucinations.pdf`](./usenix-sec25-spracklen-package-hallucinations.pdf) | Beat 3 — the measurement behind slopsquatting (~1 in 5 AI-suggested packages hallucinated, 205k+ unique fake names, recurring across runs). |
| 6 | [eBPF Security in the Wild](https://arxiv.org/abs/2609.26254) (arXiv 2609.26254) | [`2609.26254-ebpf-security-in-the-wild.pdf`](./2609.26254-ebpf-security-in-the-wild.pdf) | Demo context — 514 real eBPF vulnerability instances in Linux 5.10 (runtime, verifier, JIT). |
| 7 | [Analyzing eBPF Rootkits through the MITRE ATT&CK Framework](https://cylab.be/publications/90/download/2026-analyzing-ebpf-rootkits-through-the-mitre-attck-framework.pdf) (CyLab, 2026) | [`cylab-2026-analyzing-ebpf-rootkits-mitre-attack.pdf`](./cylab-2026-analyzing-ebpf-rootkits-mitre-attack.pdf) | Beat 6 — maps TripleCross, ebpfkit, bad-bpf, boopkit to ATT&CK. The best primer for the demo's context. |
| 8 | [ebpfkit: With Friends Like eBPF, Who Needs Enemies?](https://github.com/Gui774ume/ebpfkit) (Black Hat USA 2021) | — (repository, linked) | Beat 1 — origin talk and PoC for offensive eBPF; the opening hook. |

> Source 8 is an offensive-tooling repository, not a paper, so it is referenced by
> link rather than copied into this repo. See the [upstream repository](https://github.com/Gui774ume/ebpfkit).

# Shell demos for the keynote

Two ready-to-run, container-only exploits that each end in a shell. These are the
two from the ranked set that benefit from custom code. The other three (Flask SSTI,
DVWA command injection, Log4Shell) are public Docker images and need only the
commands in the main write-up.

| Folder | Attack class | One-liner payoff |
| --- | --- | --- |
| `npm-supplychain/` | Supply chain (install hook) | `npm install` of a helper pops a reverse shell |
| `pickle-rce/` | Insecure deserialization | `pickle.loads()` of your blob pops a reverse shell |

Each folder has its own README with the on-stage run-of-show and the one-line fix.

## Safety

- Run only inside a disposable VM or an isolated host. Everything connects back to a
  listener YOU start. On macOS the BSD `nc` has no `-lvnp`; use `ncat -lvk 4444`
  (`brew install nmap`) or the lab's `demo-listener` container (see [`../stage`](../stage)).
- These are intentionally vulnerable teaching artifacts. Do not expose them to any
  network you care about, and do not publish the images.
- Record a fallback capture of each, same rule as the main demo: if it stalls for
  more than ~15 seconds on stage, cut to the recording.

# Demo: malicious npm package (postinstall secret harvester)

The payoff: a developer installs a tiny, innocent-looking helper, and `npm install`
itself harvests their secrets and beacons them to an attacker — **before the victim's
own code ever runs.** This is exactly how the real 2025 npm worms worked: **Shai-Hulud
/ Shai-Hulud 2.0** (Sept & Nov 2025, `postinstall`/`preinstall` hooks that swept the
disk and env for npm/cloud/SSH secrets) and **ethers-provider2** (trojanized `ssh2`,
Mar 2025). The trigger is a `postinstall` hook in `package.json`.

## Two payloads (same trigger)

- **`postinstall.js` (default) — realistic secret harvester + beacon.** Reads *planted
  fake* secrets (`~/.npmrc` token, `~/.aws/credentials`, `~/.ssh/id_rsa`, a wallet seed,
  and `process.env` CI secrets) and HTTP-POSTs them, in a Discord-webhook shape, to a
  **local collector** ("attacker inbox"). Realistic in mechanism, **nothing leaves the
  machine** — every secret is a plant.
- **`postinstall-revshell.js` — reverse shell.** The original variant. To use it, set
  `"postinstall": "node postinstall-revshell.js"` in `left-pad-helper/package.json`.

## Why it fits the keynote

The live payoff for the slopsquatting beat (Beat 2/3): "your AI suggests a package, you
install it" becomes "you install it, and it installs you." The harvester version is the
*realistic* bad-actor behavior, and the inbox lighting up on screen is the gut-punch.

## Run it — use the integrated lab (recommended)

The persistent, named, Docker-Desktop-visible version lives in [`../../stage`](../../stage):

```bash
cd ../../stage && ./up.sh          # starts the collector + victim (+ the other demos)
open http://localhost:9000         # the attacker inbox (empty)
docker exec demo-npm-victim npm install    # fire it — a loot card pops into the inbox
```

Re-run: `docker exec demo-npm-victim rm -rf node_modules` first (so the hook fires again).

## Run it — standalone (harvester → collector)

```bash
# Terminal 1: the attacker inbox
cd shell-demos && docker build -t demo-collector ../collector && \
  docker run --rm -p 9000:8080 --name demo-collector demo-collector   # open http://localhost:9000

# Terminal 2: the victim install (fake secrets planted via fixtures/ + env)
cd npm-supplychain
docker run --rm \
  -e DEMO_LAB=1 \
  -e COLLECTOR_URL=http://host.docker.internal:8080/collect \
  -e GITHUB_TOKEN=ghp_FAKEdemo --add-host=host.docker.internal:host-gateway \
  -v "$PWD/fixtures/npmrc:/root/.npmrc:ro" -v "$PWD:/app" -w /app/victim-app \
  node:20-alpine npm install
```

(The lab wires `COLLECTOR_URL=http://demo-collector:8080/collect` over the compose network —
simpler than the standalone form above.)

## The whole trick (show this slide)

`left-pad-helper/package.json`:
```json
"scripts": { "postinstall": "node postinstall.js" }
```
`npm` runs lifecycle scripts automatically on install. `postinstall.js` does the harvest
and beacon — unobfuscated, so the room can read exactly what real npm malware does.

## The one-line defense

```bash
npm install --ignore-scripts        # per install
npm config set ignore-scripts true  # globally
```
Re-run with `--ignore-scripts`: the install completes, the inbox stays empty. The "and
here's the fix" beat.

## Notes & safety

- All exfil goes to a **local** collector container; nothing leaves the machine. The
  planted secrets are fakes (AWS's documented example keys, the public Hardhat test
  mnemonic, obviously-fake tokens). Keep this on an isolated host anyway.
- For the reverse-shell variant, the listener is `ncat -lvk 4444` (macOS BSD `nc` has no
  `-lvnp`), or the lab's `demo-listener` container.

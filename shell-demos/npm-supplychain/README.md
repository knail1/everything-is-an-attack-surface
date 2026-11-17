# Demo: malicious npm package (postinstall reverse shell)

The payoff: a developer installs a tiny, innocent-looking helper, and `npm install`
itself hands an attacker a shell. The victim's own code never even runs. This is
exactly how the real 2026 axios compromise and the "paperclip2" / "ethers-provider2"
packages worked: a `postinstall` hook in `package.json`.

## Why it fits the keynote

This is the live payoff for the slopsquatting beat (Beat 3). "Your AI suggests a
package, you install it" becomes "you install it, and it installs you." Pure
developer gut-punch, and it runs in a container in 30 seconds.

## Run it

```bash
# Terminal 1 (host): start a listener
nc -lvnp 4444

# Terminal 2 (host): trigger an ordinary-looking install
cd shell-demos/npm-supplychain
docker compose run --rm victim
```

Watch Terminal 1: a shell lands the moment the dependency resolves, before
`node index.js` runs. Type `id` or `hostname` in it to show you're inside the
victim container.

## The whole trick (show this slide)

`left-pad-helper/package.json`:
```json
"scripts": { "postinstall": "node postinstall.js" }
```
`npm` runs lifecycle scripts automatically on install. `postinstall.js` opens the
reverse shell. Nothing is obfuscated so the audience can read it.

## The one-line defense

```bash
npm install --ignore-scripts        # per install
npm config set ignore-scripts true  # globally
```
Show the same `docker compose run` with `--ignore-scripts` added to the command in
`docker-compose.yml`: the install completes, no shell. Great "and here's the fix"
beat.

## Notes

- `host.docker.internal:host-gateway` lets the container reach your host listener on
  Linux and macOS/Windows Docker Desktop. If your Docker can't resolve it, run the
  listener in a sibling container instead, or use the host IP.
- Everything connects back to YOUR listener only. Keep it on an isolated host.

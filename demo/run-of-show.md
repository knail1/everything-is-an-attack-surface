# Demo run-of-show (print this)

Two terminals, large font. Terminal A = loader. Terminal B = logged in as `demo`.

## Pre-flight (before you walk on)
- [ ] VM snapshot restored (clean state)
- [ ] Terminal A: `cd /opt/ebpf-lab/scripts`
- [ ] Terminal B: `su - demo` (password: demo)
- [ ] Recording open in a background tab as fallback
- [ ] Font size readable from the back row

## On stage

**1. Show the process (Terminal A)**
```
sudo ./01-show.sh
```
Say: "This process is running. You can see it. The whole system trusts this list."

**2. Hide it (Terminal A)**
```
sudo ./02-hide.sh
```
Say: "Same process, still running. And now ps can't see it. top can't see it.
The lie is coming from inside the kernel."

**3. Fail to escalate (Terminal B)**
```
sudo id
```
Say: "Right now, demo is a normal user. It can't do this."

**4. Load sudoadd (Terminal A)**
```
sudo ./03-privesc.sh
```
Say: "I'm loading one more eBPF program."

**5. Escalate (Terminal B)**
```
sudo id      # uid=0(root)
```
Say: "I didn't exploit a bug. There's no CVE. I used the feature exactly as
designed. I just read it the way an attacker reads it."

**6. Reset (Terminal A), off-mic or after**
```
sudo ./reset.sh
```

## If it stalls
More than ~15 seconds of trouble: cut to the recording, keep talking, do not
debug live.

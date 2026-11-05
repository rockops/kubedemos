### 1. Inspect the Memory-Consuming Manifest

What happens when a container tries to allocate more memory than its configured `limits.memory`?

Open and inspect the manifest in the editor:

```text
/root/manifests/memory-hog.yaml
```{{open}}

Notice the limit and execution command:
```yaml
      resources:
        requests:
          memory: 50Mi
        limits:
          memory: 100Mi
      command:
        - python3
        - -u
        - -c
        - |
          import time, sys
          print("Starting memory consumer container...", flush=True)
          print("Container limit is set to: 100Mi", flush=True)
          data = []
          for chunk in range(1, 10):
              print(f"Allocating chunk {chunk} (total: {chunk * 20}MB)...", flush=True)
              data.append(b"X" * (20 * 1024 * 1024))
              time.sleep(1)
          print("Finished all allocations.", flush=True)
```

The container limit is **100 MiB**. The Python script progressively allocates memory in chunks of **20 MiB** every second. By the time it attempts chunk 5 or 6, memory usage will exceed 100 MiB!

<br>

### 2. Deploy the Memory Hog

Deploy the manifest:

```bash
kubectl apply -f /root/manifests/memory-hog.yaml
```{{exec target=controlplane}}

<br>

### 3. Stream Container Logs

Watch the memory consumption live:

```bash
kubectl logs -f memory-hog
```{{exec target=controlplane}}

Observe the output until the container stops:
```text
Allocating chunk 1 (total: 20MB)...
Allocating chunk 2 (total: 40MB)...
Allocating chunk 3 (total: 60MB)...
Allocating chunk 4 (total: 80MB)...
Allocating chunk 5 (total: 100MB)...
```

Suddenly, the log stream cuts off with an exit signal!

<br>

### 4. Observe the OOMKill in Real Time

> [!NOTE]
> Look at the **Resource Monitor** pane below!
> Notice the live columns for `memory-hog`:
> - **`LAST_REASON`**: `OOMKilled`
> - **`LAST_EXIT`**: `137`
> - **`RESTARTS`**: increases with each restart attempt
> - **`STATUS`**: enters `CrashLoopBackOff`

<br>

### 5. Inspect the Termination Reason & Exit Code 137

Inspect the pod metadata:

```bash
kubectl describe pod memory-hog
```{{exec target=controlplane}}

Look at the **Last State** section:
```text
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
```

> [!IMPORTANT]
> **Why Exit Code 137?**
> In Unix, when a process is killed by a signal, its exit status is $128 + \text{signal number}$.
> Signal 9 is `SIGKILL` ($128 + 9 = 137$).
> The Linux kernel cgroup subsystem forcibly terminated the process because memory cannot be compressed or throttled.

You can also retrieve the logs from the crashed container instance before the restart:

```bash
kubectl logs memory-hog --previous
```{{exec target=controlplane}}


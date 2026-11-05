### 1. Inspect the Fixed Manifest

To prevent the kernel OOM killer from terminating the container, we adjust `limits.memory` to exceed the maximum expected working set memory of the process.

Open the manifest in the editor:

```text
/root/manifests/memory-fixed.yaml
```{{open}}

Notice the increased limits:
```yaml
      resources:
        requests:
          memory: 100Mi
          cpu: 100m
        limits:
          memory: 300Mi
          cpu: 200m
```

The memory limit is now **300 MiB**, providing ample headroom for the 140 MiB required by our Python script.

<br>

### 2. Replace the Crashing Pod

First, remove the failing `memory-hog` pod:

```bash
kubectl delete pod memory-hog
```{{exec target=controlplane}}

Now deploy the fixed pod:

```bash
kubectl apply -f /root/manifests/memory-fixed.yaml
```{{exec target=controlplane}}

<br>

### 3. Stream Container Logs

Follow the container logs to verify that all memory allocations succeed:

```bash
kubectl logs -f memory-fixed
```{{exec target=controlplane}}

You should see all 7 allocations complete without any interruption:
```text
Allocating chunk 1 (total: 20MB)...
Allocating chunk 2 (total: 40MB)...
Allocating chunk 3 (total: 60MB)...
Allocating chunk 4 (total: 80MB)...
Allocating chunk 5 (total: 100MB)...
Allocating chunk 6 (total: 120MB)...
Allocating chunk 7 (total: 140MB)...
SUCCESS: All 140MB allocated smoothly without triggering OOM!
Holding memory and keeping container alive...
```

<br>

### 4. Verify Stable Pod Health

> [!NOTE]
> Look at the **Resource Monitor** pane below!
> Notice that `memory-fixed` remains healthy:
> - **`STATUS`**: `Running`
> - **`RESTARTS`**: `0`
> - **`LAST_REASON`**: `<none>`

Check the pod status:

```bash
kubectl get pod memory-fixed
```{{exec interrupt}}

<br>

### 5. Clean Up

Clean up the deployed demonstration pods:

```bash
kubectl delete pod memory-fixed rightsized-pod --force
```{{exec target=controlplane}}


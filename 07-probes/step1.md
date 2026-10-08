### 1. Inspect the Pod Manifest with Probes

In this scenario, we configure a Pod with all three probe types using `exec` command actions:
- **Startup Probe**: checks whether `/tmp/started` exists. This file is **not** created by default.
- **Readiness Probe**: checks whether `/tmp/ready` exists. This file is **not** created by default.
- **Liveness Probe**: checks whether `/tmp/live` exists. This file **is created** automatically when the container process starts (`touch /tmp/live`).

Open and inspect the manifest:

```text
/root/manifests/pod-probes.yaml
```{{open}}

Notice the probe definitions:
```yaml
    startupProbe:
      exec:
        command: ["cat", "/tmp/started"]
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 60
    readinessProbe:
      exec:
        command: ["cat", "/tmp/ready"]
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 3
    livenessProbe:
      exec:
        command: ["cat", "/tmp/live"]
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 3
```

<br>

### 2. Deploy the Pod

Create the Pod by applying the manifest:

```bash
kubectl apply -f /root/manifests/pod-probes.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Check the **Pod Monitor** tab on the right running `watch kubectl get pods`.
> Notice that `pod-probes` shows `STATUS: Running`, but `READY: 0/1`.

Inspect the container's `STARTED` and `READY` status:

```bash
kubectl get pod pod-probes -o custom-columns=NAME:.metadata.name,STARTED:.status.containerStatuses[0].started,READY:.status.containerStatuses[0].ready
```{{exec target=controlplane}}

Output:
```text
NAME         STARTED   READY
pod-probes   false     false
```

Inspect detailed conditions and events:

```bash
kubectl describe pod pod-probes | grep Conditions -A 6 && kubectl describe pod pod-probes | grep Events -A 10
```{{exec target=controlplane}}

Observe the following key behaviors:
1. In the **Pod Monitor** tab: `READY` is `0/1`.
2. Under `Conditions`: `Ready` is `False` and `ContainersReady` is `False`.
3. Under `Events`: You will see warnings stating:

```text
Warning  Unhealthy  ...  kubelet  Startup probe failed: cat: can't open '/tmp/started': No such file or directory
```

4. **Key Insight**: Notice there are **no** warnings for the readiness or liveness probes! As long as the startup probe has not succeeded (`STARTED: false`), Kubernetes holds off all other probes to give the application container time to start up.

<br>

### 3. Unlock the Startup Probe

To simulate the application completing its internal startup sequence, create the `/tmp/started` file inside the container:

```bash
kubectl exec pod-probes -- touch /tmp/started
```{{exec target=controlplane}}

Wait for Kubernetes to detect that the startup probe is satisfied:

```bash
kubectl wait --for=jsonpath='{.status.containerStatuses[0].started}'=true pod/pod-probes --timeout=10s
```{{exec target=controlplane}}

Once the condition is met, inspect the container status again:

```bash
kubectl get pod pod-probes -o custom-columns=NAME:.metadata.name,STARTED:.status.containerStatuses[0].started,READY:.status.containerStatuses[0].ready
```{{exec target=controlplane}}

Output:
```text
NAME         STARTED   READY
pod-probes   true      false
```

Notice the key changes:
- **`STARTED` is now `true`**: Kubernetes officially registered that the startup probe succeeded!
- **`READY` is still `false`**: This explains why the **Pod Monitor** tab still shows `0/1 Running`. The startup probe has passed, and Kubernetes is now evaluating readiness, but `/tmp/ready` has not been created yet.

> [!IMPORTANT]
> **Why is there no "Startup probe succeeded" or "Readiness probe failed" event?**
> You might check `kubectl describe pod pod-probes` and wonder why no new event appeared:
> 1. **Probe success is silent**: Kubernetes only generates events when a probe fails, never when it succeeds.
> 2. **Initial readiness probe failures are silent**: Unlike startup and liveness probes (which trigger container restarts when they fail), initial readiness probe failures do not generate warning events on a container that was never ready. This prevents event log spam while a container is starting up.
> 3. **Old events persist in history**: If you run `kubectl describe`, the old `Startup probe failed` event remains in the history for up to an hour, but its repeat counter (`(xN over ...)`) stops increasing.
>
> Therefore, querying **`STARTED: true`** (via `.status.containerStatuses[0].started` or `kubectl wait`) is the definitive, official way in Kubernetes to confirm that the startup probe passed.

<details><summary>Tip</summary>

You can verify the file was created inside the container with:
```bash
kubectl exec pod-probes -- ls -la /tmp
```{{exec target=controlplane}}

</details>

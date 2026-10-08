### 1. Simulate Application Failure by Removing the Liveness File

The **liveness probe** monitors whether your container is healthy. Unlike readiness probes—which simply stop routing traffic—a failing liveness probe signals to Kubernetes that the application is broken (e.g. caught in an unrecoverable deadlock) and **must be restarted**.

Simulate a catastrophic failure by deleting `/tmp/live`:

```bash
kubectl exec pod-probes -- rm /tmp/live
```{{exec target=controlplane}}

<br>

### 2. Observe Kubelet Detecting Failure & Restarting the Container

Wait a few seconds for the liveness probe to fail 3 times (`periodSeconds: 2`, `failureThreshold: 3`), then inspect the Pod events:

```bash
kubectl describe pod pod-probes | grep -A 10 Events:
```{{exec target=controlplane}}

Notice the sequence of events:
```text
Warning  Unhealthy  ...  kubelet  Liveness probe failed: cat: can't open '/tmp/live': No such file or directory
Normal   Killing    ...  kubelet  Container probe-demo failed liveness probe, will be restarted
```

Look at the **Pod Monitor** tab on the right:
- Notice that **`RESTARTS`** increments to **`1`**!
- **`READY`** drops back to **`0/1`**!

> [!IMPORTANT]
> **Why did the Pod become unready after restart?**
> When kubelet restarts the container, it allocates a fresh writable filesystem layer for the container:
> 1. The container's startup command executes again: `touch /tmp/live`.
> 2. Files created dynamically in the previous container lifecycle (`/tmp/started` and `/tmp/ready`) are destroyed!
> 3. The **startup probe activates again** and fails because `/tmp/started` does not exist!
> 4. While the startup probe is failing, it shields liveness and readiness probes once more.

> [!NOTE]
> **Fast restarts with `terminationGracePeriodSeconds: 1`**:
> By default, Kubernetes waits up to 30 seconds (`terminationGracePeriodSeconds: 30`) after sending `SIGTERM` before sending `SIGKILL`. In our manifest, we configured `terminationGracePeriodSeconds: 1`, allowing Kubelet to restart the container almost immediately after detecting the failure without a 30-second delay.

<br>

### 3. Re-unlock Startup and Readiness Probes

Because the container was restarted with a clean filesystem, you must unlock the lifecycle gates again:

**Step A**: Unlock the startup probe:

```bash
kubectl exec pod-probes -- touch /tmp/started
```{{exec target=controlplane}}

Wait for the startup probe to pass:

```bash
kubectl wait --for=jsonpath='{.status.containerStatuses[0].started}'=true pod/pod-probes --timeout=10s
```{{exec target=controlplane}}

**Step B**: Unlock the readiness probe:

```bash
kubectl exec pod-probes -- touch /tmp/ready
```{{exec target=controlplane}}

Wait for the Pod to become Ready:

```bash
kubectl wait --for=condition=Ready pod/pod-probes --timeout=10s
```{{exec target=controlplane}}

Check the **Pod Monitor** tab on the right:
The Pod has fully recovered and is back in the **`1/1` Ready** state with **`1`** restart!

<details><summary>Tip</summary>

Verify that all three files now exist inside the new container instance:
```bash
kubectl exec pod-probes -- ls -l /tmp
```{{exec target=controlplane}}

</details>

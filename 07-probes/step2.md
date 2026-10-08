### 1. Observe the Container Running but Not Ready

Once the startup probe succeeds, Kubernetes immediately begins evaluating both the **liveness** and **readiness** probes:
- The **liveness probe** passes because `/tmp/live` was created when the container started.
- The **readiness probe** fails because `/tmp/ready` does not exist yet!

Look at the **Pod Monitor** tab on the right:
- `STATUS` is **`Running`**, but **`READY` is `0/1`**!

Inspect the Pod conditions:

```bash
kubectl describe pod pod-probes | grep Conditions -A 6
```{{exec target=controlplane}}

Under `Conditions`:
- `PodReadyToStartContainers`: `True`
- `Initialized`: `True`
- `Ready`: `False`
- `ContainersReady`: `False`

> [!NOTE]
> **Why is there no Warning event for the readiness probe?**
> Kubelet does not emit `Unhealthy` warning events for readiness probe failures on newly started containers that have not yet become ready. This prevents spamming the cluster event log while applications complete their startup tasks. The failure of the readiness probe is reflected directly in the condition `Ready: False` and `READY: 0/1`.

> [!NOTE]
> **Why Running $\ne$ Ready?**
> A process can be actively running in memory while initializing database connection pools, warming internal caches, or loading ML models. Kubernetes readiness probes decouple process execution from traffic routing: as long as a Pod is not `Ready`, it is excluded from Service endpoints and will not receive user traffic.

<br>

### 2. Unlock the Readiness Probe

To signal that the application is ready to accept incoming traffic, create the `/tmp/ready` file inside the container:

```bash
kubectl exec pod-probes -- touch /tmp/ready
```{{exec target=controlplane}}

Wait for the Pod to become Ready:

```bash
kubectl wait --for=condition=Ready pod/pod-probes --timeout=10s
```{{exec target=controlplane}}

Check the **Pod Monitor** tab on the right:
- Notice that `READY` flips from **`0/1`** to **`1/1`**!

Verify that the conditions reflect full readiness:

```bash
kubectl describe pod pod-probes | grep -A 6 Conditions:
```{{exec target=controlplane}}

Both `Ready` and `ContainersReady` are now **`True`**! The Pod is now alive, ready, and able to receive traffic.

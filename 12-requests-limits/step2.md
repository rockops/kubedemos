### 1. Inspect the Right-Sized Manifest

To allow the scheduler to place our workload, we configure resource requests that fit within our node's available capacity.

Open and inspect the manifest in the editor:

```text
/root/manifests/rightsized-pod.yaml
```{{open}}

Notice the balanced resource configuration:
```yaml
      resources:
        requests:
          memory: 64Mi
          cpu: 100m
        limits:
          memory: 128Mi
          cpu: 200m
```
- **Requests**: 64 MiB RAM and 100 milli-CPUs (0.1 core) reserved for scheduling.
- **Limits**: Upper ceiling of 128 MiB RAM and 200 milli-CPUs (0.2 core) at runtime.

<br>

### 2. Deploy the Right-Sized Pod

Apply the manifest:

```bash
kubectl apply -f /root/manifests/rightsized-pod.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Resource Monitor** pane below!
> Notice that `rightsized-pod` transitions immediately from `Pending` to **`Running`**.

<br>

### 3. Inspect the Quality of Service (QoS) Class

Kubernetes examines the Pod's resources and automatically assigns a **QoS Class**:

```bash
kubectl get pod rightsized-pod -o jsonpath='{.status.qosClass}'
```{{exec target=controlplane}}

The output is **`Burstable`**:
- **Why?** We specified both requests and limits, but `requests < limits`. The container is allowed to "burst" above its reserved 64Mi up to 128Mi if node capacity permits.
- If requests were strictly equal to limits (`requests == limits`), the QoS class would be **`Guaranteed`**.
- If no requests or limits were specified at all, the QoS class would be **`BestEffort`**.

<br>

### 4. Clean Up the Pending Pod

Delete the unschedulable `oversized-pod` from Step 1:

```bash
kubectl delete pod oversized-pod
```{{exec target=controlplane}}


### 1. Check Node Allocatable Capacity

Before scheduling workloads, the Kubernetes scheduler compares a Pod's `requests` against the **Allocatable** capacity of each node.

Inspect the node's allocatable resources:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,ALLOCATABLE_CPU:.status.allocatable.cpu,ALLOCATABLE_MEM:.status.allocatable.memory
```{{exec target=controlplane}}

You can also view detailed allocations and existing requests:

```bash
kubectl describe node | grep -A 8 "Allocatable:"
```{{exec target=controlplane}}

<br>

### 2. Inspect the Oversized Manifest

Open and inspect the manifest in the editor:

```text
/root/manifests/oversized-pod.yaml
```{{open}}

Notice the resource requests:
```yaml
      resources:
        requests:
          memory: 500Gi
          cpu: 128
```

This Pod requests **500 GiB of RAM** and **128 CPU cores**—resources far exceeding the capacity of this cluster node.

<br>

### 3. Deploy the Oversized Pod

Apply the manifest:

```bash
kubectl apply -f /root/manifests/oversized-pod.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Resource Monitor** pane below!
> Notice that `oversized-pod` appears with:
> - `STATUS: Pending`
> - `REASON: <none>`

<br>

### 4. Diagnose Failed Scheduling

Why is the Pod stuck in `Pending`? Inspect its events:

```bash
kubectl describe pod oversized-pod
```{{exec target=controlplane}}

Look at the **Events** section at the bottom:
```text
Events:
  Type     Reason            From               Message
  ----     ------            ----               -------
  Warning  FailedScheduling  default-scheduler  0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory.
```

> [!IMPORTANT]
> **Key Scheduling Principle**:
> `requests` act as a **hard requirement for the scheduler**. If no single node in the cluster has enough allocatable CPU and memory to satisfy the requested amounts, the Pod will remain in `Pending` indefinitely. The container is never created!


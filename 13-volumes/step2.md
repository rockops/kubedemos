### 1. The PV and PVC Decoupling Model

To provide persistent storage that survives Pod deletion, Kubernetes separates storage provisioning into two concepts:
- **`PersistentVolume` (PV)**: Cluster-level storage resource configured with physical backend details (e.g., local disk, NFS, cloud volume).
- **`PersistentVolumeClaim` (PVC)**: A developer's request for storage specifying required size and access mode, without knowing underlying physical storage details.

<br>

### 2. Inspect the Static PV and PVC Manifests

Open and inspect the PersistentVolume manifest:

```text
/root/manifests/pv-hostpath.yaml
```{{open}}

Notice the properties:
```yaml
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath:
    path: /mnt/data
    type: DirectoryOrCreate
```
- `hostPath`: Maps directly to directory `/mnt/data` on the host node.
- `storageClassName: ""`: Explicitly set to empty so that it matches only static claims.
- `persistentVolumeReclaimPolicy: Retain`: Keeps the underlying host files even if the PVC is deleted.

Now open the PersistentVolumeClaim manifest:

```text
/root/manifests/pvc-static.yaml
```{{open}}

The PVC requests 1 GiB with `ReadWriteOnce` access mode, matching the PV's specifications.

<br>

### 3. Create the PersistentVolume

Create the PV:

```bash
kubectl apply -f /root/manifests/pv-hostpath.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Storage Monitor** pane below under `=== PV ===`!
> Notice `pv-local-hostpath` appears with:
> - `STATUS: Available` (Waiting for a matching PVC to claim it)

<br>

### 4. Create the PersistentVolumeClaim

Now apply the claim:

```bash
kubectl apply -f /root/manifests/pvc-static.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Storage Monitor** pane below!
> Watch both resources transition:
> - `pv-local-hostpath`: `STATUS: Bound` (Claim: `default/pvc-static`)
> - `pvc-static`: `STATUS: Bound` (Volume: `pv-local-hostpath`)

Verify the binding with `kubectl`:

```bash
kubectl get pv,pvc
```{{exec target=controlplane}}

The claim is now bound and ready to be mounted into a Pod!


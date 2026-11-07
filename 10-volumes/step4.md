### 1. Understanding Dynamic Provisioning with Retain

In production environments, simply auto-deleting storage as soon as a claim is deleted (`Delete` policy) can be dangerous—an accidental `helm uninstall` or `kubectl delete pvc` could destroy valuable database files.

To prevent this, production StorageClasses often use **`reclaimPolicy: Retain`**. This enables a two-stage lifecycle:
1. **When the PVC is deleted**: The PV is preserved in `Released` state, and physical data on disk remains completely safe.
2. **When the administrator is ready to delete the storage**: The PV's policy is patched to `Delete`, triggering Kubernetes and the provisioner to erase the physical data and clean up the PV.

<br>

### 2. Create the Retain StorageClass

Inspect the `local-path-retain` StorageClass manifest:

```text
/root/manifests/sc-retain.yaml
```{{open}}

Notice the reclaim policy:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path-retain
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
```

Apply the StorageClass:

```bash
kubectl apply -f /root/manifests/sc-retain.yaml
```{{exec target=controlplane}}

Verify available StorageClasses:

```bash
kubectl get storageclass
```{{exec target=controlplane}}

<br>

### 3. Inspect the Dynamic PVC and Pod Manifests

Open the dynamic PVC manifest in the editor:

```text
/root/manifests/pvc-dynamic.yaml
```{{open}}

Notice that it requests storage from our `local-path-retain` StorageClass:
```yaml
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path-retain
  resources:
    requests:
      storage: 500Mi
```

Now open the Pod manifest:

```text
/root/manifests/pod-dynamic.yaml
```{{open}}

It launches an Nginx web server mounting `dynamic-pvc` at `/usr/share/nginx/html`.

<br>

### 4. Deploy the Dynamic PVC and Pod

Apply both manifests:

```bash
kubectl apply -f /root/manifests/pvc-dynamic.yaml
kubectl apply -f /root/manifests/pod-dynamic.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Keep your eyes on the **Storage Monitor** pane below!
> 1. `dynamic-pvc` is created.
> 2. `pod-dynamic` is scheduled.
> 3. The `local-path` provisioner automatically provisions a new PV.
> 4. Both reach **`Bound`**!
> 5. `pod-dynamic` reaches **`Running (1/1)`**.

<br>

### 5. Write Data to the Dynamic Volume Inside the Pod

Create an HTML file inside the dynamically provisioned volume mounted at `/usr/share/nginx/html`:

```bash
kubectl exec pod-dynamic -- sh -c 'echo "<h1>Protected Dynamic Volume Works!</h1>" > /usr/share/nginx/html/index.html'
```{{exec target=controlplane}}

Fetch the page with `wget` to verify it is served live by Nginx:

```bash
kubectl exec pod-dynamic -- wget -qO- http://localhost:80
```{{exec target=controlplane}}

<br>

### 6. Verify the Physical Directory on the Node

Where is the dynamically provisioned volume physically stored on the host node?

Inspect `/opt/local-path-provisioner/` on the node filesystem directly:

```bash
ls -la /opt/local-path-provisioner/
```{{exec target=controlplane}}

You will see a directory named after your PV and PVC (e.g. `pvc-<uuid>_default_dynamic-pvc`).

Inspect the `index.html` file directly from the host node:

```bash
cat /opt/local-path-provisioner/*_default_dynamic-pvc/index.html
```{{exec target=controlplane}}

<br>

### 7. Stage 1: Delete PVC — PV & Physical Data Remain

Now delete the Pod and the PVC:

```bash
kubectl delete pod pod-dynamic
kubectl delete pvc dynamic-pvc
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Storage Monitor** pane below!
> Notice:
> - `dynamic-pvc` has been deleted.
> - **The PV is NOT deleted!** It transitions to **`STATUS: Released`**.

Now check the node disk:

```bash
ls -la /opt/local-path-provisioner/
cat /opt/local-path-provisioner/*_default_dynamic-pvc/index.html
```{{exec target=controlplane}}

> [!IMPORTANT]
> **Safety Buffer**: The physical folder and files are **still intact on the node disk**!
> Because the policy is `Retain`, an accidental claim deletion does not destroy data.

<br>

### 8. Stage 2: Trigger Physical Deletion on the PV

Now that you have verified the data and are ready to permanently destroy the storage asset, patch the `Released` PV's reclaim policy from `Retain` to `Delete`:

```bash
PV_NAME=$(kubectl get pv -o jsonpath='{.items[0].metadata.name}')
kubectl patch pv $PV_NAME -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
```{{exec target=controlplane}}

Now delete the PV object:

```bash
kubectl delete pv $PV_NAME --ignore-not-found
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Storage Monitor** pane below!
> The PV has been cleanly deleted.

Now check the host directory `/opt/local-path-provisioner/` again:

```bash
ls -la /opt/local-path-provisioner/
```{{exec target=controlplane}}

> [!IMPORTANT]
> **Physical Data Erased!**
> The folder has been **completely wiped from the node disk**!
> Because the PV was patched to `Delete`, Kubernetes invoked the provisioner's `teardown` script (`rm -rf "$VOL_DIR"`), fully reclaiming physical disk space on the node.


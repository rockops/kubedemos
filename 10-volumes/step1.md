### 1. Inspect the Pod with an `emptyDir` Volume

An `emptyDir` volume is initially empty. All containers in the Pod can read and write the same files in the `emptyDir` volume, though that volume can be mounted at the same or different paths in each container.

Open and inspect the manifest in the editor:

```text
/root/manifests/pod-emptydir.yaml
```{{open}}

Notice the specification:
```yaml
  volumes:
    - name: cache-volume
      emptyDir: {}
```

This volume is mounted into two distinct containers:
1. **`writer` container**: writes messages with timestamps into `/shared/data.txt` every 2 seconds.
2. **`reader` container**: reads and logs the content of `/shared/data.txt`.

<br>

### 2. Deploy the Pod

Deploy the manifest:

```bash
kubectl apply -f /root/manifests/pod-emptydir.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Storage Monitor** pane below!
> Notice `shared-emptydir` reaches:
> - `READY: 2/2`
> - `STATUS: Running`

<br>

### 3. Verify Live Data Sharing Between Containers

Check the logs of the `reader` container to see that it is reading data written in real time by the `writer` container:

```bash
kubectl logs shared-emptydir -c reader
```{{exec target=controlplane}}

You can also execute a direct command inside the `reader` container to view the file created by the `writer`:

```bash
kubectl exec shared-emptydir -c reader -- cat /shared/data.txt
```{{exec target=controlplane}}

```bash
kubectl exec shared-emptydir -c writer -- cat /shared/data.txt
```{{exec target=controlplane}}


Both containers operate on the exact same shared directory!

<br>

### 4. Observe Ephemeral Lifecycle

What happens to `emptyDir` when the Pod is deleted?

```bash
kubectl delete pod shared-emptydir --force
```{{exec target=controlplane}}

> [!IMPORTANT]
> **Ephemeral Guarantee**:
> Unlike a container crash (where `emptyDir` data is preserved across container restarts), when a Pod is **deleted**, its `emptyDir` is permanently deleted from the host node. `emptyDir` cannot be used for data persistence across Pod lifecycles.


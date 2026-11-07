### 1. Inspect the Pod Using the PersistentVolumeClaim

Now we mount `pvc-static` into a Pod and write data to it.

Open and inspect the manifest in the editor:

```text
/root/manifests/pod-pvc-static.yaml
```{{open}}

Notice how the Pod references the claim:
```yaml
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: pvc-static
  containers:
    - name: app-writer
      image: busybox:1.36
      imagePullPolicy: IfNotPresent
      command:
        - sh
        - -c
        - |
          echo "Writing persistent data to /mnt/data from inside pod..."
          echo "Hello from Kubernetes Pod $(hostname) at $(date -u)" > /mnt/storage/node-file.txt
          echo "Persistent data written successfully."
          sleep 3600
      volumeMounts:
        - name: persistent-storage
          mountPath: /mnt/storage
```

The container mounts the claim at `/mnt/storage` and writes a message into `/mnt/storage/node-file.txt`.

<br>

### 2. Deploy the Pod

Deploy the manifest:

```bash
kubectl apply -f /root/manifests/pod-pvc-static.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Storage Monitor** pane below!
> Notice `pod-static-storage` reaches `Running (1/1)`.

<br>

### 3. Verify the File from Inside the Container

Check the file contents from within the running container:

```bash
kubectl exec pod-static-storage -- cat /mnt/storage/node-file.txt
```{{exec target=controlplane}}

<br>

### 4. Verify the File on the Host Node Filesystem

Because `pv-local-hostpath` uses `hostPath: { path: /mnt/data }`, the file written inside the container should exist directly on the node's local filesystem at `/mnt/data/`.

Inspect `/mnt/data/node-file.txt` directly on the host node:

```bash
cat /mnt/data/node-file.txt
```{{exec target=controlplane}}

You can also inspect its permissions and inode details:

```bash
ls -la /mnt/data/node-file.txt
```{{exec target=controlplane}}

> [!IMPORTANT]
> The container wrote to its mounted volume path (`/mnt/storage`), and Kubernetes mapped it straight through to the node's `/mnt/data/` filesystem!

<br>

### 5. Verify Persistence After Pod Deletion

Delete the Pod:

```bash
kubectl delete pod pod-static-storage --force
```{{exec target=controlplane}}

Now check the node filesystem again:

```bash
cat /mnt/data/node-file.txt
```{{exec target=controlplane}}

The file is **still intact on the host node**! Unlike `emptyDir`, persistent volumes preserve data across Pod terminations.

<br>

### 6. Delete PV/PVC and Observe Physical Data on Disk

Now delete both the claim and the persistent volume:

```bash
kubectl delete pvc pvc-static && kubectl delete pv pv-local-hostpath
```{{exec target=controlplane}}

Now check the node filesystem again:

```bash
ls -la /mnt/data/node-file.txt
```{{exec target=controlplane}}

> [!IMPORTANT]
> **Static Provisioning Limitation: Data Remains on Disk**
> Even though both the PVC and the PV objects are completely deleted from Kubernetes, the physical file `/mnt/data/node-file.txt` **still exists on the node disk**!
> In static `hostPath` provisioning, Kubernetes does not manage or delete physical host directories for security reasons. The cluster administrator must manually delete the physical data:

Clean up the file from the host node:

```bash
rm -rf /mnt/data/node-file.txt
```{{exec target=controlplane}}


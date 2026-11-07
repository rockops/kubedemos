<br>

### Congratulations! 🎉

You have completed the **Kubernetes Volumes: emptyDir, PersistentVolumes & Dynamic Provisioning** scenario.

---

### Key Concepts Reviewed

1. **`emptyDir` (Pod-Scoped Ephemeral Storage)**:
   - Created when a Pod is assigned to a node; initially empty.
   - Mounted and shared across any number of containers in the same Pod.
   - Data persists across container crashes/restarts within the same Pod, but is **permanently destroyed** when the Pod is deleted.

2. **Decoupled Persistent Storage (PV & PVC)**:
   - **`PersistentVolume` (PV)**: Cluster-level resource representing physical storage provisioned statically by an administrator (or dynamically by a StorageClass).
   - **`PersistentVolumeClaim` (PVC)**: A request for storage by a user that abstracts away physical storage implementation details.
   - Bound 1-to-1 once capacity and access mode criteria match.

3. **`hostPath` Volumes**:
   - Mounts a file or directory from the host node's filesystem into your Pod.
   - Data written by the container directly modifies files on the host node (`/mnt/data`).
   - Persists on the node even after Pod deletion.

4. **Dynamic Provisioning (`StorageClass`)**:
   - Eliminates manual administrator intervention.
   - When a PVC references a `StorageClass`, the storage provisioner automatically creates a matching PV on-the-fly.
   - `volumeBindingMode: WaitForFirstConsumer` delays volume binding until Pod scheduling to guarantee the volume is placed on the node where the Pod will run.

5. **Reclaim Policies & Physical Data Cleanup**:
   - **Static `hostPath` (`Retain`)**: Deleting the PV and PVC leaves the physical folder and files intact on the host node (`/mnt/data`). Kubernetes core intentionally does not delete host files for security reasons; administrators must manually delete the physical data (`rm -rf`).
   - **Dynamic Provisioning (`Retain` $\rightarrow$ `Delete` Pattern)**: Using `reclaimPolicy: Retain` ensures that deleting a PVC does not delete the PV or data (transitions to `Released`). When ready to permanently destroy the storage, patching the `Released` PV to `Delete` triggers the provisioner's teardown script (`rm -rf "$VOL_DIR"`), completely erasing physical files from the node disk.

---

### What's Next?

Explore related scenarios:
- `02-configmaps-secrets`: Inject configuration files and secrets into volume mounts.
- `11-init`: Use `emptyDir` volumes to pass pre-computed artifacts from init containers to app containers.
- `12-requests-limits`: Manage CPU and memory requests and limits for your workloads.


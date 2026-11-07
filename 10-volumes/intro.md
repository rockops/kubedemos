<br>

### Welcome to the Kubernetes Volumes Demo!

Containers are inherently stateless and ephemeral: when a container terminates, all files created inside its writable layer are lost.

Kubernetes solves this with **Volumes**—providing abstraction layers for data sharing, node-level storage, and decoupled cloud/external storage backends.

---

### Key Storage Abstractions Covered

| Storage Type | Lifetime | Scope | Typical Use Case |
|---|---|---|---|
| **`emptyDir`** | Bound to the Pod lifecycle | Single Pod (shared across all its containers) | Scratch space, cache, inter-container pipelines. |
| **Static `PersistentVolume` (`PV`)** | Independent of Pods | Cluster-wide resource | Manual provisioning of local disks (`hostPath`), NFS, or pre-allocated SAN/cloud disks. |
| **`PersistentVolumeClaim` (`PVC`)** | Independent of Pods | Namespace-scoped request for storage | User request specifying capacity, access modes, and storage class. |
| **`StorageClass` (Dynamic)** | Permanent cluster definition | Cluster-wide provisioner | Just-in-time, automated PV creation triggered by PVC creation. |

---

### Terminal Layout

- **Top Pane (`controlplane`)**: Your interactive shell for issuing commands, inspecting files, and interacting with pods.
- **Bottom Pane (`Storage Monitor`)**: Live terminal continuously showing active Pods alongside all `PersistentVolumes` and `PersistentVolumeClaims`!

---

### What You Will Learn

1. **Step 1: Ephemeral Storage with `emptyDir`**: Share files live between two containers in the same Pod. Observe what happens to data when the Pod is deleted.
2. **Step 2: Static PersistentVolume & Claim Binding**: Provision a `hostPath` PV pointing to the node filesystem (`/mnt/data`), create a matching PVC, and watch them bind.
3. **Step 3: Mount `hostPath` & Verify Node Filesystem**: Write a file from inside a Pod container, verify directly on the host node filesystem that the file was created, and verify data persistence after Pod deletion.
4. **Step 4: Dynamic Volume Provisioning**: Use a `StorageClass` (local-path provisioner) to dynamically provision storage without creating PVs manually.

Let's begin!


<br>

### Welcome to the kind (Kubernetes IN Docker) Demo!

**kind** (Kubernetes IN Docker) is a tool for running local Kubernetes clusters using Docker container "nodes". It was primarily designed for testing Kubernetes itself, but is widely used for local development and CI/CD pipelines.

### Key Features of kind:
- **Official Kubernetes SIG Tool**: Maintained by Kubernetes SIG Testing and closely tracks upstream Kubernetes releases.
- **Runs Inside Docker**: Each node is a Docker container running systemd, containerd, and kubelet.
- **Full Conformance**: Implements standard, unmodified Kubernetes components (kubeadm, kubelet, containerd).
- **Multi-Node Support**: Easily supports multi-node clusters (multiple control planes and workers) via simple declarative config.

### In this scenario:
1. The startup script installs and caches `kind`, `kubectl`, and `helm` under `/rockdemo`.
2. A single-node kind cluster named `rockdemo` is automatically provisioned and configured in `~/.kube/config`.
3. You will inspect the kind cluster and nodes, interact with `kubectl`, create namespaces, and verify workload execution.

Click **START** to begin exploring kind!

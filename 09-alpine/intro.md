<br>

### Welcome to the k3d (K3s in Docker) Demo!

**k3d** is a lightweight utility designed to run Rancher's **k3s** (a lightweight, certified Kubernetes distribution) inside Docker containers. It makes running single-node or multi-node Kubernetes clusters on your local machine incredibly fast and resource-efficient.

### Key Features of k3d:
- **Fast Cluster Lifecycle**: Spin up, stop, start, or delete full Kubernetes clusters in seconds.
- **Runs Inside Docker**: Nodes run as isolated Docker containers on the host without modifying system runtimes.
- **Low Footprint**: Leverages k3s under the hood, consuming minimal CPU and RAM (~150MB baseline).
- **Built-in Ingress & Port Mapping**: Exposes ports easily to the host via k3d's built-in proxy/loadbalancer container.

### In this scenario:
1. The startup script installs and caches `k3d`, `kubectl`, and `helm` under `/rockdemo`.
2. A single-node k3d cluster named `rockdemo` is automatically provisioned and configured in `~/.kube/config`.
3. You will inspect the k3d cluster and nodes, interact with `kubectl`, create namespaces, and verify workload execution.

Click **START** to begin exploring k3d!

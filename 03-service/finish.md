<br>

### Congratulations!

You have completed the **Kubernetes Services & Networking** scenario!

### Summary of Key Concepts:
- **Direct Pod Networking**: Explored how every Pod is assigned an IP from the cluster Pod CIDR, and why relying on raw Pod IPs is fragile due to their ephemeral lifecycle.
- **ClusterIP Services**: Created a stable virtual IP and DNS entry inside the cluster that decouples service consumers from dynamic Pod IPs and handles internal Layer 4 routing.
- **NodePort Services**: Exposed internal cluster workloads to external clients by reserving and listening on a dedicated high port (`30000-32767`) across every cluster node.
- **Multi-Replica Load Balancing**: Configured a Deployment with 2 replicas using the Downward API to dynamically report Pod IPs, and witnessed how a Kubernetes Service distributes incoming requests across multiple healthy pod endpoints.
- **LoadBalancer Services**: Provisioned a single, production-grade external entrypoint on standard port 80 via a dedicated external IP, observing how requests are load-balanced across all healthy backend replicas without needing non-standard NodePorts.

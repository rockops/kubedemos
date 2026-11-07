<br>

### Congratulations! 🎉

You have completed the **Kubernetes Resource Requests, Limits & OOMKill** scenario.

---

### Key Concepts Reviewed

1. **Requests (Kube-Scheduler Placement)**:
   - Resource requests reserve capacity for the Pod.
   - If a Pod requests more CPU or memory than any node has unreserved capacity, it stays **`Pending`** with `FailedScheduling`.
   - Requests do not restrict runtime usage; they only guide placement.

2. **Limits (Runtime Enforcement)**:
   - Resource limits specify the maximum ceiling a container can use.
   - **CPU**: A *compressible* resource. When a container exceeds its CPU limit, the kernel CFS (Completely Fair Scheduler) **throttles** its CPU cycles. The process slows down, but is not killed.
   - **Memory**: An *incompressible* resource. When a container exceeds its memory limit, the Linux kernel cgroup controller invokes the **Out-Of-Memory (OOM) Killer**, killing the process with signal 9 (`SIGKILL`, exit code $128 + 9 = 137$).

3. **Quality of Service (QoS) Hierarchy**:
   - **Guaranteed**: Highest priority. `requests == limits` for all containers.
   - **Burstable**: Middle priority. At least one request or limit set, but not equal (`requests < limits`).
   - **BestEffort**: Lowest priority. Neither requests nor limits specified. When a node runs low on resources, `BestEffort` pods are evicted first.

4. **Production Best Practices**:
   - Always set **memory requests equal to memory limits** for predictable memory guarantees and to avoid silent node overcommit.
   - For CPU, setting limits is debated: many teams avoid strict CPU limits to prevent unnecessary throttling during temporary latency spikes.
   - Use the **Vertical Pod Autoscaler (VPA)** in recommendation mode to analyze real-world resource consumption and right-size your Pod specs.

---

### What's Next?

Explore related scenarios in this catalog:
- `11-init`: Understand how init containers calculate effective resource requests.
- `07-probes`: Ensure application readiness and health with startup, readiness, and liveness probes.
- `03-service`: Route traffic reliably to healthy replicas behind Kubernetes Services.


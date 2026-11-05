<br>

### Welcome to the Kubernetes Resource Requests, Limits & OOMKill Demo!

Managing computing resources (CPU and Memory) is essential to running stable, multi-tenant container workloads in Kubernetes. Kubernetes uses two primary mechanisms to manage resources: **Requests** and **Limits**.

---

### Core Concepts: Requests vs. Limits

| Concept | Purpose | Enforced By | Violation Consequence |
|---|---|---|---|
| **`requests`** | Minimum guaranteed resources reserved for the container. | **kube-scheduler** | If no node has enough unreserved capacity, the Pod remains **`Pending`** (`FailedScheduling`). |
| **`limits`** | Maximum ceiling the container can consume at runtime. | **Linux cgroups / kernel** | **CPU**: Throttled (slowed down).<br>**Memory**: Process terminated by kernel **OOMKiller** (`exit code 137`). |

<br>

### Quality of Service (QoS) Classes

Kubernetes automatically classifies every Pod into one of three **QoS classes** based on its requests and limits:
1. **Guaranteed**: Every container in the Pod has both CPU and memory specified, and `requests == limits`. (Highest priority, last to be evicted).
2. **Burstable**: At least one container has CPU or memory request/limit specified, but they are not equal (`requests < limits`).
3. **BestEffort**: Neither requests nor limits are set for any container. (First to be evicted when the node experiences resource pressure).

---

### Terminal Layout

- **Top Pane (`controlplane`)**: Your interactive terminal for executing commands and inspecting pods.
- **Bottom Pane (`Resource Monitor`)**: Live terminal running `watch` to display Pod status, restart count, exit codes, and termination reasons in real time!

---

### What You Will Learn

1. **Step 1: Resource Requests & Failed Scheduling**: Request excessive resources (`500Gi` memory) and observe the scheduler refuse to schedule the Pod (`Pending`).
2. **Step 2: Right-Sizing Requests & QoS Classes**: Adjust requests to match allocatable node capacity, deploy successfully, and inspect the resulting QoS class.
3. **Step 3: Memory Limits & The OOMKiller**: Run an active memory-consuming workload that exceeds its `100Mi` memory limit. Watch the kernel terminate it with `OOMKilled` (`exit code 137`).
4. **Step 4: Resolving OOM & Verifying Stability**: Increase memory limits to accommodate peak allocation and verify that the container runs without restarts.

Let's begin!


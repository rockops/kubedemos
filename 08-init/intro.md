<br>

### Welcome to the Kubernetes Init Containers Demo!

In Kubernetes, a Pod can host application containers as well as **Init Containers**. Init containers are specialized containers that run **to completion before any application containers are started**.

---

### Core Principles of Init Containers

1. **Strict Sequential Execution**:
   If a Pod defines multiple init containers, Kubernetes executes them **one at a time, strictly in order**. Each init container must run to completion and exit successfully (`exit code 0`) before the next init container is started.

2. **Main Application Gating**:
   Application containers do **not** run in parallel with init containers. The `kubelet` waits until **all** init containers have completed successfully before creating and launching the primary application containers. While init containers run, the Pod status displays `Init:0/N` or `Init:1/N`, and app containers remain in `Waiting: PodInitializing`.

3. **Tool Separation & Image Slimming**:
   Init containers can use different container images with setup tools (`curl`, `git`, `nc`, `sed`, build scripts) that are absent from minimal production images, reducing the attack surface of your application containers.

4. **Shared File Storage**:
   Init containers can write data, configurations, or database migration artifacts into shared volumes (such as `emptyDir`), which the application container mounts and reads once started.

5. **Failure Handling**:
   If an init container fails (`exit non-zero`), Kubernetes restarts the Pod (according to its `restartPolicy`) and re-executes the init containers from the beginning. The application containers are **never started**, protecting your system from corrupted or uninitialized state.

---

### Layout of this Demo

Take a look at the two terminal panes on the right:
- **Top Pane (`controlplane`)**: Your primary interactive shell for running commands.
- **Bottom Pane (`Pod Monitor`)**: Continuously monitors the live state and lifecycle transitions of all pods in real time via `watch kubectl get pods -o wide`.

---

### What You Will Learn

1. **Step 1: Service Dependency Gating & Execution Order**: Deploy a web pod that pauses in `Init:0/1` while waiting for a database service to exist. Verify that the main container has not started.
2. **Step 2: Unblocking Dependencies & State Transitions**: Create the required backend service and watch the Pod transition from `Init:0/1` $\rightarrow$ `PodInitializing` $\rightarrow$ `Running 1/1`.
3. **Step 3: Multi-Stage Pipeline with Shared Volumes**: Chain multiple init containers that sequentially gather system info, render an HTML page into an `emptyDir` volume, and let Nginx serve it.
4. **Step 4: Failure Semantics & CrashLoopBackOff**: Observe how a failed init container halts the Pod lifecycle in `Init:Error` and prevents the application container from ever launching.

Let's begin!


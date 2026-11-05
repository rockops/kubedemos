<br>

### Congratulations! 🎉

You have completed the **Kubernetes Init Containers Lifecycle** scenario.

---

### Key Concepts Reviewed

1. **Strict Execution Order**:
   - Init containers always execute **before** any application containers.
   - When multiple init containers are defined, they execute **sequentially** in the order they appear in the Pod specification.
   - Each init container must terminate with **exit code `0`** before the next container starts.

2. **Application Gating**:
   - The primary application containers remain in `Waiting: PodInitializing` until all init containers succeed.
   - This prevents applications from receiving traffic or executing logic in an uninitialized environment.

3. **Data Sharing via Volumes**:
   - Init containers and application containers can share files through standard volumes like `emptyDir`.
   - Setup tasks (e.g. schema migration, downloading assets, generating configurations) can run in separate init containers using utility images, keeping production application images minimal, slim, and secure.

4. **Failure Handling**:
   - If an init container fails (exit code $\neq 0$), Kubernetes triggers a restart following the Pod's `restartPolicy`.
   - The Pod enters `Init:Error` and `Init:CrashLoopBackOff`.
   - Application containers are **never executed** during an init container failure.

5. **Resource Calculation Rule (Pro Tip)**:
   - In Kubernetes, the Pod's effective resource request is:
     $$\max\left(\sum \text{requests of app containers},\ \max \text{request of any init container}\right)$$
   - This ensures init containers have enough CPU and memory during startup without over-allocating cluster capacity during steady-state runtime.

---

### What's Next?

Check out other scenarios in this collection:
- `07-probes`: Master Pod Startup, Readiness, and Liveness probes.
- `02-configmaps-secrets`: Externalize configurations and manage credentials.
- `03-service`: Connect microservices through ClusterIP, NodePort, and DNS resolution.


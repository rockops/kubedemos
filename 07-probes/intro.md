<br>

### Welcome to the Kubernetes Probes Lifecycle Demo!

Health checks are critical for running reliable, highly available containerized workloads. Kubernetes provides three distinct probe mechanisms to monitor container health and control lifecycle events:

- **Startup Probe (`startupProbe`)**:
  Determines whether the application within the container has finished its initialization. Crucially, **all readiness and liveness checks are disabled** until the startup probe succeeds. This prevents slow-starting legacy apps or cache-warming workloads from being prematurely terminated by liveness probes.

- **Readiness Probe (`readinessProbe`)**:
  Determines whether the container is ready to serve incoming network traffic. If a readiness probe fails, Kubernetes stops forwarding traffic from Services and Ingress to the Pod without restarting the container.

- **Liveness Probe (`livenessProbe`)**:
  Determines whether the container is still running and healthy. If a liveness probe fails, the `kubelet` automatically kills the container and initiates a restart according to the Pod's `restartPolicy`.

---

### What You Will Learn

In this hands-on scenario, you will observe the complete probe lifecycle in action:
1. **Startup Probe Gating**: Deploy a Pod with all three probes configured. Observe that startup probe failure blocks container readiness and holds off liveness/readiness evaluations, then unlock it interactively.
2. **Readiness Probe & Traffic Gating**: Observe that the container is `Running` but `0/1 READY` while waiting for the readiness probe, then unlock it to bring the Pod to full operational readiness.
3. **Liveness Probe Self-Healing & Reset Lifecycle**: Simulate a fatal application failure by removing the liveness marker. Watch kubelet detect the failure, restart the container, and observe how the entire probe cycle safely resets.
4. **HTTP Probes & Service Gating**: Deploy an HTTP application with `/health` and `/ready` endpoints fronted by a Service. Observe how unready pods are excluded from Service endpoints and protected with zero container restarts.

Let's begin!

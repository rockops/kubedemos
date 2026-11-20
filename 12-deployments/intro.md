<br>

### Welcome to the Kubernetes Deployments & Zero-Downtime Rollouts Demo!

In production, applications must be updated continuously with new features, bug fixes, and security patches without causing downtime for end users.

A **Kubernetes Deployment** provides declarative updates for Pods and ReplicaSets. Instead of manually restarting containers, you declare the desired state, and the Deployment controller orchestrates a smooth, gradual transition from the old version to the new version.

```
                    ┌─────────────────────────┐
                    │   Deployment: webapp    │
                    └────────────┬────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 ▼                               ▼
    ┌─────────────────────────┐     ┌─────────────────────────┐
    │  ReplicaSet (v1: Old)   │     │  ReplicaSet (v2: New)   │
    │   desired: 0 (scaled)   │     │   desired: 3 (active)   │
    └────────────┬────────────┘     └────────────┬────────────┘
                 │                               │
           (Terminated)            ┌─────────────┼─────────────┐
                                   ▼             ▼             ▼
                               [ Pod 1 ]     [ Pod 2 ]     [ Pod 3 ]
```

---

### What You Will Learn

1. **Deployment Architecture & Hierarchy**: Deploy a 3-replica web application and discover the 3-tier ownership chain (`Deployment` $\rightarrow$ `ReplicaSet` $\rightarrow$ `Pods`).
2. **Zero-Downtime Rolling Updates**: Master the rolling update algorithm using `maxSurge` and `maxUnavailable` to update the application while streaming traffic with zero dropped requests.
3. **Diagnosing a Stalled Rollout**: Trigger an update with a broken image tag, observe how Kubernetes safely pauses the rollout, and verify that the running application remains 100% available.
4. **Rollout History & Undo**: Inspect the deployment revision history with change causes and execute an instant rollback using `kubectl rollout undo`.
5. **Pausing, Resuming & Batching Updates**: Pause an active deployment to stage multiple atomic configuration changes before triggering a single, unified rollout.

> [!TIP]
> **3-Window Workspace Layout**:
> - **Top Window (`controlplane`)**: Primary terminal to execute `kubectl` commands.
> - **Bottom-Left Window (`Rollout Monitor`)**: Live `watch` tracking Deployments, ReplicaSets, and Pods in real time.
> - **Bottom-Right Window (`Live Traffic Stream`)**: Continuous HTTP traffic loop streaming requests to verify zero downtime live!

Click **Start** to begin!


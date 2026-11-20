<br>

### Congratulations!

You have completed the **Kubernetes Deployments & Zero-Downtime Rollouts** scenario!

---

### Key Concepts Mastered

```
[ User Request ]
       │
       ▼
 [ webapp-service ] (ClusterIP)
       │
       ├─► 100% traffic during rollout with maxUnavailable: 0
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│                     Deployment: webapp                      │
│                (strategy: RollingUpdate)                    │
└──────────────────────────────┬──────────────────────────────┘
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
┌────────────────────────┐            ┌────────────────────────┐
│ ReplicaSet (v1 / Old)  │            │ ReplicaSet (v2 / New)  │
│      desired: 0        │            │      desired: 3        │
│ (Retained for rollback)│            │        (Active)        │
└────────────────────────┘            └───────────┬────────────┘
                                                  ▼
                                      [ Pod 1 ] [ Pod 2 ] [ Pod 3 ]
```

1. **3-Tier Ownership Model**:
   - `Deployment`: Owns declarative rollout strategy and revision history.
   - `ReplicaSet`: Owns the exact pod count and scales up/down.
   - `Pod`: Hosts the application containers.

2. **Zero-Downtime Rolling Updates**:
   - Tuned `maxSurge: 1` and `maxUnavailable: 0` to guarantee that no pod is terminated until its replacement passes readiness checks.
   - Verified 100% continuous uptime during live version transitions.

3. **Protective Stalling on Failures**:
   - Witnessed how a broken image tag (`nginx:broken-v3-tag-error`) triggers a stalled rollout without impacting the running production workload.

4. **Rollout Audit History & Instant Rollbacks**:
   - Documented releases with `kubernetes.io/change-cause`.
   - Used `kubectl rollout undo` to recover from a failed release in seconds.

5. **Paused Rollouts & Change Batching**:
   - Used `kubectl rollout pause` and `kubectl rollout resume` to bundle multiple resource and configuration modifications into a single, clean rollout.

---

### Production Best Practices
- **Always configure Readiness Probes**: Without a readiness probe, Kubernetes considers a container Ready immediately upon process start, defeating the purpose of `maxUnavailable: 0`.
- **Set `revisionHistoryLimit`**: Configure `spec.revisionHistoryLimit: 5` (default: 10) in high-frequency CI/CD environments to avoid storing excessive ReplicaSets in `etcd`.
- **Prefer Declarative GitOps**: Store deployment manifests in version control and use automated CI/CD tools to trigger rollouts deterministically.


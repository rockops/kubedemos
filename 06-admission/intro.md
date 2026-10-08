# Kubernetes Admission Controllers: Mutating & Validating Webhooks

In Kubernetes, **Admission Controllers** are plugins that intercept requests to the Kubernetes API server after authentication and authorization (RBAC), but *before* objects are committed to `etcd`.

```
                    ┌──────────────────────────────────────────────┐
                    │            Kubernetes API Server             │
                    └──────────────────────────────────────────────┘
                                           │
                                1. AuthN & AuthZ (RBAC)
                                           │
                                           ▼
                      ┌──────────────────────────────────────────┐
                      │    Mutating Admission Controllers        │ ◄─── (Step 1: Sidecar Injector)
                      └──────────────────────────────────────────┘
                                           │
                               2. Object Schema Validation
                                           │
                                           ▼
                      ┌──────────────────────────────────────────┐
                      │    Validating Admission Controllers      │ ◄─── (Step 2: Replica Policy)
                      └──────────────────────────────────────────┘
                                           │
                               3. Persist to etcd
                                           ▼
                                       [ etcd ]
```

---

### What You Will Build & Learn

In this scenario, you will deploy a unified in-cluster webhook server and explore both admission controller types:

1. **Step 1 — Mutating Admission Controller (Sidecar Injection)**:
   - Intercepts Pod creation requests.
   - Dynamically patches Pods in labeled namespaces with a **heartbeat sidecar container** (`busybox`, printing every 5 seconds).
   - Leaves workloads in unlabeled namespaces untouched.

2. **Step 2 — Validating Admission Controller (Deployment Policy Enforcement)**:
   - Intercepts Deployment creation and update requests.
   - Enforces an infrastructure policy: **Deployments cannot exceed 5 replicas** in labeled namespaces.
   - Blocks non-compliant deployments with an informative HTTP 403 rejection.

---

> [!NOTE]
> **TLS Setup in the Background**:
> The Kubernetes API server strictly requires all admission webhooks to communicate over **HTTPS** signed by a Certificate Authority (CA) trusted in the webhook configuration.
> To keep this scenario focused on admission control mechanics without certificate debugging, the TLS keypair and Secret (`webhook-tls` in `webhook-system`) were provisioned automatically in the background.

Click **Start** to begin with the Mutating Admission Controller!

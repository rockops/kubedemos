# Kubernetes Gateway API: Modern L7 Ingress & Traffic Management

The **Kubernetes Gateway API** is the next-generation evolution of the traditional `Ingress` resource. It addresses the architectural limitations of Ingress by introducing an extensible, role-oriented, and expressive API for traffic routing.

```
       ┌─────────────────────────────────────────────────────────────────┐
       │                  Roles & Resource Separation                    │
       └─────────────────────────────────────────────────────────────────┘
                                        │
           ┌────────────────────────────┼────────────────────────────┐
           ▼                            ▼                            ▼
  [ Infrastructure Provider ]   [ Cluster Operator ]       [ Application Developer ]
         GatewayClass                 Gateway                      HTTPRoute
      (NGINX Controller)       (Listeners, Ports, TLS)     (Paths, Headers, Weights)
           │                            │                            │
           └────────────────────────────┼────────────────────────────┘
                                        ▼
                           ┌─────────────────────────┐
                           │    NGINX Data Plane     │
                           │  (LoadBalancer / Proxy) │
                           └─────────────────────────┘
                                  │            │
                     80% /store   ▼            ▼   /blog
                            [ store-v1 ]  [ blog-v1 ]
                            [ store-v2 ] (20% canary)
```

---

### Why Gateway API Over Ingress?

| Feature | Legacy Ingress | Gateway API |
|---|---|---|
| **Role Separation** | Single monolithic object mixed across teams | Distinct resources for Ops (`Gateway`) and Devs (`HTTPRoute`) |
| **Traffic Splitting (Canary)** | Requires proprietary annotations (`canary-weight`) | Core standard declarative feature (`weight: 80 / 20`) |
| **Header Matching** | Custom vendor annotations | First-class citizen in route matching rules |
| **Portability** | Incompatible annotations across ingress controllers | Standard cross-vendor API specification (`gateway.networking.k8s.io`) |
| **Request Filters** | Vendor-specific plugins or Lua scripts | Standard filters: `URLRewrite`, `RequestHeaderModifier`, `Redirect` |

---

### What You Will Build

In this scenario, you will discover the Gateway API in action using **NGINX Gateway Fabric**, the official reference Gateway API implementation by F5/NGINX:

1. **Step 1 — GatewayClass & Deploying a Gateway**: Inspect the pre-configured NGINX GatewayClass, deploy an HTTP `Gateway` on port 80, and observe how the controller provisions its data plane and external LoadBalancer IP address.
2. **Step 2 — Path-Based Routing with HTTPRoute**: Deploy sample backend microservices (`store-v1` and `blog-v1`) and route requests dynamically with path rewriting.
3. **Step 3 — Native Canary Traffic Splitting**: Introduce `store-v2` and perform weight-based canary distribution (80% / 20%) without any annotations!
4. **Step 4 — Header-Based Routing & Filters**: Route developer/tester requests (`X-Version: canary`) to `store-v2` and inject custom response headers via Gateway API filters.

> [!NOTE]
> **Automated Cluster Setup**:
> Standard Kubernetes clusters lack Gateway API CRDs and cloud load balancers. In the background, the Gateway API standard CRDs were registered and NGINX Gateway Fabric was deployed with a lightweight bare-metal LoadBalancer IP assigner.

Click **Start** to begin!

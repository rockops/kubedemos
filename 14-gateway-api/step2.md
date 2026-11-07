# 2. Path-Based Routing with HTTPRoute

As an **Application Developer**, you do not need cluster administrative privileges to expose your services. You simply author an `HTTPRoute` that attaches to the operator's `Gateway`.

---

### Step 2.1: Deploy Backend Microservices

Deploy two separate backend applications representing a store service and an engineering blog:

Open and review the workloads manifest:

```text
/root/manifests/sample-apps.yaml
```{{open}}

Deploy the backend services:

```bash
kubectl apply -f /root/manifests/sample-apps.yaml
```{{exec}}

Wait for both backend deployments to become ready:

```bash
kubectl rollout status deployment/store-v1 --timeout=60s
kubectl rollout status deployment/blog-v1 --timeout=60s
```{{exec}}

Verify their internal ClusterIP services:

```bash
kubectl get svc store-v1 blog-v1
```{{exec}}

---

### Step 2.2: Inspect the HTTPRoute Resource

Open and review the routing manifest:

```text
/root/manifests/httproute-path.yaml
```{{open}}

Key elements of the `HTTPRoute` specification:
- **`parentRefs`**: Specifies `my-gateway`. This attaches the route to the Gateway created in Step 1.
- **`rules[0].matches`**: Matches requests with path prefix `/store`.
- **`rules[0].filters`**: Uses the standard `URLRewrite` filter to rewrite `/store` to `/` before forwarding to the backend.
- **`rules[0].backendRefs`**: Routes the traffic to service `store-v1` on port 80.
- **`rules[1]`**: Mirrors the same pattern for `/blog` $\rightarrow$ `blog-v1`.

Apply the HTTPRoute:

```bash
kubectl apply -f /root/manifests/httproute-path.yaml
```{{exec}}

---

### Step 2.3: Verify Route Attachment & Status

Inspect the route status:

```bash
kubectl get httproute web-routes
```{{exec}}

Describe the route to check the Gateway controller's acceptance condition:

```bash
kubectl describe httproute web-routes
```{{exec}}

Notice under `status.parents`:
- `parentRef.name: my-gateway`
- `conditions`: `Accepted: True` (The NGINX Gateway Fabric controller accepted and programmed the route).

---

### Step 2.4: Test Path-Based Routing

Retrieve the Gateway's external IP:

```bash
GATEWAY_IP=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
```{{exec}}

1. Request the store endpoint:

```bash
curl http://$GATEWAY_IP/store
```{{exec}}

Expected output:
```text
Store Service v1 (Production)
```

2. Request the blog endpoint:

```bash
curl http://$GATEWAY_IP/blog
```{{exec}}

Expected output:
```text
Company Blog v1 (Engineering Updates)
```

3. Request an unconfigured path:

```bash
curl -i http://$GATEWAY_IP/unknown
```{{exec}}

Unmatched paths return a clean `404 Not Found` directly from the Gateway.

Click **Check** to verify Step 2!

# 3. Native Traffic Splitting (Canary Releases)

One of the most praised capabilities of the Gateway API is native, declarative **weight-based traffic splitting**.

In traditional Ingress, achieving a canary rollout required creating a second Ingress manifest packed with proprietary vendor annotations (e.g. `nginx.ingress.kubernetes.io/canary-weight: "20"`). In the Gateway API, `weight` is a first-class standard attribute on any `backendRef`.

---

### Step 3.1: Ensure the Canary Workload is Ready

The `store-v2` workload was created in Step 2. Confirm it is running:

```bash
kubectl rollout status deployment/store-v2 --timeout=60s
```{{exec}}

Verify that `store-v2` returns its own distinct message when queried internally:

```bash
kubectl run test-curl --image=nginx:alpine --image-pull-policy=IfNotPresent --rm -it --restart=Never --command -- curl -s http://store-v2/
```{{exec}}

---

### Step 3.2: Inspect the Canary Route Manifest

Open and review the canary routing configuration:

```text
/root/manifests/httproute-canary.yaml
```{{open}}

Look closely at the `/store` rule:

```yaml
    backendRefs:
    - name: store-v1
      port: 80
      weight: 80
    - name: store-v2
      port: 80
      weight: 20
```

- Requests hitting `/store` are dynamically distributed across both versions.
- **80%** of traffic goes to stable production (`store-v1`).
- **20%** of traffic is routed to the canary release (`store-v2`).
- No vendor-specific ingress controller annotations are needed!

Apply the canary routing update:

```bash
kubectl apply -f /root/manifests/httproute-canary.yaml
```{{exec}}

---

### Step 3.3: Observe Traffic Distribution in Real-Time

Fetch the Gateway external IP:

```bash
GATEWAY_IP=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
```{{exec}}

Execute a loop sending 20 consecutive requests to `/store` and aggregate the results:

```bash
for i in {1..20}; do
  curl -s http://$GATEWAY_IP/store
done | sort | uniq -c
```{{exec}}

You will see output similar to:

```text
     16 Store Service v1 (Production)
      4 Store Service v2 (CANARY Release)
```

The Gateway load-balances across the two service backends according to the exact declared weights.

Click **Check** to verify Step 3!

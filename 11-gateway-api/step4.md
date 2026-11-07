# 4. Request Header Matching & Gateway Filters

In real-world production environments, traffic routing often depends on request metadata—such as authentication tokens, session cookies, or custom headers—to support A/B testing, internal QA dogfooding, and protocol transformations.

In this step, you will configure:
1. **Header-Based Matching**: Route developers/testers sending `X-Version: canary` directly to `store-v2` (100% deterministic).
2. **Gateway API Filters (`ResponseHeaderModifier`)**: Inject dynamic HTTP headers into the response to identify which routing rule handled the request.

---

### Step 4.1: Inspect the Header Matching Route

Open and review the routing manifest:

```text
/root/manifests/httproute-header.yaml
```{{open}}

Notice the rule ordering and structure:

```yaml
  # Rule 1: QA / Tester route (Exact header match)
  - matches:
    - path:
        type: PathPrefix
        value: /store
      headers:
      - name: X-Version
        value: canary
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplaceFullPath
          replaceFullPath: /
    - type: ResponseHeaderModifier
      responseHeaderModifier:
        add:
        - name: X-Route-Matched
          value: canary-tester
    backendRefs:
    - name: store-v2
      port: 80
```

- When a client presents `X-Version: canary`, Rule 1 triggers.
- The request bypasses the 80/20 weight pool and routes directly to `store-v2`.
- The filter appends `X-Route-Matched: canary-tester` to the HTTP response headers.
- Requests without this header fall through to Rule 2 (the weighted canary pool).

Apply the updated configuration:

```bash
kubectl apply -f /root/manifests/httproute-header.yaml
```{{exec}}

---

### Step 4.2: Test Default Traffic vs Targeted Header Traffic

Fetch the Gateway external IP:

```bash
GATEWAY_IP=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
```{{exec}}

1. **Test a standard request without custom headers**:

```bash
curl -i http://$GATEWAY_IP/store
```{{exec}}

Notice the response headers:
```http
HTTP/1.1 200 OK
...
x-route-matched: weighted-pool
...
Store Service v1 (Production)
```

2. **Test a targeted QA request with `X-Version: canary`**:

```bash
curl -i -H "X-Version: canary" http://$GATEWAY_IP/store
```{{exec}}

Notice that:
- The response body is **always** `Store Service v2 (CANARY Release)`.
- The response header confirms: `x-route-matched: canary-tester`.

3. **Verify with a batch test**:

Send 10 requests with the header to verify deterministic routing:

```bash
for i in {1..10}; do
  curl -s -H "X-Version: canary" http://$GATEWAY_IP/store
done | sort | uniq -c
```{{exec}}

Expected output:
```text
     10 Store Service v2 (CANARY Release)
```

100% of requests with the header reached the canary service, while regular users continue to receive the weighted distribution!

Click **Check** to complete Step 4!

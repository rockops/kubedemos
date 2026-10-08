# 2. Validating Admission Controller (Replica Limit Policy)

In this step, you will configure and test a **Validating Admission Webhook** that enforces an organizational governance rule: **Deployments cannot exceed 5 replicas** in designated namespaces.

---

### Understanding Validating Webhooks

Unlike mutating webhooks (which modify objects before schema validation), **validating webhooks** run *after* schema validation. They cannot alter objects; they can only **allow** or **deny** the request based on custom policy logic.

If denied, the Kubernetes API server aborts the transaction immediately and returns an HTTP 403 Forbidden error along with a clear diagnostic message.

---

### Step 2.1: Inspect the Validating Logic & Configuration

Review the validating handler in the Python script:

```text
/root/manifests/injector.py
```{{open}}

Look at `handle_validate`:
```python
replicas = obj.get("spec", {}).get("replicas", 1)
if replicas > MAX_REPLICAS: # MAX_REPLICAS = 5
    return allowed: False (Code 403: "Deployment violates replica quota: maximum allowed is 5 replicas")
else:
    return allowed: True
```

Now open the ValidatingWebhookConfiguration manifest:

```text
/root/manifests/validating-webhook.yaml
```{{open}}

Notice how:
- It intercepts `CREATE` and `UPDATE` operations on `deployments`.
- It routes requests to path `/validate` on the `admission-webhook` Service.
- It is scoped with `namespaceSelector: matchLabels: sidecar-injection: enabled`.

---

### Step 2.2: Register the Validating Webhook

Register the validating webhook with the Kubernetes API server:

```bash
kubectl apply -f /root/manifests/validating-webhook.yaml
```{{exec}}

Verify that both admission webhooks are now active:

```bash
kubectl get mutatingwebhookconfigurations
kubectl get validatingwebhookconfigurations
```{{exec}}

---

### Step 2.3: Test Case 1 — Deploy a Compliant Deployment (3 Replicas)

Open and inspect the compliant deployment manifest:

```text
/root/manifests/deployment-valid.yaml
```{{open}}

This deployment requests **3 replicas** ($\le 5$).

Deploy it to the labeled `prod` namespace:

```bash
kubectl apply -f /root/manifests/deployment-valid.yaml -n prod
```{{exec}}

Verify that it was accepted:

```bash
kubectl get deployment valid-app -n prod
```{{exec}}

The webhook allowed the creation, and the deployment is running with 3 replicas.

---

### Step 2.4: Test Case 2 — Deploy an Oversized Deployment (8 Replicas)

Open and inspect the oversized deployment manifest:

```text
/root/manifests/deployment-invalid.yaml
```{{open}}

Notice that `spec.replicas` is set to **`8`** ($> 5$).

Try applying this manifest to the labeled `prod` namespace:

```bash
kubectl apply -f /root/manifests/deployment-invalid.yaml -n prod
```{{exec}}

The API server immediately **rejects** the request! You will see an error:

```text
Error from server (Forbidden): error when creating "/root/manifests/deployment-invalid.yaml": 
admission webhook "replica-validator.webhook-system.svc" denied the request: 
Deployment violates replica quota: maximum allowed is 5 replicas (requested: 8)
```

Confirm that the deployment was **not** created in `prod`:

```bash
kubectl get deployment oversized-app -n prod 2>&1 || true
```{{exec}}

---

### Step 2.5: Test Case 3 — Verify Namespace Scoping

What happens if we apply the oversized deployment to the unlabeled `dev` namespace?

```bash
kubectl apply -f /root/manifests/deployment-invalid.yaml -n dev
```{{exec}}

Check the deployment in `dev`:

```bash
kubectl get deployment oversized-app -n dev
```{{exec}}

It succeeds! Because `dev` does not have the `sidecar-injection=enabled` label, the API server bypassed the validating webhook entirely, demonstrating strict namespace isolation.

---

### Step 2.6: Review Admission Webhook Logs

Inspect the webhook server logs to see the decisions made for each request:

```bash
kubectl logs -n webhook-system -l app=admission-webhook --tail=20
```{{exec}}

You will see:
```text
[ALLOWED] Deployment 'valid-app' in 'prod' requested 3 replicas (<= 5)
[DENIED] Deployment 'oversized-app' in 'prod' requested 8 replicas (max: 5)
```

# 1. Mutating Admission Controller (Automatic Sidecar Injection)

In this step, you will deploy the in-cluster admission webhook server and configure a **Mutating Admission Webhook** to automatically inject a heartbeat sidecar container into pods in a target namespace.

---

### Step 1.1: Initialize TLS & Verify CA Bundle

Admission webhooks require TLS. Run the setup script to generate the certificates, create the `webhook-tls` secret, and inject the base64 CA bundle into the webhook manifests:

```bash
bash /root/manifests/setup-tls.sh
```{{exec}}

Confirm that the TLS secret exists in the `webhook-system` namespace:

```bash
kubectl get secret webhook-tls -n webhook-system
```{{exec}}

---

### Step 1.2: Inspect the Webhook Logic & Deploy Server

Open and review the Python script that powers the admission server:

```text
/root/manifests/injector.py
```{{open}}

Notice the mutating handler `handle_mutate`:
- Reads the incoming `AdmissionReview` from the Kubernetes API server.
- Uses `urllib.parse.urlparse` to safely handle the request path without getting tripped up by query parameters like `?timeout=5s`.
- Returns an RFC 6902 JSONPatch to append `sidecar-agent` (`busybox` printing heartbeats every 5s) to `/spec/containers/-`.

Now open the deployment manifest:

```text
/root/manifests/webhook-server.yaml
```{{open}}

Deploy the webhook server into `webhook-system`:

```bash
kubectl apply -f /root/manifests/webhook-server.yaml
```{{exec}}

Wait for the deployment to become ready:

```bash
kubectl rollout status deployment/admission-webhook -n webhook-system --timeout=60s
```{{exec}}

---

### Step 1.3: Apply the MutatingWebhookConfiguration

Open and review the mutating configuration:

```text
/root/manifests/mutating-webhook.yaml
```{{open}}

Notice the `namespaceSelector: matchLabels: sidecar-injection: enabled`. Only pods in namespaces with this label will be intercepted.

Register the mutating webhook:

```bash
kubectl apply -f /root/manifests/mutating-webhook.yaml
```{{exec}}

Verify the registration:

```bash
kubectl get mutatingwebhookconfigurations
```{{exec}}

---

### Step 1.4: Create Namespaces & Deploy Workloads

Create two namespaces, one for development and one for production:

```bash
kubectl create ns dev
kubectl create ns prod
```{{exec}}

Label the `prod` namespace for sidecar injection:

```bash
kubectl label ns prod sidecar-injection=enabled
```{{exec}}

Verify the namespaces:
```bash
kubectl get ns dev prod --show-labels
```{{exec}}


Open and inspect the sample application manifest:

```text
/root/manifests/sample-app.yaml
```{{open}}

Notice that `sample-app.yaml` defines **only one container** (`name: web`, `image: nginx:alpine`).

Deploy the exact same manifest to both namespaces:

```bash
kubectl apply -f /root/manifests/sample-app.yaml -n dev
kubectl apply -f /root/manifests/sample-app.yaml -n prod
```{{exec}}

Wait for the pods to be ready:

```bash
kubectl wait --for=condition=Ready pod/web-app -n dev --timeout=60s
kubectl wait --for=condition=Ready pod/web-app -n prod --timeout=60s
```{{exec}}

---

### Step 1.5: Observe Injection & Heartbeat Logs

Compare the pod container counts between namespaces:

```bash
kubectl get pods -n dev
kubectl get pods -n prod
```{{exec}}

Notice the difference:
- In `dev`: **`1/1 READY`** (unmutated, single `web` container).
- In `prod`: **`2/2 READY`** (the admission controller injected `sidecar-agent`!).

Inspect the logs of the injected sidecar container:

```bash
kubectl logs pod/web-app -n prod -c sidecar-agent --tail=5
```{{exec}}

You will see heartbeat messages printed every 5 seconds:
```text
[sidecar-agent] Heartbeat active at Tue Oct  6 21:40:00 UTC 2026
[sidecar-agent] Heartbeat active at Tue Oct  6 21:40:05 UTC 2026
```

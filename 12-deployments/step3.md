### 1. What Happens When a Release Fails?

In traditional deployments, pushing a broken container image or bad configuration often crashes the running service, causing immediate downtime.

In Kubernetes, the Deployment controller acts as an automated safety harness:
1. It attempts to start a replacement pod (governed by `maxSurge: 1`).
2. If the new pod fails to start or fails its readiness probe, it is **never added as an active endpoint** to the Service.
3. Because `maxUnavailable: 0`, Kubernetes **refuses to terminate any existing healthy pods** until the new pod is verified healthy!

Let's observe this protection mechanism in action.

<br>

### 2. Inspect the Broken Version 3 Manifest

Open and review the broken release manifest:

```text
/root/manifests/webapp-v3-broken.yaml
```{{open}}

Notice the error in the container image specification:
- `image: nginx:broken-v3-tag-error`: A non-existent image tag.
- `annotations.kubernetes.io/change-cause`: `"Release v3.0.0: Broken image tag release"`

<br>

### 3. Deploy the Broken Release

Apply the broken deployment:

```bash
kubectl apply -f /root/manifests/webapp-v3-broken.yaml
```{{exec}}

Watch the rollout status with a 20-second timeout:

```bash
kubectl rollout status deployment/webapp --timeout=20s
```{{exec}}

The rollout **stalls**! Kubernetes waits indefinitely for the new replica to become ready.

<br>

### 4. Diagnose the Root Cause

Inspect all pods belonging to the `webapp`:

```bash
kubectl get pods -l app=webapp
```{{exec}}

Look at the statuses:

```text
NAME                      READY   STATUS             RESTARTS   AGE
webapp-59c47cf79-4k2ln    1/1     Running            0          4m    <-- Healthy v2
webapp-59c47cf79-8vx2p    1/1     Running            0          4m    <-- Healthy v2
webapp-59c47cf79-m9z1q    1/1     Running            0          4m    <-- Healthy v2
webapp-675bf87489-j9d4w   0/1     ImagePullBackOff   0          30s   <-- Stalled v3
```

Describe the failing pod to inspect the Kubernetes events:

```bash
kubectl describe pod -l version=v3
```{{exec}}

Scroll to the **Events** section at the bottom. You will see:
`Failed to pull image "nginx:broken-v3-tag-error": pull access denied, repository does not exist or may require authorization`.

<br>

### 5. Verify Zero Impact on Production Traffic

Look at your **Live Traffic Stream** window (bottom-right):
Notice that despite the failed rollout, requests never stopped and continue returning `[App v2.0.0]` without a single error!

You can also send requests directly from your main terminal:

```bash
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}')
for i in {1..6}; do curl -s http://$SVC_IP; done
```{{exec}}

**100% of requests succeed and return `[App v2.0.0]`!**

Why?
1. The broken `v3` pod was never Ready, so Kubernetes never registered its IP in `webapp-service` Endpoints (`kubectl get endpoints webapp-service`).
2. `maxUnavailable: 0` prevented the controller from shutting down any healthy `v2` pods.

Click **Check** to verify Step 3!


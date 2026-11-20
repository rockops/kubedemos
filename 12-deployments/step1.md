### 1. The Deployment Architecture

A common misconception is that a `Deployment` directly manages Pods. In reality, Kubernetes implements a **3-tier ownership chain**:

1. **`Deployment`**: Manages declarative rollout state, strategies, and revision history.
2. **`ReplicaSet`**: Manages the exact count of identical Pod replicas (scaling up or down).
3. **`Pod`**: Runs the actual container workloads.

<br>

### 2. Inspect the Manifests

Open and review the initial production deployment manifest:

```text
/root/manifests/webapp-v1.yaml
```{{open}}

Notice key elements:
- `replicas: 3`: Specifies that three pod instances must be running at all times.
- `strategy.type: RollingUpdate`: The default strategy for seamless updates.
- `annotations.kubernetes.io/change-cause`: Records a descriptive message in the deployment's audit history.
- `readinessProbe`: Ensures a pod is only considered healthy once it can serve traffic.

Open and review the companion Service:

```text
/root/manifests/webapp-service.yaml
```{{open}}

<br>

### 3. Deploy the Initial Application (v1.0.0)

Apply both manifests:

```bash
kubectl apply -f /root/manifests/webapp-v1.yaml
kubectl apply -f /root/manifests/webapp-service.yaml
```{{exec}}

Watch the deployment reach the completed state using `kubectl rollout status`:

```bash
kubectl rollout status deployment/webapp
```{{exec}}

<br>

### 4. Inspect the 3-Tier Ownership Chain

List the Deployment:

```bash
kubectl get deployment webapp
```{{exec}}

Now inspect the **ReplicaSet** created on behalf of this Deployment:

```bash
kubectl get replicaset -l app=webapp
```{{exec}}

Notice the ReplicaSet name: it begins with `webapp-` followed by a hash (e.g. `webapp-7f6d89b...`). This hash is calculated from the pod template specification.

Now list the **Pods**:

```bash
kubectl get pods -l app=webapp -o wide
```{{exec}}

Observe that each Pod name starts with the exact name of the parent ReplicaSet!

Verify the ownership link on one of the pods:

```bash
kubectl get pod -l app=webapp -o jsonpath='{.items[0].metadata.name} is owned by {.items[0].metadata.ownerReferences[0].kind}: {.items[0].metadata.ownerReferences[0].name}{"\n"}'
```{{exec}}

<br>

### 5. Test Baseline Traffic

Retrieve the service ClusterIP and send an HTTP request:

```bash
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}')
curl -s http://$SVC_IP
```{{exec}}

Send 6 consecutive requests to confirm traffic balances across all 3 replicas:

```bash
for i in {1..6}; do curl -s http://$SVC_IP; done
```{{exec}}

All pods report `[App v1.0.0]`. Click **Check** to verify Step 1!


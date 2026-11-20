### 1. Why Pause a Deployment?

In production, you often need to apply multiple configuration modifications to a Deployment—such as:
- Adjusting compute resource requests and limits (`resources`)
- Adding or modifying environment variables (`env`)
- Updating container images (`image`)
- Adding labels or annotations

If you apply these changes individually, Kubernetes triggers a **separate, full rolling update** for every single modification! This creates unnecessary pod churn, wastes cluster resources, and clutters the ReplicaSet revision history.

With **`kubectl rollout pause`**, you can freeze rollouts, stage multiple modifications safely, and then execute all changes in a single, atomic rollout using **`kubectl rollout resume`**.

<br>

### 2. Pause the Active Deployment

Freeze the `webapp` deployment:

```bash
kubectl rollout pause deployment/webapp
```{{exec}}

Verify that the deployment is marked as paused:

```bash
kubectl get deployment webapp -o jsonpath='Paused: {.spec.paused}{"\n"}'
```{{exec}}

<br>

### 3. Stage Multiple Configuration Changes

While the deployment is paused, let's stage two independent updates:

**Change 1 — Set CPU and Memory resource limits**:

```bash
kubectl set resources deployment/webapp -c=web --limits=cpu=200m,memory=128Mi --requests=cpu=50m,memory=64Mi
```{{exec}}

**Change 2 — Update the application version environment variable**:

```bash
kubectl set env deployment/webapp APP_VERSION="v2.1.0-patched"
```{{exec}}

**Change 3 — Update the rollout audit message**:

```bash
kubectl annotate deployment/webapp kubernetes.io/change-cause="Release v2.1.0: Added resource limits and patched version" --overwrite
```{{exec}}

<br>

### 4. Verify That No Intermediate Rollout Occurred

Check the ReplicaSets:

```bash
kubectl get rs -l app=webapp
```{{exec}}

Notice that **no new ReplicaSet was created**, and all running pods remain completely untouched! The changes were recorded in the Deployment specification, but execution was held in reserve.

<br>

### 5. Resume and Execute the Batched Rollout

Resume the deployment to trigger the unified rollout:

```bash
kubectl rollout resume deployment/webapp
```{{exec}}

Monitor the single rollout as it updates all 3 replicas:

```bash
kubectl rollout status deployment/webapp
```{{exec}}

<br>

### 6. Verify the Batched Changes

1. **Verify the new version in traffic**:

Look at your **Live Traffic Stream** window (bottom-right): the responses have seamlessly transitioned to `[App v2.1.0-patched]`!

You can also send requests directly from your main terminal:

```bash
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}')
for i in {1..6}; do curl -s http://$SVC_IP; done
```{{exec}}

Notice the response: `[App v2.1.0-patched]`.

2. **Verify the applied resource limits on the new pods**:

```bash
kubectl get pod -l app=webapp -o jsonpath='{.items[0].spec.containers[0].resources}{"\n"}'
```{{exec}}

Both the resource constraints and the version change were deployed together in a single rollout cycle!

Click **Check** to verify Step 5!


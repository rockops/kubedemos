### 1. The Rollout History & Revisions

Whenever a Deployment's pod template (`spec.template`) is updated, the Deployment controller automatically generates a new **Revision** and preserves the older ReplicaSet.

This built-in versioning mechanism allows you to inspect past changes and revert broken deployments in seconds.

<br>

### 2. Inspect the Rollout History

View the revision history of the `webapp` deployment:

```bash
kubectl rollout history deployment/webapp
```{{exec}}

You will see:

```text
REVISION  CHANGE-CAUSE
1         Release v1.0.0: Initial production deployment
2         Release v2.0.0: Performance updates and new features
3         Release v3.0.0: Broken image tag release
```

> [!NOTE]
> **Why `CHANGE-CAUSE` is populated**:
> In our manifests, we set `metadata.annotations["kubernetes.io/change-cause"]`. Without this annotation, `CHANGE-CAUSE` defaults to `<none>`, making production audits difficult.

Inspect the detailed pod template for Revision 2:

```bash
kubectl rollout history deployment/webapp --revision=2
```{{exec}}

Notice that Kubernetes stored the exact container image, environment variables, and labels used in that revision!

<br>

### 3. Undo the Broken Rollout

To instantly abort the stalled `v3` release and recover, run `kubectl rollout undo`:

```bash
kubectl rollout undo deployment/webapp
```{{exec}}

*(Note: To roll back to a specific revision further in the past, you can pass `--to-revision=<N>`, for example `kubectl rollout undo deployment/webapp --to-revision=1`)*.

Wait for the rollback to complete:

```bash
kubectl rollout status deployment/webapp
```{{exec}}

<br>

### 4. Verify Cluster Health & Pod State

List the pods:

```bash
kubectl get pods -l app=webapp
```{{exec}}

Notice that:
- The failing `v3` pod has been terminated and purged.
- Exactly 3 healthy `v2` pods remain active.

Check the rollout history again:

```bash
kubectl rollout history deployment/webapp
```{{exec}}

Notice that Revision 2 has now been promoted to **Revision 4**!

<br>

### 5. Verify Application Responses

Look at the **Live Traffic Stream** window (bottom-right): all requests are cleanly served by the recovered `v2` pods.

You can also send requests directly from your main terminal:

```bash
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}')
for i in {1..6}; do curl -s http://$SVC_IP; done
```{{exec}}

All 3 replicas respond cleanly with `[App v2.0.0]`. Click **Check** to verify Step 4!


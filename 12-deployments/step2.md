### 1. Understanding `maxSurge` & `maxUnavailable`

During a `RollingUpdate`, Kubernetes balances speed against availability using two key parameters:

| Parameter | What It Controls | Our Setting (`webapp-v1.yaml`) | Effect |
|---|---|---|---|
| **`maxSurge`** | How many extra pods can be created *above* `replicas`. | `1` (or 25%) | Up to 4 pods can exist simultaneously ($3 + 1$). |
| **`maxUnavailable`** | How many pods can be unavailable *below* `replicas`. | `0` | **Zero downtime guarantee**: No pod is terminated until a new pod is fully ready! |

Because `maxUnavailable: 0`, Kubernetes will **never** reduce capacity below the desired 3 replicas.

<br>

### 2. Inspect the Version 2 Manifest

Open and review the v2 update manifest:

```text
/root/manifests/webapp-v2.yaml
```{{open}}

Notice the changes:
- `template.metadata.labels.version`: `v2`
- `env.APP_VERSION`: `v2.0.0`
- `annotations.kubernetes.io/change-cause`: `"Release v2.0.0: Performance updates and new features"`

<br>

### 3. Trigger the Rolling Update with Live Traffic

Look at your **Live Traffic Stream** window (bottom-right). Notice that it is actively sending continuous HTTP requests every 0.5s to `webapp-service` and printing responses.

Now apply the v2 deployment in your main terminal:

```bash
kubectl apply -f /root/manifests/webapp-v2.yaml
```{{exec}}

Track the rollout progress in real time:

```bash
kubectl rollout status deployment/webapp
```{{exec}}

Observe the three windows working in synchronization:
1. **Top Window**: Tracks the status until all 3 new replicas are ready.
2. **Bottom-Left Window (`Rollout Monitor`)**: The new ReplicaSet appears and scales up incrementally ($0 \rightarrow 1 \rightarrow 2 \rightarrow 3$), while the old ReplicaSet scales down.
3. **Bottom-Right Window (`Live Traffic Stream`)**: The live responses shift smoothly from `[App v1.0.0]` to `[App v2.0.0]` without a single connection drop or error!

<br>

### 4. Inspect the Inactive vs Active ReplicaSets

List all ReplicaSets associated with the webapp:

```bash
kubectl get rs -l app=webapp
```{{exec}}

Notice the output:

```text
NAME                DESIRED   CURRENT   READY   AGE
webapp-7f6d89b...   0         0         0       3m    <-- Old v1 ReplicaSet (Preserved for rollback)
webapp-59c47cf...   3         3         3       45s   <-- New v2 ReplicaSet (Active)
```

> [!NOTE]
> **Why is the old ReplicaSet preserved?**
> Kubernetes does not delete old ReplicaSets when a rollout completes. It retains their pod templates so you can instantly roll back to an earlier revision at any time!

Send requests to confirm that 100% of traffic is now handled by version 2:

```bash
for i in {1..6}; do curl -s http://$SVC_IP; done
```{{exec}}

Click **Check** to verify Step 2!


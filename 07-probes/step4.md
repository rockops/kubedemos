### 1. Inspect and Deploy the HTTP Application Pod

In real-world microservices, probes are typically implemented via HTTP health endpoints rather than filesystem commands.

> [!NOTE]
> An in-cluster client Pod (`curl-test-pod`) using `alpine/curl` has been automatically prepared in the background.

Open and inspect the HTTP probe application manifest:

```text
/root/manifests/http-pod.yaml
```{{open}}

This manifest configures a lightweight Python server inside **`http-probe-pod`** on port `8080`:
- **`/health`**: Checks if `/tmp/health` exists $\rightarrow$ returns `200 OK` (or `500` if absent). Configured as the **`livenessProbe`**.
- **`/ready`**: Checks if `/tmp/ready` exists $\rightarrow$ returns `200 OK` (or `500` if absent). Configured as the **`readinessProbe`**.
- **`/`**: Returns a JSON status summary: `{"status": "...", "ready": ..., "healthy": ...}`.

Notice the probe definitions in the Pod spec:
```yaml
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 2
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 2
      periodSeconds: 2
      failureThreshold: 2
```

Deploy the Pod:

```bash
kubectl apply -f /root/manifests/http-pod.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Check the **Pod Monitor** tab on the right:
> Notice that `http-probe-pod` shows `STATUS: Running`, but `READY: 0/1`.

Inspect the Pod status:

```bash
kubectl get pod http-probe-pod -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,READY:.status.containerStatuses[0].ready,IP:.status.podIP
```{{exec target=controlplane}}

The container is running and healthy (`/health` returns `200` because `/tmp/health` was initialized), but it is not ready because `/tmp/ready` has not yet been created (`/ready` returns `500`).

<br>

### 2. Deploy the Service in Front of the Pod

Open and inspect the Service manifest:

```text
/root/manifests/http-service.yaml
```{{open}}

Deploy the Service:

```bash
kubectl apply -f /root/manifests/http-service.yaml
```{{exec target=controlplane}}

Inspect the Service and its registered endpoints:

```bash
kubectl get endpoints http-probe-service
```{{exec target=controlplane}}

Notice:
```text
NAME                 ENDPOINTS   AGE
http-probe-service   <none>      ...
```

**`ENDPOINTS` is `<none>`!** Even though `http-probe-pod` matches the selector `app: http-probe`, Kubernetes automatically **excludes** unready Pods from receiving Service traffic.

<br>

### 3. Open an In-Cluster Shell in the Second Terminal

Until now, the second terminal tab (**Pod Monitor**) has been running `watch kubectl get pods`.
We will now send an **`interrupt`** (Ctrl+C) to stop the watch process and open an interactive shell inside our in-cluster test client (`curl-test-pod`):

```bash
kubectl exec -it curl-test-pod -- sh
```{{exec interrupt target=logs}}

> [!NOTE]
> Look at the second terminal tab on the right: the `watch` has stopped and the terminal prompt is now `/ # ` inside `curl-test-pod`. All subsequent `curl` commands will run directly inside this in-cluster shell!

<br>

### 4. Enable Pod Name Resolution

In standard Kubernetes, CoreDNS automatically resolves Service names (`http-probe-service`), but does not register standalone Pod names. To enable direct testing of `http-probe-pod` by its name, map the Pod IP in the test client's `/etc/hosts`:

```bash
POD_IP=$(kubectl get pod http-probe-pod -o jsonpath='{.status.podIP}')
kubectl exec curl-test-pod -- sh -c "echo '$POD_IP http-probe-pod' >> /etc/hosts"
echo "Mapped http-probe-pod -> $POD_IP"
```{{exec target=controlplane}}

Now both **`http-probe-pod`** and **`http-probe-service`** can be addressed by name!

<br>

### 5. Direct Pod Access vs. Service Access from Inside the Cluster

In the second terminal on the right (`curl-test-pod`), run the curl tests:

#### Direct Pod Access (by Pod Name):
Query `http-probe-pod` directly:

```bash
curl -s http://http-probe-pod:8080/
```{{exec target=logs}}

Output:
```json
{
  "status": "Not Ready",
  "ready": false,
  "healthy": true
}
```

**The Pod responds with its status recap even while unready!**

#### Service DNS Access (by Service Name):
Now query through the Service using its in-cluster CoreDNS name (`http-probe-service`):

```bash
curl -s --connect-timeout 2 http://http-probe-service:8080/ || echo "Connection Failed: No endpoints available"
```{{exec target=logs}}

**Through the Service, the application is inaccessible.** CoreDNS resolves `http-probe-service` to its virtual IP, but Kubernetes blocks traffic because the Service has zero ready endpoints.

<br>

### 6. Unlock Readiness

In the left terminal (**controlplane**), simulate the application completing internal startup by creating `/tmp/ready`:

```bash
kubectl exec http-probe-pod -- touch /tmp/ready
```{{exec target=controlplane}}

Wait for the HTTP readiness probe to succeed:

```bash
kubectl wait --for=condition=Ready pod/http-probe-pod --timeout=10s
```{{exec target=controlplane}}

Verify the Service endpoints:

```bash
kubectl get endpoints http-probe-service
```{{exec target=controlplane}}

The Pod IP is now active in `ENDPOINTS`:
```text
NAME                 ENDPOINTS            AGE
http-probe-service   10.244.0.x:8080      ...
```

Now, in the right terminal, query through the Service again:

```bash
curl -s http://http-probe-service:8080/
```{{exec target=logs}}

Output:
```json
{
  "status": "Ready",
  "ready": true,
  "healthy": true
}
```
Traffic now flows cleanly through the Service!

<br>

### 7. Remove Readiness: Traffic Cutoff with Zero Restarts

In the **controlplane** terminal, simulate an unready state by removing `/tmp/ready`:

```bash
kubectl exec http-probe-pod -- rm /tmp/ready
```{{exec target=controlplane}}

Wait 2–4 seconds (`periodSeconds: 2`), then inspect the Service endpoints:

```bash
kubectl get endpoints http-probe-service
```{{exec target=controlplane}}

The Pod is immediately removed from `ENDPOINTS` (`<none>`).

In the right terminal, attempt to query the Service:

```bash
curl -s --connect-timeout 2 http://http-probe-service:8080/ || echo "Traffic cleanly cut off by Service"
```{{exec target=logs}}

In the right terminal, query the Pod directly by its name:

```bash
curl -s http://http-probe-pod:8080/
```{{exec target=logs}}

The Pod is still alive and responds directly with `ready: false`!

In the **controlplane** terminal, verify that the container was not restarted:

```bash
kubectl get pod http-probe-pod -o custom-columns=NAME:.metadata.name,READY:.status.containerStatuses[0].ready,RESTARTS:.status.containerStatuses[0].restartCount
```{{exec target=controlplane}}

Notice:
- **`READY`** is `false`.
- **`RESTARTS`** is still **`0`**!

> [!NOTE]
> **Key Insight**: Failing a **readiness probe** detaches the Pod from Service routing without killing the container. This allows the application to shed traffic safely without triggering destructive container restarts.

<br>

### 8. Reactivate Readiness: Seamless Traffic Recovery

In the **controlplane** terminal, re-create `/tmp/ready`:

```bash
kubectl exec http-probe-pod -- touch /tmp/ready
```{{exec target=controlplane}}

Wait for the Pod to become Ready:

```bash
kubectl wait --for=condition=Ready pod/http-probe-pod --timeout=10s
```{{exec target=controlplane}}

In the right terminal, query the Service once more:

```bash
curl -s http://http-probe-service:8080/
```{{exec target=logs}}

Output:
```json
{
  "status": "Ready",
  "ready": true,
  "healthy": true
}
```

The Service automatically resumes routing traffic to the Pod the moment the readiness probe succeeds again!

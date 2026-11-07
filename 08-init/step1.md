### 1. Inspect the Manifest with an Init Container

In this step, we examine a Pod that requires a database service to be reachable before its main web server starts.

Open and inspect the manifest in the editor:

```text
/root/manifests/web-portal.yaml
```{{open}}

Notice the `initContainers` specification:
```yaml
  initContainers:
    - name: wait-for-db
      image: busybox:1.36
      imagePullPolicy: IfNotPresent
      command:
        - sh
        - -c
        - |
          echo "Init container wait-for-db started."
          until nc -z -w 2 db-service 3306; do
            echo "Waiting for db-service on port 3306..."
            sleep 2
          done
          echo "Database service detected! Init container completed successfully."
```

The init container uses `nc` (netcat) inside a loop to poll for `db-service` on port 3306. Since `db-service` does not yet exist, the init container will keep looping and remain running.

<br>

### 2. Deploy the Web Portal Pod

Deploy the manifest:

```bash
kubectl apply -f /root/manifests/web-portal.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Pod Monitor** pane at the bottom!
> Notice that `web-portal` shows:
> - `READY: 0/1`
> - `STATUS: Init:0/1`
>
> The `Init:0/1` status means that **0 out of 1 init containers** have finished executing.

<br>

### 3. Verify Container Execution States

Now check the exact state of both the init container and the application container:

```bash
kubectl describe pod web-portal
```{{exec target=controlplane}}

Look at the **Init Containers** and **Containers** sections in the output:
- **`wait-for-db` (Init Container)**: `State: Running`
- **`web-app` (Main Container)**: `State: Waiting` with `Reason: PodInitializing`, and `Ready: false`.

> [!IMPORTANT]
> **Execution Order Guarantee**:
> The `web-app` container has **NOT** even started. Kubernetes guarantees that no application container will run until every init container exits with code `0`.

<br>

### 4. Inspect Init Container Logs

To view the logs of an init container, use `kubectl logs` with the `-c <container-name>` flag:

```bash
kubectl logs web-portal -c wait-for-db
```{{exec target=controlplane}}

You can see the repeated polling attempts:
```text
Waiting for db-service on port 3306...
Waiting for db-service on port 3306...
```

The pod will remain safely gated in this state indefinitely until the dependency is fulfilled.


### 1. Inspect the Database Service Manifest

To unblock the `web-portal` pod, we need to create the `db-service` Service and a mock database backend.

Open the manifest in the editor:

```text
/root/manifests/db-service.yaml
```{{open}}

Notice the manifest defines:
1. A backend Pod `db-backend` running `busybox` listening on port 3306.
2. A ClusterIP Service named `db-service` routing port 3306 to `db-backend`.

<br>

### 2. Deploy the Database Service

Deploy the database and service:

```bash
kubectl apply -f /root/manifests/db-service.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Keep your eyes on the **Pod Monitor** pane below!
> Watch the live transition:
> 1. `db-backend` starts and reaches `Running (1/1)`.
> 2. `web-portal`'s init container detects port 3306.
> 3. `web-portal` transitions: `Init:0/1` $\longrightarrow$ `PodInitializing` $\longrightarrow$ `Running (1/1)`.

<br>

### 3. Verify Completion of the Init Container

Now inspect the logs of `wait-for-db`:

```bash
kubectl logs web-portal -c wait-for-db
```{{exec target=controlplane}}

You should see the successful resolution:
```text
Database service detected! Init container completed successfully.
```

Check the status of the init container in the pod metadata:

```bash
kubectl get pod web-portal -o jsonpath='{.status.initContainerStatuses[0].state.terminated.reason}
'
```{{exec target=controlplane}}

The init container is marked as **`Completed`** with exit code `0`.

<br>

### 4. Verify Main Application Container Startup

Now check the logs of the main application container `web-app`:

```bash
kubectl logs web-portal -c web-app
```{{exec target=controlplane}}

You will see Nginx's startup message:
```text
Configuration complete; ready for start up
```

> [!TIP]
> The init container did its job and completely stopped. It consumes no CPU or memory while the application container runs!


### 1. Inspect the Faulty Init Container Manifest

What happens if an init container encounters an error and exits with a non-zero exit code?

Open the manifest in the editor:

```text
/root/manifests/faulty-init.yaml
```{{open}}

Notice the init container command:
```yaml
  initContainers:
    - name: pre-flight-check
      image: busybox:1.36
      imagePullPolicy: IfNotPresent
      command:
        - sh
        - -c
        - |
          echo "Running pre-flight validation checks..."
          sleep 2
          echo "ERROR: Critical database migration script missing or corrupt!" >&2
          exit 1
```

The script exits with `exit 1` after reporting a critical error.

<br>

### 2. Deploy the Faulty Pod

Deploy the manifest:

```bash
kubectl apply -f /root/manifests/faulty-init.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Look at the **Pod Monitor** pane below!
> Notice the status changes:
> - `STATUS: Init:Error` (The init container exited with code 1)
> - `STATUS: Init:CrashLoopBackOff` (Kubernetes backs off before retrying the init container)

<br>

### 3. Verify Application Container Isolation

Run `kubectl describe` to inspect the states of both containers:

```bash
kubectl describe pod faulty-pod
```{{exec target=controlplane}}

Observe two key findings:
1. Under **Init Containers**:
   - `pre-flight-check` shows `Last State: Terminated` with `Exit Code: 1`.
   - `State: Waiting` with `Reason: CrashLoopBackOff`.
2. Under **Containers**:
   - `critical-service` shows `State: Waiting` with `Reason: PodInitializing`.
   - `Ready: false`.

> [!IMPORTANT]
> **Safety Guarantee**:
> Even though the init container crashed repeatedly, Kubernetes **never** attempted to start the `critical-service` container.
> This prevents an application from running with corrupted schemas, missing secrets, or invalid configurations.

<br>

### 4. Inspect the Failure Logs

Check the logs to diagnose why the init container failed:

```bash
kubectl logs faulty-pod -c pre-flight-check
```{{exec target=controlplane}}

You can also view the logs of the previous crashed instance using `--previous`:

```bash
kubectl logs faulty-pod -c pre-flight-check --previous
```{{exec target=controlplane}}

<br>

### 5. Clean Up

Clean up the faulty pod:

```bash
kubectl delete pod faulty-pod
```{{exec target=controlplane}}


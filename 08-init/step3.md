### 1. Inspect the Multi-Stage Init Pipeline

Init containers are often chained together to build sequential initialization pipelines. In this step, we demonstrate:
1. **Sequential execution**: Container 1 must finish before Container 2 starts.
2. **Data pre-population**: Writing data to a shared `emptyDir` volume that the main container serves.

Open the manifest in the editor:

```text
/root/manifests/page-generator.yaml
```{{open}}

Examine how the pieces connect:
- **Shared Volume**:

```yaml
  volumes:
    - name: shared-data
      emptyDir: {}
```

- **Init Container 1 (`step1-system-info`)**: Gathers kernel version, node hostname, and timestamp, then writes them to `/work-dir/info.txt`.

- **Init Container 2 (`step2-build-page`)**: Reads `/work-dir/info.txt`, formats an HTML document, and writes `/work-dir/index.html`.

- **Main Container (`web-server`)**: Mounts `shared-data` at Nginx's document root `/usr/share/nginx/html`.

### 2. Deploy the Multi-Init Pod

Deploy the manifest:

```bash
kubectl apply -f /root/manifests/page-generator.yaml
```{{exec target=controlplane}}

> [!NOTE]
> Observe the sequential status progression in the **Pod Monitor** pane below:
> 1. `STATUS: Init:0/2` (Step 1 is running)
> 2. `STATUS: Init:1/2` (Step 1 completed; Step 2 is running)
> 3. `STATUS: PodInitializing` (All init containers finished; Nginx container is starting)
> 4. `STATUS: Running (1/1)` (Pod is fully operational)

<br>

### 3. Inspect Logs Across the Pipeline

Each init container has its own independent log stream. You can inspect each stage of the pipeline:

View the output of the first init container:

```bash
kubectl logs multi-init-web -c step1-system-info
```{{exec target=controlplane}}

View the output of the second init container:

```bash
kubectl logs multi-init-web -c step2-build-page
```{{exec target=controlplane}}

<br>

### 4. Test the Generated Web Page

The main Nginx container now serves the file created by the init containers. Send an HTTP request to Nginx using `wget`:

```bash
kubectl exec multi-init-web -c web-server -- wget -qO- http://localhost:80
```{{exec target=controlplane}}

> [!IMPORTANT]
> Notice that the HTML page contains the exact system metadata (`Kernel`, `Hostname`, `Timestamp`) created during the init stages! The main `web-server` container never needed to know how that page was generated or require the tools to create it.


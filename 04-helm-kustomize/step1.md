### 1. Explore the Local Helm Chart Structure

Helm packages Kubernetes applications into a directory tree called a **Chart**.

Navigate to the Helm manifests directory:

```bash
cd /root/manifests/helm
```{{exec}}

Inspect the contents of the local chart:

```bash
tree nginx-chart/ || find nginx-chart/
```{{exec}}

A minimal chart requires three core components:
1. `Chart.yaml`: Metadata declaring the chart name, description, and semantic version.
2. `values.yaml`: Default configuration values passed into templates.
3. `templates/`: Directory containing Kubernetes YAML files parameterized with Go template directives.

Open and inspect `Chart.yaml`:

```text
/root/manifests/helm/nginx-chart/Chart.yaml
```{{open}}

Open and inspect the default `values.yaml`:

```text
/root/manifests/helm/nginx-chart/values.yaml
```{{open}}

Notice that by default, `replicaCount: 1` is configured for local/development environments.

Open and inspect the deployment template:

```text
/root/manifests/helm/nginx-chart/templates/deployment.yaml
```{{open}}

Notice line 9:
```yaml
spec:
  replicas: {{ .Values.replicaCount }}
```
Helm's template engine interpolates `{{ .Values.replicaCount }}` with whatever value is provided at render time!

<br>

### 2. Inspect External Environment Values Files

In production workflows, charts maintain base defaults in `values.yaml`, while environment-specific parameters are kept in external values files.

Open and inspect the development values file:

```text
/root/manifests/helm/values-dev.yaml
```{{open}}

Open and inspect the production values file:

```text
/root/manifests/helm/values-prod.yaml
```{{open}}

Notice that `values-prod.yaml` specifies `replicaCount: 3`.

<br>

### 3. Dry-Run Template Rendering

Before installing into the cluster, Helm allows you to render the final Kubernetes YAML locally using `helm template`:

```bash
helm template my-nginx ./nginx-chart
```{{exec}}

Compare that to rendering with the production values file:

```bash
helm template my-nginx ./nginx-chart -f values-prod.yaml | grep -C 2 replicas:
```{{exec}}

Notice how the template engine replaces the placeholder with `replicas: 3` without sending any request to Kubernetes.

<br>

### 4. Deploy the Initial Release with Default Values (1 Replica)

Install the chart using the default values (1 replica):

```bash
helm install my-nginx ./nginx-chart
```{{exec}}

Verify the deployment and pod count:

```bash
kubectl get deployment my-nginx
```{{exec}}

Wait for the single pod to become ready:

```bash
kubectl rollout status deployment/my-nginx
kubectl get pods -l app=my-nginx
```{{exec}}

Check the Helm release status:

```bash
helm list
```{{exec}}

Helm records this installation as revision **1**.

<br>

### 5. Upgrade the Release with Production Values (3 Replicas)

Now upgrade the release using `values-prod.yaml`:

```bash
helm upgrade my-nginx ./nginx-chart -f values-prod.yaml
```{{exec}}

Wait for the new replicas to roll out:

```bash
kubectl rollout status deployment/my-nginx
kubectl get pods -l app=my-nginx
```{{exec}}

Verify that **3 pods** are now running:

```bash
kubectl get deployment my-nginx -o jsonpath='{.spec.replicas}{"\n"}'
```{{exec}}

<br>

### 6. Inspect Helm Release History and State Tracking

Helm maintains a full revision history in the cluster:

```bash
helm history my-nginx
```{{exec}}

Notice how Helm tracks:
- **Revision 1**: Initial install (`my-nginx-0.1.0`) with default values.
- **Revision 2**: Upgrade with `values-prod.yaml`.

Inspect the Kubernetes Secret Helm created to track this release:

```bash
kubectl get secrets -l owner=helm
```{{exec}}

Because Helm persists release history inside the cluster, rolling back to Revision 1 is as simple as running `helm rollback my-nginx 1`!

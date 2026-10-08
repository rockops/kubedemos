### 1. Introduction to Kustomize: Template-Free Customization

Unlike Helm, **Kustomize** does not use template syntax (`{{ ... }}`). All files remain 100% valid Kubernetes YAML that any standard linter, validator, or IDE can parse.

Kustomize organizes configurations into:
- **Base**: Standard Kubernetes manifests representing the default application specification.
- **Overlays**: Environment-specific layers (`dev`, `staging`, `prod`) that patch or augment the base.

Navigate to the Kustomize directory:

```bash
cd /root/manifests/kustomize
```{{exec}}

Inspect the directory structure:

```bash
tree base/ overlays/ || find .
```{{exec}}

<br>

### 2. Inspect the Base Manifests

Open and inspect the base Deployment manifest:

```text
/root/manifests/kustomize/base/deployment.yaml
```{{open}}

Notice that unlike Helm, there are no Go template placeholders (`{{ .Values... }}`). The base specifies a standard deployment with `replicas: 1`.

Open and inspect `base/kustomization.yaml`:

```text
/root/manifests/kustomize/base/kustomization.yaml
```{{open}}

This file instructs Kustomize to include `deployment.yaml` in the resource set.

<br>

### 3. Build and Apply Only the Base (1 Replica)

Before applying to the cluster, preview what Kustomize generates using `kubectl kustomize`:

```bash
kubectl kustomize base/
```{{exec}}

Now apply the base configuration directly using `kubectl apply -k`:

```bash
kubectl apply -k base/
```{{exec}}

Wait for the deployment to become ready:

```bash
kubectl rollout status deployment/nginx-kustomize
```{{exec}}

Verify that **1 pod** is running:

```bash
kubectl get deployment nginx-kustomize
kubectl get pods -l app=nginx-kustomize
```{{exec}}

<br>

### 4. Inspect the Production Overlay and Patch

Now let's examine how Kustomize adapts the base for production without touching any files in `base/`.

Open and inspect the production patch:

```text
/root/manifests/kustomize/overlays/prod/replica-patch.yaml
```{{open}}

Notice how concise the patch is:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-kustomize
spec:
  replicas: 3
```
Through **Strategic Merge Patch**, Kustomize only requires the identification keys (`apiVersion`, `kind`, `metadata.name`) and the specific fields you want to override (`replicas: 3`).

Now open and inspect the overlay's `kustomization.yaml`:

```text
/root/manifests/kustomize/overlays/prod/kustomization.yaml
```{{open}}

Notice that it:
1. References `../../base` as its resource source.
2. Directs Kustomize to merge `replica-patch.yaml` into the matching resource.

<br>

### 5. Preview and Apply the Production Overlay (3 Replicas)

Preview the generated YAML from the production overlay:

```bash
kubectl kustomize overlays/prod/ | grep -C 2 replicas:
```{{exec}}

Kustomize dynamically patched the replica count from 1 to 3 while keeping all other specifications from the base intact.

Apply the production overlay to the cluster:

```bash
kubectl apply -k overlays/prod/
```{{exec}}

Wait for the new replicas to roll out:

```bash
kubectl rollout status deployment/nginx-kustomize
```{{exec}}

Verify that **3 pods** are now running:

```bash
kubectl get deployment nginx-kustomize -o jsonpath='{.spec.replicas}{"\n"}'
kubectl get pods -l app=nginx-kustomize
```{{exec}}

Both Helm and Kustomize have successfully scaled their respective workloads from 1 to 3 replicas—Helm via template values, and Kustomize via declarative patches!

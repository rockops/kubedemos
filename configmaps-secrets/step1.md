### 1. Create a ConfigMap

ConfigMaps store configuration artifacts as key-value pairs. They can be created imperatively using `kubectl create configmap` or declaratively with a YAML manifest.

Open and inspect the provided manifest:

```text
/root/manifests/app-config.yaml
```{{open}}

Notice that this ConfigMap defines two scalar keys (`APP_ENV` and `APP_COLOR`) as well as a multi-line configuration file (`app.properties`).

Apply the ConfigMap manifest:

```
kubectl apply -f /root/manifests/app-config.yaml
```{{exec}}

Verify the ConfigMap was created:

```
kubectl get configmap app-config -o yaml
```{{exec}}

<br>

### 2. Inspect the Pod Manifest Consuming ConfigMap as Environment Variables

There are two primary ways to inject ConfigMap values as environment variables:
- **Individual Mapping (`valueFrom.configMapKeyRef`)**: Selects a specific key and maps it to a custom container environment variable name.
- **Bulk Loading (`envFrom.configMapRef`)**: Injects all keys from the ConfigMap directly into the container as environment variables matching the key names.

Open and inspect the Pod manifest:

```text
/root/manifests/pod-configmap-env.yaml
```{{open}}

Deploy the Pod:

```
kubectl apply -f /root/manifests/pod-configmap-env.yaml
```{{exec}}

Wait for the Pod to reach the `Running` state:

```
kubectl wait --for=condition=Ready pod/pod-configmap-env --timeout=60s
```{{exec}}

<br>

### 3. Verify Environment Variables Inside the Container

Now, query the environment variables inside the running container using `kubectl exec`:

```
kubectl exec pod-configmap-env -- env | grep -E 'APPLICATION_ENVIRONMENT|UI_COLOR|APP_ENV|APP_COLOR'
```{{exec}}

Observe the output:
- `APPLICATION_ENVIRONMENT=production`: Injected via `valueFrom.configMapKeyRef`.
- `UI_COLOR=blue`: Injected via `valueFrom.configMapKeyRef`.
- `APP_ENV=production` & `APP_COLOR=blue`: Injected via `envFrom.configMapRef`.

The application inside the container can now read these standard environment variables without needing any Kubernetes-specific client libraries!

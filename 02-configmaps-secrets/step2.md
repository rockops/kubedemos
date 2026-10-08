### 1. Why Mount ConfigMaps as Volumes?

While environment variables are simple, mounting a ConfigMap as a volume provides significant advantages:
1. **File-based Configuration**: Legacy applications or complex servers (like Nginx, Redis, PostgreSQL) expect physical files on disk rather than environment variables.
2. **Multi-line and Structured Files**: JSON, YAML, properties, or INI configuration files can be mounted directly into the filesystem.
3. **Dynamic Updates**: If a mounted ConfigMap is updated, Kubernetes automatically updates the mounted files in the container (via atomic symlink updates) without restarting the Pod. In contrast, environment variables cannot be updated without restarting the container.

<br>

### 2. Inspect the Pod Volume Manifest

Open and inspect the manifest:

```text
/root/manifests/pod-configmap-volume.yaml
```{{open}}

Key fields in this specification:
- `spec.volumes`: Declares a volume named `config-volume` backed by the `app-config` ConfigMap.
- `spec.containers[*].volumeMounts`: Mounts `config-volume` at `/etc/config` with `readOnly: true`.

Deploy the Pod:

```
kubectl apply -f /root/manifests/pod-configmap-volume.yaml
```{{exec}}

Wait for the Pod to be ready:

```
kubectl wait --for=condition=Ready pod/pod-configmap-volume --timeout=60s
```{{exec}}

<br>

### 3. Inspect Mounted Files Inside the Container

List the files created in `/etc/config`:

```
kubectl exec pod-configmap-volume -- ls -la /etc/config
```{{exec}}

Notice how Kubernetes created a file for each key in the ConfigMap:
- `APP_COLOR`
- `APP_ENV`
- `app.properties`

Notice also the `..data` symlink. Kubernetes uses symbolic links to perform atomic file updates when the ConfigMap changes!

Now view the content of the mounted configuration files:

```
kubectl exec pod-configmap-volume -- cat /etc/config/app.properties
```{{exec}}

Read the scalar value files as well:

```
kubectl exec pod-configmap-volume -- cat /etc/config/APP_COLOR; echo ""
kubectl exec pod-configmap-volume -- cat /etc/config/APP_ENV; echo ""
```{{exec}}

The container has full read access to these files as if they were baked directly into the image!

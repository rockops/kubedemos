### 1. Consuming Secrets in Workloads

Just like ConfigMaps, Secrets can be consumed in two main ways:
1. **As Environment Variables**: Individual keys mapped to environment variables (`valueFrom.secretKeyRef`) or bulk injected (`envFrom.secretRef`).
2. **Mounted as Volumes**: Mounted as files into the container's filesystem (`volumes.secret`).

When Kubernetes mounts a Secret (either into environment variables or volume files), it **automatically decodes the Base64 values** into plaintext for the application!

<br>

### 2. Inspect the Pod Manifest Consuming the Secret

Open and inspect `/root/manifests/pod-secret-env-volume.yaml`:

```text
/root/manifests/pod-secret-env-volume.yaml
```{{open}}

Notice two important security features in this manifest:
- **Environment Variables**: `DATABASE_USER` and `DATABASE_PASS` reference `db-credentials` using `secretKeyRef`.
- **Volume Mount**: Mounted at `/etc/secrets` with `readOnly: true`.
- **Restricted Permissions (`defaultMode: 256`)**: In octal, `256` decimal equals `0400` permissions (read-only for the container owner, no read/write access for group or others).

Deploy the Pod:

```
kubectl apply -f /root/manifests/pod-secret-env-volume.yaml
```{{exec}}

Wait for the Pod to be ready:

```
kubectl wait --for=condition=Ready pod/pod-secret-demo --timeout=60s
```{{exec}}

<br>

### 3. Verify Secret Environment Variables Inside the Container

Execute `env` inside the pod to verify that Kubernetes automatically provided the decoded plaintext values:

```
kubectl exec pod-secret-demo -- env | grep -E 'DATABASE_USER|DATABASE_PASS'
```{{exec}}

Both values are available in plaintext inside the container without your application needing to decode Base64!

<br>

### 4. Verify Secret Volume Files & Permissions

List the contents of `/etc/secrets` inside the pod:

```
kubectl exec pod-secret-demo -- ls -la /etc/secrets
```{{exec}}

Notice the file permissions:
- The files `-r--------` (`0400`) are accessible only by the root/process owner, satisfying security best practices.

Now, read the password file directly:

```
kubectl exec pod-secret-demo -- cat /etc/secrets/DB_PASSWORD; echo ""
```{{exec}}

And read the username file:

```
kubectl exec pod-secret-demo -- cat /etc/secrets/DB_USERNAME; echo ""
```{{exec}}

The container has seamless, secure access to its database credentials through both environment variables and mounted files!

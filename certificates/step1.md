### 1. Verify Cluster Nodes

Ensure your Kubernetes node is ready:

```
kubectl get nodes
```{{exec}}

<br>

### 2. Create the Namespaces

We need two isolated namespaces: `public` and `private`.

Inspect the manifest at `/root/manifests/namespaces.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: public
---
apiVersion: v1
kind: Namespace
metadata:
  name: private
```

Apply the namespaces manifest:

```
kubectl apply -f /root/manifests/namespaces.yaml
```{{exec}}

<br>

### 3. Configure the ServiceAccount and RBAC

We create a ServiceAccount named `public-sa` inside the `public` namespace.
We then create a `Role` granting read permissions (`get`, `list`, `watch`) on pods, and bind it to `public-sa`.

Inspect the RBAC manifest at `/root/manifests/rbac.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: public-sa
  namespace: public
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: public-reader
  namespace: public
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: public-reader-binding
  namespace: public
subjects:
- kind: ServiceAccount
  name: public-sa
  namespace: public
- kind: User
  name: public-sa
- kind: User
  name: system:serviceaccount:public:public-sa
roleRef:
  kind: Role
  name: public-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply the RBAC manifest:

```
kubectl apply -f /root/manifests/rbac.yaml
```{{exec}}

<br>

### 4. Deploy Sample Pods

Deploy test pods in both namespaces to test permissions against:

```
kubectl apply -f /root/manifests/sample-pods.yaml
```{{exec}}

Verify that the pods are running:

```
kubectl get pods -n public
kubectl get pods -n private
```{{exec}}

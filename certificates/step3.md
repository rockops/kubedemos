### 1. Build a Dedicated Kubeconfig File

We will generate a standalone kubeconfig file at `/root/public-sa.kubeconfig` containing:
- Cluster endpoint with embedded CA certificate
- Client credentials with embedded certificate and private key
- Context pointing to the `public` namespace

First, determine the API server endpoint from the current cluster configuration:

```
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "API Server: ${APISERVER}"
```{{exec}}

<br>

### 2. Configure Cluster and Credentials

Set the cluster configuration and embed the CA certificate:

```
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl config --kubeconfig=/root/public-sa.kubeconfig set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server="${APISERVER}"
```{{exec}}

Set client credentials and embed the newly generated certificate and private key:

```
kubectl config --kubeconfig=/root/public-sa.kubeconfig set-credentials public-sa \
  --client-certificate=/root/public-sa.crt \
  --client-key=/root/public-sa.key \
  --embed-certs=true
```{{exec}}

Create and switch to the context:

```
kubectl config --kubeconfig=/root/public-sa.kubeconfig set-context public-sa-context \
  --cluster=kubernetes \
  --user=public-sa \
  --namespace=public

kubectl config --kubeconfig=/root/public-sa.kubeconfig use-context public-sa-context
```{{exec}}

<br>

### 3. Demo Access to the Public Namespace

Authenticate using the new kubeconfig and list pods in the `public` namespace:

```
kubectl get pods --kubeconfig=/root/public-sa.kubeconfig -n public
```{{exec}}

> **Result:** This command succeeds! The user `public-sa` is authorized by the `public-reader` role.

<br>

### 4. Demo Access Denied in the Private Namespace

Now attempt to list pods in the `private` namespace:

```
kubectl get pods --kubeconfig=/root/public-sa.kubeconfig -n private
```{{exec}}

> **Result:** This command fails with:
> `Error from server (Forbidden): pods is forbidden: User "public-sa" cannot list resource "pods" in API group "" in the namespace "private"`

<br>

### 5. Verify Permissions Using `auth can-i`

Check the user's effective permissions across both namespaces:

```
kubectl auth can-i list pods -n public --kubeconfig=/root/public-sa.kubeconfig
kubectl auth can-i list pods -n private --kubeconfig=/root/public-sa.kubeconfig
```{{exec}}

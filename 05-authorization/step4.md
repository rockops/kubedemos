### 1. How Certificate Revocation Works in Kubernetes

In standard PKI systems, certificates can be revoked using Certificate Revocation Lists (CRL) or OCSP. However:

> **Important Kubernetes Security Concept:**
> The Kubernetes API server **does not support CRLs or OCSP natively**. Once an X.509 client certificate is signed by the cluster CA, the API server will cryptographically validate and authenticate it until it expires.
> 
> Deleting the `CertificateSigningRequest` object does **not** invalidate the certificate held by the client.
> 
> Therefore, in Kubernetes, **revoking access for a compromised or offboarded certificate is achieved at the Authorization (RBAC) layer**.

<br>

### 2. Demonstrate: Deleting the CSR Does NOT Invalidate the Certificate

Let's test this behavior. First, delete the `CertificateSigningRequest` resource from the cluster:

```
kubectl delete csr public-sa-csr
```{{exec}}

Confirm that the CSR no longer exists:

```
kubectl get csr public-sa-csr
```{{exec}}

Now, attempt to access the `public` namespace again using the client certificate in our kubeconfig:

```
kubectl get pods --kubeconfig=/tmp/public-sa.kubeconfig -n public
```{{exec}}

> **Observation:** The request **still succeeds**! The API server validates the client certificate against the CA directly without checking for the existence of the CSR.

<br>

### 3. Revoke Access via RBAC

To effectively revoke access for `public-sa`, we remove its authorization binding.

Delete the `RoleBinding` in the `public` namespace:

```
kubectl delete rolebinding public-reader-binding -n public
```{{exec}}

Verify that the binding has been removed:

```
kubectl get rolebinding -n public
```{{exec}}

<br>

### 4. Verify Access is Now Denied

Now attempt to query the `public` namespace using the client certificate again:

```
kubectl get pods --kubeconfig=/tmp/public-sa.kubeconfig -n public
```{{exec}}

> **Result:** Access is now **forbidden**!
> ```
> Error from server (Forbidden): pods is forbidden: User "public-sa" cannot list resource "pods" in API group "" in the namespace "public"
> ```

<br>

### 5. Confirm Effective Permissions with `auth can-i`

Check the user's permission in the `public` namespace:

```
kubectl auth can-i list pods -n public --kubeconfig=/tmp/public-sa.kubeconfig
```{{exec}}

> **Result:** `no`

The certificate is now effectively revoked from performing actions within the cluster.

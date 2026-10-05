<br>

### Welcome to Kubernetes Certificate Authentication!

In Kubernetes, users and clients can authenticate using **X.509 Client Certificates** signed by the cluster's Certificate Authority (CA).

In this scenario, you will:
1. **Create two namespaces**: `public` and `private`.
2. **Configure RBAC**: Create a ServiceAccount and grant it read permissions only in the `public` namespace.
3. **Generate & Sign an X.509 Certificate**: Submit a `CertificateSigningRequest` to Kubernetes and approve it using `kubectl`.
4. **Build a dedicated Kubeconfig**: Configure client credentials and contexts.
5. **Verify Access**: Demonstrate that the certificate grants access to `public`, but denies access to `private`.
6. **Revoke Access**: Understand how certificate revocation works in Kubernetes and invalidate access to the `public` namespace.

Let's begin!

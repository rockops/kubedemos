### 1. Understanding the Kubernetes CSR API

Instead of manually accessing cluster CA private keys on the control plane, Kubernetes provides the **`CertificateSigningRequest` (CSR) API**.

This allows users or processes to:
1. Submit a base64-encoded PKCS#10 CSR to the Kubernetes API.
2. Have an administrator inspect and approve it using `kubectl certificate approve`.
3. Have the `kube-controller-manager` automatically sign the certificate.
4. Retrieve the issued certificate directly via `kubectl`.

<br>

### 2. Generate a Private Key and CSR

Generate a 2048-bit RSA private key:

```
openssl genrsa -out /root/public-sa.key 2048
```{{exec}}

Create a Certificate Signing Request with Common Name `/CN=public-sa`:

```
openssl req -new -key /root/public-sa.key -out /root/public-sa.csr -subj "/CN=public-sa/O=dev"
```{{exec}}

<br>

### 3. Submit the CSR to the Kubernetes API

Encode the CSR in base64 and create a `CertificateSigningRequest` resource in the cluster:

```
CSR_BASE64=$(cat /root/public-sa.csr | base64 | tr -d '\n')
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: public-sa-csr
spec:
  request: ${CSR_BASE64}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
```{{exec}}

Verify that the CSR was created and is currently `Pending`:

```
kubectl get csr
```{{exec}}

<br>

### 4. Approve the CSR Using `kubectl`

As an administrator, approve the certificate request:

```
kubectl certificate approve public-sa-csr
```{{exec}}

Check the CSR again to see that it is now `Approved,Issued`:

```
kubectl get csr public-sa-csr
```{{exec}}

<br>

### 5. Extract and Verify the Signed Certificate

Extract the issued certificate from the CSR resource and decode it into `/root/public-sa.crt`:

```
kubectl get csr public-sa-csr -o jsonpath='{.status.certificate}' | base64 -d > /root/public-sa.crt
```{{exec}}

Inspect the subject and issuer of the certificate signed by Kubernetes:

```
openssl x509 -in /root/public-sa.crt -text -noout | grep -E "Issuer:|Subject:"
```{{exec}}

Verify the certificate against the cluster CA certificate:

```
openssl verify -CAfile /etc/kubernetes/pki/ca.crt /root/public-sa.crt
```{{exec}}

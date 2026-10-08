### 1. Kubernetes Secrets & The Base64 Mechanism

Kubernetes Secrets are intended for sensitive data like passwords, tokens, or keys.

When stored in Kubernetes:
- The `data` field stores values as **Base64-encoded strings**.
- The `stringData` field is a write-only convenience field in manifests where you can provide plaintext values; the API server automatically converts them to Base64 in `data` upon submission.

> **CRITICAL SECURITY NOTE**: Base64 is an **encoding scheme**, **NOT encryption**! It protects sensitive values from accidental shoulder surfing or casual log scraping, but anyone who can read the Secret can immediately decode it. True security requires configuring **Encryption at Rest** in `kube-apiserver` (or using external KMS/Vault integrations).

<br>

### 2. Inspect and Apply the Secret Manifest

Open and inspect the manifest:

```text
/root/manifests/db-secret.yaml
```{{open}}

Notice that we use `stringData` with human-readable plaintext values:
- `DB_USERNAME: "db_admin"`
- `DB_PASSWORD: "SuperSecretPassword123!"`

Apply the manifest:

```
kubectl apply -f /root/manifests/db-secret.yaml
```{{exec}}

<br>

### 3. Inspect the Stored Secret & Observe Base64 Encoding

Now retrieve the stored Secret object from the Kubernetes API in YAML format:

```
kubectl get secret db-credentials -o yaml
```{{exec}}

Notice what happened:
1. The `stringData` field disappeared.
2. A `data` field was created with Base64-encoded values:
   - `DB_USERNAME`
   - `DB_PASSWORD`

<br>

### 4. Manually Encode and Decode Secret Values

Let's verify the Base64 encoding and decoding directly in your terminal.

Encode a plaintext password to Base64 using Linux `base64`:

```
echo -n "SuperSecretPassword123!" | base64
```{{exec}}

Compare this output with the value stored in `.data.DB_PASSWORD` in the Secret!

Now extract and decode the password directly from the Kubernetes cluster:

```
kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
echo ""
```{{exec}}

Decode the username as well:

```
kubectl get secret db-credentials -o jsonpath='{.data.DB_USERNAME}' | base64 --decode
echo ""
```{{exec}}

You have successfully decoded the stored credentials! Next, let's inject this secret into a running workload.

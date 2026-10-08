<br>

### Congratulations!

You have completed the **Kubernetes ConfigMaps & Secrets** scenario!

### Summary of Key Concepts Learned:

1. **ConfigMaps**:
   - Used for non-sensitive application settings, feature flags, and configuration files.
   - Declarative creation via manifests using scalar keys or multi-line configuration blocks (`app.properties`).

2. **Environment Variable Injection**:
   - `valueFrom.configMapKeyRef` & `valueFrom.secretKeyRef`: Select individual keys and map to custom environment variable names.
   - `envFrom.configMapRef` & `envFrom.secretRef`: Injects all keys as environment variables in bulk.

3. **Volume Mounts**:
   - Ideal for configuration files required by legacy or file-based services.
   - Each key in the ConfigMap or Secret becomes a separate file inside the mounted directory.
   - Mounted ConfigMap files support dynamic updates via atomic symbolic links (`..data`).

4. **Secrets & Base64 Security**:
   - Secrets store values as **Base64** strings in `.data`.
   - Manifests can accept human-readable plaintext via `stringData` which the API server automatically encodes.
   - **Base64 is an encoding, not encryption!** True security requires Kubernetes Encryption at Rest (`EncryptionConfiguration` on `kube-apiserver`) or external KMS tools (HashiCorp Vault, External Secrets Operator).
   - Kubernetes **automatically decodes** Base64 values when presenting them to containers as environment variables or volume files.
   - File permissions on mounted secrets can be hardened using `defaultMode: 256` (`0400` octal).

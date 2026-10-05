<br>

### Welcome to the Kubernetes ConfigMaps & Secrets Demo!

In cloud-native applications, separating application code from configuration is one of the foundational principles of the **Twelve-Factor App**. Kubernetes provides two core API resources for configuration management:

- **ConfigMaps**: Store non-confidential key-value pairs, configuration files, and environment settings.
- **Secrets**: Store confidential and sensitive data, such as database credentials, API tokens, and TLS keys.

In this hands-on scenario, you will learn how to:
1. **Create and Consume ConfigMaps via Environment Variables**: Create a ConfigMap and inject values into container environment variables both individually (`valueFrom`) and in bulk (`envFrom`).
2. **Mount ConfigMaps as Volumes**: Expose configuration files to containers as mounted files and verify their contents dynamically.
3. **Manage Secrets & Understand Base64 Encoding**: Create Kubernetes Secrets imperatively and declaratively, inspect the API representation, and decode Base64 data values.
4. **Consume Secrets via Environment Variables and Volumes**: Securely pass sensitive credentials to containers as environment variables and restricted-permission filesystem mounts (`defaultMode: 0400`).

Let's get started!

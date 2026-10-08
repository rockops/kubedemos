# Congratulations! 🎉

You have successfully mastered both **Mutating** and **Validating Admission Controllers** in Kubernetes!

---

### Comparison: Mutating vs. Validating Webhooks

| Feature | Mutating Admission Webhook | Validating Admission Webhook |
|---|---|---|
| **Execution Order** | **First** (before schema validation) | **Second** (after schema validation) |
| **Object Modification** | ✅ Can alter, add, or remove fields | ❌ Cannot alter the object |
| **Response Format** | Base64-encoded RFC 6902 JSONPatch | Boolean (`allowed: true/false`) + Status message |
| **Typical Use Cases** | Injecting sidecars, default settings, adding labels/annotations | Enforcing replica limits, security contexts, image registry whitelists |
| **Real-World Examples** | Istio Envoy injection, Vault Agent Injector | OPA Gatekeeper, Kyverno, PodSecurityAdmission |

---

### Key Architectural Takeaways

1. **The Admission Lifecycle**:
   - Every API request goes through Authentication & Authorization $\rightarrow$ Mutating Webhooks $\rightarrow$ Schema Validation $\rightarrow$ Validating Webhooks $\rightarrow$ `etcd`.
2. **Namespace Scoping**:
   - `namespaceSelector` prevents admission controllers from intercepting or breaking critical control plane components in namespaces like `kube-system`.
3. **URL Parsing & Robustness**:
   - Admission webhooks receive query parameters like `?timeout=5s` from the API server. Production webhook handlers must use proper URL parsing (like `urllib.parse.urlparse`) to isolate endpoints.

---

### Clean Up (Optional)

To remove all demo resources:

```bash
kubectl delete mutatingwebhookconfiguration sidecar-injector-webhook
kubectl delete validatingwebhookconfiguration replica-limit-webhook
kubectl delete ns dev prod webhook-system
```{{exec}}

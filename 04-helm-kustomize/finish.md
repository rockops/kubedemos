<br>

### Congratulations! 🎉

You have successfully explored both **Helm** and **Kustomize**, understanding their internal principles, workflows, and core architectural differences.

---

### What You Covered:

1. **Helm (Template-Driven Package Manager)**:
   - Created a local chart containing `Chart.yaml`, `values.yaml`, and `templates/deployment.yaml`.
   - Used Go template interpolation (`{{ .Values.replicaCount }}`) to inject values.
   - Deployed release `my-nginx` with default development settings (**1 replica**).
   - Upgraded the release to production (**3 replicas**) using an external `values-prod.yaml`.
   - Explored Helm's state management, revision tracking (`helm history`), and cluster Secrets.

2. **Kustomize (Overlay- & Patch-Driven Customizer)**:
   - Created standard, template-free Kubernetes YAML manifests in `base/` (**1 replica**).
   - Applied the base directly using native `kubectl apply -k`.
   - Created a production overlay (`overlays/prod/`) with a Strategic Merge Patch (`replica-patch.yaml`) to scale to **3 replicas**.
   - Verified that Kustomize requires no template placeholders and operates completely stateless on the client side.

3. **Core Architectural Differences Summary**:

| Dimension | Helm | Kustomize |
|---|---|---|
| **Design Paradigm** | Template interpolation & packaging | Declarative bases & structural overlays |
| **Manifest Format** | Go `text/template` files (can be invalid YAML until rendered) | Pure, valid Kubernetes YAML at all times |
| **CLI & Dependencies** | Requires standalone `helm` CLI binary | Built directly into `kubectl` (`kubectl apply -k`) |
| **State Storage** | Stateful: stores release revisions as cluster Secrets | Stateless: no cluster state; relies on Git as source of truth |
| **Primary Strength** | Distributing reusable third-party software packages | Multi-environment application configuration in GitOps workflows |

---

### Next Steps:
- Experiment with Kustomize's `commonLabels` and `namePrefix` transformers in `overlays/prod/kustomization.yaml`.
- Try Helm's template helper functions (`_helpers.tpl`) and conditional blocks (`{{- if .Values.ingress.enabled }}`).
- Explore the **Helm + Kustomize hybrid pattern** using tools like Argo CD or Flux for production GitOps pipelines.

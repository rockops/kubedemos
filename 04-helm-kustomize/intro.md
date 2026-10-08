<br>

### Welcome to Helm vs Kustomize Demo!

When managing Kubernetes applications across multiple environments (Development, Staging, Production), managing raw YAML manifests quickly leads to code duplication, drift, and errors.

Two leading tools in the Kubernetes ecosystem solve this problem with fundamentally different philosophies:

1. **Helm (The Package Manager)**:
   - **Paradigm**: Template-driven configuration.
   - **Mechanism**: Parameterizes YAML manifests using Go `text/template` engine (`{{ .Values.replicaCount }}`).
   - **Features**: Packages applications into versioned charts, tracks deployment lifecycle as "releases" stored in cluster Secrets, supports rollback and dependencies.

2. **Kustomize (The Declarative Customizer)**:
   - **Paradigm**: Overlay- and patch-driven configuration.
   - **Mechanism**: Uses pure, standard Kubernetes YAML without any template placeholders. Composes a common `base` and applies environment-specific `overlays` using Strategic Merge Patches.
   - **Features**: Built directly into `kubectl` (`kubectl apply -k`), completely stateless, and natively GitOps-friendly.

---

### In this scenario, you will:

1. **Step 1 - Helm**:
   - Inspect a local Helm chart with an Nginx deployment and parameterized replicas (`.Values.replicaCount`).
   - Deploy a release using the chart's default development values (**1 replica**).
   - Upgrade the release using an external production values file `values-prod.yaml` (**3 replicas**).
   - Inspect Helm's release revisions and secret-based state tracking.

2. **Step 2 - Kustomize**:
   - Inspect a template-free `base` deployment (**1 replica**).
   - Deploy the base directly using `kubectl apply -k`.
   - Inspect the production overlay (`overlays/prod`) with a replica patch (**3 replicas**).
   - Apply the overlay and observe the declarative patch in action.

3. **Step 3 - Principles & Differences**:
   - Compare template rendering (`helm template`) vs declarative building (`kubectl kustomize`).
   - Compare Helm's stateful release management (`helm history`, release Secrets) with Kustomize's client-side stateless approach.
   - Learn the operational trade-offs and when to choose each tool.

Let's begin with Step 1 to package and deploy with Helm!

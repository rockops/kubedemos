# CLAUDE.md - Killercoda Kubernetes Scenarios Guide

This document serves as the persistent memory, architectural specification, and authoring handbook for developing interactive Kubernetes training scenarios in the `kubedemos` repository for the **Killercoda** platform (and Rockdemo).

---

## 1. Project Overview & Architecture

`kubedemos` contains modular, interactive Kubernetes training scenarios runnable on the [Killercoda](https://killercoda.com) interactive learning platform.

### Folder Structure Convention
Each scenario is completely self-contained in its own top-level directory:

```
kubedemos/
├── <scenario-name>/
│   ├── index.json             # Scenario metadata, step definitions, backend, assets
│   ├── intro.md               # Scenario introduction & learning objectives
│   ├── step1.md               # Step 1 instructions & interactive command blocks
│   ├── step1_verify.sh        # Verification script for step 1 (returns 0 on success)
│   ├── step2.md               # Step 2 instructions
│   ├── step2_verify.sh        # Step 2 verification script
│   ├── ...
│   ├── finish.md              # Wrap-up, concepts reviewed, next steps
│   └── assets/                # Scenario assets copied to target VM
│       └── manifests/         # Kubernetes YAML manifests loaded onto the host
└── CLAUDE.md                  # This handbook
```

---

## 2. Scenario Configuration (`index.json`)

The `index.json` file is the core descriptor interpreted by the Killercoda engine.

### Schema Reference

```json
{
  "title": "Human-Readable Scenario Title",
  "description": "Concise 1-2 sentence description shown in the scenario card/catalog",
  "details": {
    "intro": {
      "text": "intro.md",
      "foreground": "intro_foreground.sh",
      "background": "intro_background.sh"
    },
    "steps": [
      {
        "title": "1. Descriptive Title for Step 1",
        "text": "step1.md",
        "verify": "step1_verify.sh"
      },
      {
        "title": "2. Descriptive Title for Step 2",
        "text": "step2.md",
        "verify": "step2_verify.sh"
      }
    ],
    "finish": {
      "text": "finish.md"
    },
    "assets": {
      "host01": [
        {
          "file": "manifests/*",
          "target": "/root",
          "chmod": "+w"
        }
      ]
    }
  },
  "backend": {
    "imageid": "kubernetes-kubeadm-1node"
  },
  "interface": {
    "layout": "ide"
  }
}
```

### Supported Backend Image IDs
- `kubernetes-kubeadm-1node`: Single-node Kubernetes cluster (Control plane + worker on `host01`). Standard for most demos.
- `kubernetes-kubeadm-2nodes`: Two-node Kubernetes cluster (Control plane `host01` + worker `node01`). Ideal for scheduling, pod placement, node affinity, multi-node networking.
- `ubuntu`: Bare Ubuntu Linux environment (useful for container runtime, low-level networking, or custom setups).

### Assets Mapping & The Target Directory Rule
- Assets are declared per target machine (`host01` or `node01`).
- Source paths (`"file"`) are relative to the scenario's `assets/` directory (e.g. `"manifests/*"`).
- Permissions (`"chmod"`): Optional permissions flag, e.g. `"+x"` for shell scripts, `"+w"` for editable manifests.

> [!IMPORTANT]
> **The Assets Target Rule (Preserved Subpath Trick)**:
> Wildcard patterns (e.g. `"file": "manifests/*"`) preserve their full path relative to `assets/` under `target`.
> Because each file keeps its `manifests/` prefix:
> - **CORRECT**: `"target": "/root"` $\rightarrow$ files land in `/root/manifests/...`
> - **WRONG**: `"target": "/root/manifests"` $\rightarrow$ files land in `/root/manifests/manifests/...`
> **Always set `"target": "/root"`** when mapping `"file": "manifests/*"`.

---

## 3. Killercoda & rockDemo Markdown Syntax & Interactive Directives

Killercoda and rockDemo extend standard Markdown with interactive directives:

### Code Execution & File Opening Directives
| Syntax | Behavior in UI |
|---|---|
| `` `command`{{exec}} `` | Clicking executes the command directly in the active terminal. |
| ```` ```bash\ncommand\n```{{exec}} ```` | Clicking executes all commands in the block. |
| `` `command`{{exec interrupt}} `` | Sends `Ctrl+C` first to terminate any running process, then executes the command. |
| ```` ```bash\ncommand\n```{{exec interrupt}} ```` | Interrupts active command and executes the multi-line block. |
| ```` ```text\n/root/manifests/app.yaml\n```{{open}} ```` | **📂 Open file**: Opens the referenced file directly in the editor. In rockDemo, container paths under assets map to the live host copy. |
| `` `text` `` | Default inline code is copyable on click. |
| `` `text`{{}} `` | Disables click-to-copy behavior. |
| ```` ```yaml\ncontent\n```{{copy}} ```` | Explicit copy-to-clipboard button on code block. |

> [!TIP]
> **Always use `{{open}}` instead of `cat`**:
> Whenever guiding learners to inspect or edit a manifest or asset file, do **NOT** use `cat /path/file` in a terminal block.
> Always use an `{{open}}` block:
> ````markdown
> Open and inspect the manifest:
> ```text
> /root/manifests/app-config.yaml
> ```{{open}}
> ````

### Dropdown Tips & Solutions
Use HTML `<details>` and `<summary>` tags for expandable hints or answers:
```markdown
<details><summary>Tip</summary>

Inspect the pod using:
```bash
kubectl describe pod my-pod
```{{exec}}

</details>

<details><summary>Solution</summary>

```bash
kubectl apply -f /root/manifests/solution.yaml
```{{exec}}

</details>
```

---

## 4. Verification Scripts Standards (`step*_verify.sh`)

Every step with a `"verify"` field in `index.json` executes a verification script when the user clicks the "Verify" button (or when Killercoda runs automatic verification).

### Verification Principles
1. **Exit Codes**:
   - Exit `0`: Step completed successfully (turns step green).
   - Exit non-zero (`!= 0`): Step failed or requirements not yet met.
2. **Silent & Fast**:
   - Redirect stdout and stderr (`>/dev/null 2>&1`) unless debugging output is helpful.
   - Keep execution time under 2 seconds.
3. **Idempotent & Non-Destructive**:
   - Never mutate cluster state during verification. Only read (`kubectl get`, `kubectl wait`, `grep`, `test`, `stat`).
4. **Resilient Checks**:
   - Use specific jsonpath, label selectors, or namespace flags.
   - Check both existence and status (e.g., Pod is `Running` or `Ready`, Service has `endpoints`).

### Common Verification Patterns

```bash
#!/bin/bash
# 1. Check namespace existence
kubectl get ns dev >/dev/null 2>&1 && kubectl get ns prod >/dev/null 2>&1

# 2. Check pod readiness
kubectl get pod my-nginx -n default -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"

# 3. Check service and endpoints
kubectl get svc my-service >/dev/null 2>&1 && \
  test $(kubectl get endpoints my-service -o jsonpath='{.subsets[*].addresses[*].ip}' | wc -w) -gt 0

# 4. Check RBAC binding
kubectl get rolebinding public-reader-binding -n public >/dev/null 2>&1

# 5. Check file existence & permissions
test -f /root/cert.pem && stat -c "%a" /root/cert.key | grep -E "600|400"
```

---

## 5. Existing Scenarios in `kubedemos`

| Scenario Folder | Topic & Objectives | Backend | Key Manifests / Assets |
|---|---|---|---|
| `01-basic/` | **Namespaces Isolation**: Resource scoping, name collision avoidance, separate images per namespace, lifecycle isolation. | `kubernetes-kubeadm-1node` | `assets/manifests/` (pod definitions in dev & prod) |
| `02-configmaps-secrets/` | **ConfigMaps & Secrets**: ConfigMap creation, environment variable injection (`valueFrom`, `envFrom`), volume mounts, Secret creation (`stringData`), Base64 encoding/decoding, secure consumption (`defaultMode: 0400`). | `kubernetes-kubeadm-1node` | `assets/manifests/` (`app-config.yaml`, `pod-configmap-env.yaml`, `pod-configmap-volume.yaml`, `db-secret.yaml`, `pod-secret-env-volume.yaml`) |
| `03-service/` | **Services & Networking**: Direct Pod IP limits, ClusterIP creation, Endpoints/EndpointSlices, CoreDNS resolution, NodePort external access, Replica load balancing, LoadBalancer services. | `kubernetes-kubeadm-1node` | `assets/manifests/` (`clusterip-service.yaml`, `nodeport-service.yaml`, `webapp-deployment.yaml`, `loadbalancer-service.yaml`) |
| `04-helm-kustomize/` | **Helm vs Kustomize**: Template-driven packaging (Helm charts, values parameterization, release upgrades) vs overlay-driven customization (Kustomize base, strategic merge patches, client-side generation). | `kubernetes-kubeadm-1node` | `assets/manifests/` (`helm/` chart & values files, `kustomize/` base & prod overlay) |
| `05-authorization/` | **Certificate Authentication & RBAC**: Generating X.509 client key/CSR, signing via Kubernetes CA, building custom kubeconfig contexts, namespace-scoped RBAC, access revocation. | `kubernetes-kubeadm-1node` | `assets/manifests/` (`namespaces.yaml`, `rbac.yaml`, `sample-pods.yaml`) |
| `06-admission/` | **Kubernetes Admission Controllers (Mutating & Validating)**: In-cluster Python webhook server, dynamic RFC 6902 JSONPatch sidecar injection (5s heartbeat), validating webhook policy enforcement (blocking deployments > 5 replicas) in labeled namespaces. | `kubernetes-kubeadm-1node` | `assets/manifests/` (`injector.py`, `webhook-server.yaml`, `mutating-webhook.yaml`, `validating-webhook.yaml`, `sample-app.yaml`, `deployment-valid.yaml`, `deployment-invalid.yaml`, `setup-tls.sh`) |
| `07-probes/` | **Pod Probes Lifecycle (Startup, Readiness & Liveness)**: Gating container readiness via startup probes, understanding running vs ready states with readiness probes, triggering self-healing restarts with liveness probes, and observing lifecycle reset upon restart. | `kubernetes-kubeadm-1node` | `assets/manifests/` (`pod-probes.yaml`) |
| `08-k3d/` | **Lightweight Kubernetes with k3d**: Bootstrapping a k3s cluster inside Docker using k3d on Ubuntu, caching binaries in `/rockdemo`, background/foreground synchronization, and validating cluster readiness and workloads. | `ubuntu` | `assets/manifests/` (`test-pod.yaml`) |
| `10-kind/` | **Local Kubernetes with kind**: Bootstrapping a local Kubernetes cluster inside Docker using kind on Ubuntu, caching binaries in `/rockdemo`, and inspecting cluster workloads and namespaces. | `ubuntu` | `assets/manifests/` (`test-pod.yaml`) |
| `11-init/` | **Kubernetes Init Containers Lifecycle**: Gating application container startup with dependency checks, dynamic status tracking (`Init:0/1` -> `Running`), multi-stage data generation with shared volumes (`emptyDir`), and observing failure semantics (`CrashLoopBackOff`) with split-terminal monitoring. | `kubernetes-kubeadm-1node` | `assets/manifests/` (`web-portal.yaml`, `db-service.yaml`, `page-generator.yaml`, `faulty-init.yaml`) |
| `12-requests-limits/` | **Compute Resources: Requests, Limits & OOMKill**: Observing failed scheduling due to excessive requests (`Pending`), QoS classes classification (`Burstable`), runtime memory limit tripping with Linux OOMKiller (`exit code 137`), and right-sizing memory limits. | `kubernetes-kubeadm-1node` | `assets/manifests/` (`oversized-pod.yaml`, `rightsized-pod.yaml`, `memory-hog.yaml`, `memory-fixed.yaml`) |
| `13-volumes/` | **Kubernetes Volumes: emptyDir, PersistentVolumes & Dynamic Provisioning**: Ephemeral volume sharing between containers with `emptyDir`, static `hostPath` PV/PVC binding, writing and validating files on the host node filesystem (`/mnt/data`), and dynamic volume provisioning via `StorageClass` (`local-path`). | `kubernetes-kubeadm-1node` | `assets/manifests/` (`pod-emptydir.yaml`, `pv-hostpath.yaml`, `pvc-static.yaml`, `pod-pvc-static.yaml`, `pvc-dynamic.yaml`, `pod-dynamic.yaml`, `local-path-storage.yaml`) |
| `14-gateway-api/` | **Kubernetes Gateway API**: Role-oriented ingress architecture (`GatewayClass`, `Gateway`, `HTTPRoute`), NGINX Gateway Fabric controller with LoadBalancer exposure and auto IP assigner, path prefix routing with `URLRewrite`, declarative canary traffic splitting (80/20 weights), and header-based QA routing with `ResponseHeaderModifier` filters. | `kubernetes-kubeadm-1node` | `assets/manifests/` (`gateway-crds.yaml`, `ngf-crds.yaml`, `ngf-deploy.yaml`, `lb-controller.sh`, `gateway.yaml`, `sample-apps.yaml`, `httproute-path.yaml`, `httproute-canary.yaml`, `httproute-header.yaml`, `setup-gateway.sh`) |

---

## 6. Authoring Workflow: Creating a New Scenario

When creating a new scenario in `kubedemos`, follow these steps:

### Step 1: Create Directory Structure
```bash
mkdir -p kubedemos/<scenario-id>/assets/manifests
```

### Step 2: Formulate Pedagogical Objective & Outline
- **Target Concept**: What core Kubernetes mechanic is being taught?
- **Duration**: Target 5-15 minutes (typically 3 to 5 steps).
- **Structure**:
  1. `intro.md`: Scenario goal, prerequisite knowledge, cluster readiness check.
  2. `step1.md`: Baseline setup / initial inspection / problem introduction.
  3. `step2.md` ... `stepN.md`: Hands-on resolution / progressive building.
  4. `finish.md`: Key takeaways, architecture recap, real-world context.

### Step 3: Write Kubernetes Manifests (`assets/manifests/`)
- Keep manifests clean, standard, and well-commented.
- Use lightweight container images available quickly:
  - `nginx:alpine`, `nginx:1.24`, `nginx:1.25`
  - `busybox`, `curlimages/curl`, `python:alpine`
- Include clear labels (`app`, `tier`, `role`) for selectors.
- **Offline / Caching Compatibility**: Always set `imagePullPolicy: IfNotPresent` on all containers in Pod and Deployment manifests (and use `--image-pull-policy=IfNotPresent` on `kubectl run` commands) so offline runs leverage pre-cached images without attempting registry lookups.

### Step 4: Write Step Markdowns & Interactive Commands
- Provide conceptual explanation before commands.
- Provide click-to-run commands with `{{exec}}`.
- Always include inspection commands (`kubectl get ... -o wide`, `kubectl describe ...`) so learners observe results.
- Add `<details><summary>Tip</summary>` and `<details><summary>Solution</summary>` where learners might struggle.

### Step 5: Implement Verification Scripts
- Create `stepX_verify.sh` for each step.
- Ensure executable permissions (`chmod +x stepX_verify.sh`).
- Test with negative and positive cases.

### Step 6: Define `index.json`
- Assemble `details.intro`, `details.steps`, `details.finish`, and `details.assets`.
- Set the backend (`kubernetes-kubeadm-1node` or `kubernetes-kubeadm-2nodes`).

---

## 7. Quality Checklist for New Scenarios

Before finalizing any scenario, verify:
- [ ] `index.json` is valid JSON (no trailing commas, properly closed quotes).
- [ ] Every step referenced in `index.json` matches existing files.
- [ ] All `assets` mapped in `index.json` exist in the scenario folder.
- [ ] All interactive code blocks use `` `cmd`{{exec}} `` or ```` ```bash\ncmd\n```{{exec}} ````.
- [ ] Verification scripts are non-destructive and return `0` on success.
- [ ] Port exposure uses valid NodePort range (`30000-32767`) if NodePort is used.
- [ ] Any HTTP links use `{{TRAFFIC_HOST1_<PORT>}}` macro.
- [ ] Markdown headers use clean `#`, `###`, and `<br>` spacing for Killercoda's UI renderer.
- [ ] All Pods, Deployments, and `kubectl run` commands specify `imagePullPolicy: IfNotPresent` (or `--image-pull-policy=IfNotPresent`) for offline compatibility.


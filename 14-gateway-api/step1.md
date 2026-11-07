# 1. Inspect GatewayClass & Deploy the Gateway

In this step, you will understand the separation of roles between the **Infrastructure Provider** and the **Cluster Operator**, and deploy your first `Gateway`.

---

### Step 1.1: Verify the GatewayClass

A `GatewayClass` defines a specific Gateway controller implementation available in the cluster. It is typically installed and maintained by infrastructure administrators or cloud providers.

Wait for the NGINX Gateway Fabric controller to reconcile and accept the class:

```bash
kubectl wait --for=condition=Accepted gatewayclass/nginx --timeout=60s
```{{exec}}

List the installed gateway classes:

```bash
kubectl get gatewayclasses
```{{exec}}

Inspect the details of the `nginx` gateway class:

```bash
kubectl describe gatewayclass nginx
```{{exec}}

Notice:
- `spec.controllerName`: `gateway.nginx.org/nginx-gateway-controller`. This informs Kubernetes that NGINX Gateway Fabric manages any Gateway requesting this class.
- `status.conditions`: `Accepted: True`.

---

### Step 1.2: Inspect & Apply the Gateway

As a **Cluster Operator**, you declare a `Gateway` to provision an entry point into the cluster with specific listeners, ports, and allowed namespaces.

Open and review the gateway manifest:

```text
/root/manifests/gateway.yaml
```{{open}}

Notice the specification:
- `gatewayClassName: nginx`: Associates this gateway with the NGINX Gateway Fabric controller.
- `listeners`: Listens on HTTP port `80`.
- `allowedRoutes`: Permits routes within the `Same` namespace (`default`) to attach to this gateway.

Apply the Gateway:

```bash
kubectl apply -f /root/manifests/gateway.yaml
```{{exec}}

Wait for the Gateway to be programmed by the controller:

```bash
kubectl wait --for=condition=Programmed gateway/my-gateway --timeout=60s
```{{exec}}

---

### Step 1.3: Inspect Gateway Status & Exposure

Check the newly created Gateway:

```bash
kubectl get gateway my-gateway
```{{exec}}

When NGINX Gateway Fabric detects this `Gateway`, it automatically:
1. Deploys the dedicated NGINX data plane proxy pod.
2. Creates a companion Kubernetes Service of type `LoadBalancer`.
3. Populates `status.addresses` with the assigned external IP.
4. Marks the Gateway condition as `Programmed: True`.

Inspect the provisioned Service:

```bash
kubectl get svc -l gateway.networking.k8s.io/gateway-name=my-gateway
```{{exec}}

Extract the Gateway's assigned external IP into an environment variable:

```bash
GATEWAY_IP=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo "Gateway IP: $GATEWAY_IP"
```{{exec}}

---

### Step 1.4: Test Gateway Access Before Attaching Routes

Send an HTTP request to the Gateway IP on standard HTTP port 80:

```bash
curl -i http://$GATEWAY_IP/
```{{exec}}

> [!NOTE]
> **Why HTTP 404 Not Found?**
> The Gateway is active and NGINX received the connection, but no application routing rules (`HTTPRoute`) have been attached to the listener yet.
> In Gateway API, a Gateway without routes safely rejects unmatched traffic with a `404 Not Found`.

Click **Check** to verify Step 1!

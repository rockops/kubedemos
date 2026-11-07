### 1. What is a LoadBalancer Service?

In earlier steps, you explored two service types:
- **`ClusterIP`**: Internal to the cluster only.
- **`NodePort`**: Exposes the service on a high, non-standard port (`30000-32767`) across every node.

In production environments, external clients expect applications to be accessible on standard ports (such as HTTP port `80` or HTTPS port `443`) via a single, dedicated external IP address.

A **`LoadBalancer`** service solves this:
1. It automatically provisions an external IP address reachable by outside clients.
2. It forwards traffic arriving at `<External-IP>:80` directly to the backing Pods.
3. It seamlessly incorporates both `ClusterIP` (for in-cluster communication) and `NodePort` (for underlying routing).

<br>

### 2. Inspect the LoadBalancer Service Manifest

View the LoadBalancer service manifest:

```
cat /root/manifests/loadbalancer-service.yaml
```{{exec}}

Notice the specification:
- `type: LoadBalancer`: Declares that this service should be exposed via an external load balancer.
- `ports.port: 80`: The service is exposed to external clients on standard HTTP port `80`.
- `selector.app: webapp`: Targets the 2-replica web application deployed in Step 4.

<br>

### 3. Deploy the LoadBalancer Service

Apply the manifest:

```
kubectl apply -f /root/manifests/loadbalancer-service.yaml
```{{exec}}

Inspect the service status:

```
kubectl get svc webapp-loadbalancer
```{{exec}}

You will see output similar to:

```text
NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
webapp-loadbalancer   LoadBalancer   10.96.x.x       192.168.1.100   80:3xxxx/TCP   5s
```

Notice the columns:
- **`CLUSTER-IP`**: Internal virtual IP for pod-to-pod communication (`10.96.x.x`).
- **`EXTERNAL-IP`**: The dedicated external entrypoint address allocated for clients outside the cluster (`192.168.1.100`), placed in an external subnet completely separate from the node's network (`172.30.1.x`).
- **`PORT(S)`**: Maps port `80` externally to the backing container port.

> [!NOTE]
> Notice the clear network separation across the entire architecture:
> - **Pod Network**: `10.244.x.x` (ephemeral container IPs)
> - **ClusterIP Network**: `10.96.x.x` (internal virtual service IPs)
> - **Node Network**: `172.30.1.x` (host infrastructure IPs)
> - **External Client IP**: `192.168.1.100` (external LoadBalancer IP)

<br>

### 4. Connect to the Application via the External IP

Extract the allocated external IP address into an environment variable:

```
LB_IP=$(kubectl get svc webapp-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "LoadBalancer External IP: $LB_IP"
```{{exec}}

Send an HTTP request directly to the external IP on standard port 80:

```
curl -i http://$LB_IP/
```{{exec}}

You will receive an `HTTP/1.1 200 OK` response directly from one of your application pods!

<br>

### 5. Verify External Load Balancing

Send 10 consecutive requests to the LoadBalancer IP:

```
for i in {1..10}; do curl -s http://$LB_IP; done
```{{exec}}

Observe the output:

```text
Response from Pod IP: 10.244.0.X (Hostname: webapp-...)
Response from Pod IP: 10.244.0.Y (Hostname: webapp-...)
```

The LoadBalancer service provides a single, production-grade external entrypoint on standard port 80, while automatically balancing requests across all healthy replica pods!

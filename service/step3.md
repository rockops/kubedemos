### 1. Create a NodePort Service

While `ClusterIP` allows communication **inside** the cluster, a **NodePort** service exposes the application on a dedicated port across **every worker node's external/internal IP address** (allocated from the default range `30000-32767`).

View the NodePort service manifest:

```
cat /root/manifests/nodeport-service.yaml
```{{exec}}

Apply the NodePort service:

```
kubectl apply -f /root/manifests/nodeport-service.yaml
```{{exec}}

*(Alternatively, you could run `kubectl expose pod my-nginx --port=80 --target-port=80 --name=my-nginx-nodeport --type=NodePort`)*

<br>

### 2. Inspect the Allocated NodePort

List the services to view the assigned high port:

```
kubectl get service my-nginx-nodeport
```{{exec}}

Extract the dynamically assigned NodePort (e.g., `3xxxx`):

```
NODE_PORT=$(kubectl get svc my-nginx-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
echo "Allocated NodePort: $NODE_PORT"
```{{exec}}

Notice that a `NodePort` service **also** receives a `ClusterIP`. Traffic routed to either `<NodeIP>:<NodePort>` or `<ClusterIP>:<Port>` is forwarded to the backing pods.

<br>

### 3. Discover the Node IP Address

Find the IP address of the cluster node where the workload runs:

```
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Node IP address: $NODE_IP"
```{{exec}}

<br>

### 4. Connect to the Pod Using the NodePort

Send an HTTP request directly to `<NodeIP>:<NodePort>`:

```
curl -I http://$NODE_IP:$NODE_PORT
```{{exec}}

You can also test connecting via `localhost` or any interface on the node:

```
curl -I http://localhost:$NODE_PORT
```{{exec}}

`kube-proxy` listens on the node port on all network interfaces of the node and forwards traffic to the target container!

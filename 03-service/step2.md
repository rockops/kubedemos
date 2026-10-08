### 1. Create a ClusterIP Service

A `ClusterIP` Service exposes a workload on a stable internal IP address accessible only from within the cluster. It acts as an internal Layer 4 load balancer.

You can create the service by applying the provided manifest:

```
cat /root/manifests/clusterip-service.yaml
```{{exec}}

Notice how the `selector` matches the pod's label (`run: my-nginx`), mapping service port `80` to target port `80` on the container.

Apply the service manifest:

```
kubectl apply -f /root/manifests/clusterip-service.yaml
```{{exec}}

*(Alternatively, you could run `kubectl expose pod my-nginx --port=80 --target-port=80 --name=my-nginx-clusterip --type=ClusterIP`)*

<br>

### 2. Inspect the Service & Backing Endpoints

Check the newly created service:

```
kubectl get service my-nginx-clusterip
```{{exec}}

Behind every Service with a selector, Kubernetes automatically manages an **Endpoints** (or `EndpointSlice`) object that tracks the IPs of matching healthy pods:

```
kubectl get endpoints my-nginx-clusterip
```{{exec}}

Notice that the endpoint IP corresponds exactly to the `my-nginx` Pod IP you discovered in Step 1!

<br>

### 3. Connect to the Pod Through the Service

Retrieve the virtual ClusterIP assigned to the service:

```
CLUSTER_IP=$(kubectl get svc my-nginx-clusterip -o jsonpath='{.spec.clusterIP}')
echo "Service ClusterIP: $CLUSTER_IP"
```{{exec}}

Send an HTTP request to the service's ClusterIP:

```
curl -I http://$CLUSTER_IP
```{{exec}}

The request reaches the service virtual IP, and `kube-proxy` transparently routes the traffic to the backing pod!

<br>

### 4. Service Discovery via DNS Name

Kubernetes also provides built-in DNS service discovery through CoreDNS. Inside any pod or container within the cluster, the service can be addressed directly by its DNS name: `my-nginx-clusterip.default.svc.cluster.local` (or simply `my-nginx-clusterip`).

Let's test connecting to the service by its DNS name using a temporary test container:

```
kubectl run curl-test --image=nginx --image-pull-policy=IfNotPresent --restart=Never --rm -i -- curl -s -I http://my-nginx-clusterip
```{{exec}}

Even if the backing pod is recreated with a new IP address, the Service ClusterIP and DNS name remain unchanged!

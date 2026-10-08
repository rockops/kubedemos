### 1. Deploy 2 Replicas with Dynamic Pod IP Responses

In production, applications run across multiple replicas for high availability and throughput. A Kubernetes Service automatically distributes incoming traffic across all healthy pods backing the service.

Inspect the provided manifest:

```
cat /root/manifests/webapp-deployment.yaml
```{{exec}}

Notice how the deployment is configured:
1. `replicas: 2`: Two pod instances are scheduled.
2. **Downward API (`env`)**: Injects each container's dynamically assigned Pod IP via `status.podIP`.
3. **Lifecycle Hook (`postStart`)**: Writes the Pod IP and container hostname into `/usr/share/nginx/html/index.html`. Every HTTP request directly returns the IP of the pod handling the request!
4. **Service (`webapp-service`)**: Exposes the `app: webapp` pods on port `80`.

<br>

### 2. Apply the Deployment and Service

Deploy the application and service:

```
kubectl apply -f /root/manifests/webapp-deployment.yaml
```{{exec}}

Wait for both replicas to become ready:

```
kubectl rollout status deployment/webapp
```{{exec}}

<br>

### 3. Inspect Pods and Service Endpoints

List the running pods and their assigned IP addresses:

```
kubectl get pods -l app=webapp -o wide
```{{exec}}

Inspect the `Endpoints` registered under `webapp-service`:

```
kubectl get endpoints webapp-service
```{{exec}}

Notice that Kubernetes has registered **both** Pod IPs as active endpoints for `webapp-service`!

<br>

### 4. Demonstrate Traffic Load Balancing

Retrieve the Service ClusterIP:

```
WEB_SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}')
echo "Webapp Service ClusterIP: $WEB_SVC_IP"
```{{exec}}

Send 10 consecutive requests to the service:

```
for i in {1..10}; do curl -s http://$WEB_SVC_IP; done
```{{exec}}

Observe the output! Notice that the responses alternate between the two different Pod IPs:
```
Response from Pod IP: 10.244.0.X (Hostname: webapp-...)
Response from Pod IP: 10.244.0.Y (Hostname: webapp-...)
```

Kubernetes automatically load-balances the requests across both replicas, providing seamless traffic distribution and high availability!

### 1. Create an Nginx Pod

In Kubernetes, Pods are the smallest deployable units of computing. Let's create an Nginx pod named `my-nginx`:

```
kubectl run my-nginx --image=nginx --restart=Never --image-pull-policy=IfNotPresent
```{{exec}}

Wait for the pod to reach the `Running` state:

```
kubectl wait --for=condition=Ready pod/my-nginx --timeout=60s
```{{exec}}

<br>

### 2. Discover the Pod IP Address

Every pod receives an IP address within the cluster network (Pod CIDR). Inspect the pod to find its allocated IP:

```
kubectl get pod my-nginx -o wide
```{{exec}}

Store the IP address in a shell variable for easy access:

```
POD_IP=$(kubectl get pod my-nginx -o jsonpath='{.status.podIP}')
echo "My Pod IP is: $POD_IP"
```{{exec}}

<br>

### 3. Connect Directly to the Pod via Curl

Since you are running inside a cluster node on the cluster network, you can access the Pod IP directly using `curl`:

```
curl -I http://$POD_IP
```{{exec}}

You should see an `HTTP/1.1 200 OK` response from the Nginx web server!

<br>

### 4. Why We Need Services

While accessing the Pod directly by IP works right now, notice the key limitation:
- **Ephemeral Lifecycle**: If the `my-nginx` pod crashes, is deleted, or is rescheduled on another node, its IP address is released and a new IP is assigned.
- **No Load Balancing**: Direct IP access points to a single static instance.
- **No Service Discovery**: Other workloads would need to track pod lifecycle events to know which IP to connect to.

In the next step, we will solve this by creating a **ClusterIP Service**!

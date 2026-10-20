### 1. Inspect k3d Cluster & Tools

The initialization script has installed `k3d`, `kubectl`, and `helm` into `/usr/local/bin` and created a cluster named `rockdemo`.

Verify the k3d cluster and nodes using the `k3d` CLI:

```
k3d cluster list
```{{exec}}

```
k3d node list
```{{exec}}

Verify the client tools:

```
kubectl version --client
```{{exec}}

```
helm version
```{{exec}}

Inspect cluster information and active nodes:

```
kubectl cluster-info
```{{exec}}

```
kubectl get nodes -o wide
```{{exec}}

<br>

### 2. Create Two Namespaces

Namespaces allow dividing cluster resources between multiple users, teams, or environments.

Create the `dev` namespace:

```
kubectl create namespace dev
```{{exec}}

Create the `prod` namespace:

```
kubectl create namespace prod
```{{exec}}

<br>

### 3. Verify Namespaces & Deploy Test Workload

List all namespaces to verify that both `dev` and `prod` are active:

```
kubectl get namespaces
```{{exec}}

Deploy a test Pod in the `dev` namespace to verify that the k3d cluster can schedule and run container workloads:

```
kubectl run test-pod --image=nginx:alpine --image-pull-policy=IfNotPresent -n dev
```{{exec}}

Inspect the running Pod and check its status:

```
kubectl get pods -n dev -o wide
```{{exec}}

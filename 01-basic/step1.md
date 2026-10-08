### 1. Inspect Kubeconfig

The `kubeconfig` file contains cluster endpoints, credentials, and context configurations.

View your current configuration by clicking below:

```
kubectl config view
```{{exec}}

To view the active context and default namespace:

```
kubectl config current-context
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

### 3. Verify the Namespaces

List all namespaces to verify that both `dev` and `prod` are active:

```
kubectl get namespaces
```{{exec}}

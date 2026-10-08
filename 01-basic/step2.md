### 1. Name Scoping in Kubernetes Namespaces

In Kubernetes, resource names must be unique within a single namespace, but **can be reused across different namespaces**.

We will deploy two pods:
- Namespace `dev`: Pod named `demo` using image `nginx:1.24`
- Namespace `prod`: Pod named `demo` using image `nginx:1.25`

<br>

### 2. Create the First Pod in the `dev` Namespace

Create the pod `demo` in the `dev` namespace using `nginx:1.24`:

```
kubectl run demo --image=nginx:1.24 --namespace=dev --image-pull-policy=IfNotPresent
```{{exec}}

<br>

### 3. Create the Second Pod in the `prod` Namespace

Create the pod `demo` in the `prod` namespace using `nginx:1.25`:

```
kubectl run demo --image=nginx:1.25 --namespace=prod --image-pull-policy=IfNotPresent
```{{exec}}

<br>

### 4. Verify Both Pods Are Running

Check the status of the `demo` pod in `dev`:

```
kubectl get pod demo -n dev
```{{exec}}

Check the status of the `demo` pod in `prod`:

```
kubectl get pod demo -n prod
```{{exec}}

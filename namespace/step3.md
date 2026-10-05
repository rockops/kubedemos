### 1. Compare Pod Images Across Namespaces

Even though both pods share the identical name `demo`, they exist in completely separate namespace boundaries and run different container images.

Inspect the container images of both pods side-by-side using custom columns:

```
kubectl get pods -A -l run=demo -o custom-columns=NAMESPACE:.metadata.namespace,POD_NAME:.metadata.name,IMAGE:.spec.containers[*].image
```{{exec}}

You can also inspect the image tag for each pod individually:

In `dev`:
```
kubectl get pod demo -n dev -o jsonpath='{.spec.containers[0].image}{"\n"}'
```{{exec}}
> Points to: **`nginx:1.24`**

In `prod`:
```
kubectl get pod demo -n prod -o jsonpath='{.spec.containers[0].image}{"\n"}'
```{{exec}}
> Points to: **`nginx:1.25`**

Notice that the image tags are different!

<br>

### 2. Demonstrate Namespace Isolation During Deletion

Resources in different namespaces have independent lifecycles.

Delete the `demo` pod in the `dev` namespace:

```
kubectl delete pod demo -n dev
```{{exec}}

Confirm that the `demo` pod in `dev` has been deleted:

```
kubectl get pod demo -n dev
```{{exec}}

<br>

### 3. Verify the `prod` Pod Is Still Running

Check that the `demo` pod in `prod` is still alive and running undisturbed:

```
kubectl get pod demo -n prod
```{{exec}}

> **Takeaway:** Actions performed on a resource inside one namespace do not impact same-named resources in other namespaces.

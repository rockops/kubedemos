<br>

### Welcome to Kubernetes Namespaces Demo!

In Kubernetes, **Namespaces** provide a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces.

In this scenario, you will:
1. **Inspect your Kubeconfig**: View your cluster connection details and active contexts.
2. **Create two namespaces**: `dev` and `prod`.
3. **Deploy same-named Pods**: Create a pod named `demo` in `dev` using `nginx:1.24`, and another pod named `demo` in `prod` using `nginx:1.25`.
4. **Compare Pod Images**: Observe how each namespace holds its own independent `demo` pod with its own container image tag.
5. **Demonstrate Lifecycle Isolation**: Delete the `demo` pod in `dev` and verify that the `demo` pod in `prod` remains unaffected.

Let's get started!

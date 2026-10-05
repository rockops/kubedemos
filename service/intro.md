<br>

### Welcome to the Kubernetes Services & Networking Demo!

In Kubernetes, Pods are ephemeral resources. They are dynamically created, destroyed, and rescheduled across worker nodes. Each Pod gets an internal IP address assigned from the cluster's Pod CIDR network, but relying on direct Pod IPs is fragile.

**Kubernetes Services** provide an abstraction layer: a durable IP address, DNS name, and built-in Layer 4 load balancer that routes traffic to a dynamically updated set of Pods matching a label selector.

In this scenario, you will learn and test:
1. **Direct Pod Access**: Deploy an Nginx pod, discover its ephemeral Pod IP, and access it directly using `curl`.
2. **ClusterIP Service**: Expose the pod with a stable virtual ClusterIP and connect through the service abstraction.
3. **NodePort Service**: Expose the pod externally on every node's IP address using a high port (`30000-32767`).
4. **Load Balancing with Deployment Replicas**: Deploy a scalable 2-replica deployment where each pod dynamically serves its own IP address, and observe how a Kubernetes Service distributes requests across both endpoints.

Let's begin!

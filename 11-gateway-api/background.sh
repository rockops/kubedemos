#!/bin/bash

# Wait for Kubernetes cluster to be responsive
while ! kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

# Wait for assets to be copied to /root/manifests
while [ ! -f /root/manifests/setup-gateway.sh ]; do
  sleep 1
done

# Execute NGINX Gateway Fabric setup
chmod +x /root/manifests/setup-gateway.sh
bash /root/manifests/setup-gateway.sh >/var/log/setup-gateway.log 2>&1


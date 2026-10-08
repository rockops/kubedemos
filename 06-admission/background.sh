#!/bin/bash

# Wait for Kubernetes cluster to be responsive
while ! kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

# Wait for assets to be copied to /root/manifests
while [ ! -f /root/manifests/setup-tls.sh ]; do
  sleep 1
done

# Execute TLS setup
chmod +x /root/manifests/setup-tls.sh
bash /root/manifests/setup-tls.sh >/var/log/setup-tls.log 2>&1

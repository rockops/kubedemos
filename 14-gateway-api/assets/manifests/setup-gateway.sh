#!/bin/bash
set -e

echo "[setup-gateway] Waiting for Kubernetes cluster to be ready..."
while ! kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

echo "[setup-gateway] Starting lightweight LoadBalancer IP assigner..."
if ! pgrep -f "lb-controller.sh" >/dev/null 2>&1; then
  chmod +x /root/manifests/lb-controller.sh
  nohup bash /root/manifests/lb-controller.sh >/var/log/lb-controller.log 2>&1 &
fi

echo "[setup-gateway] Applying Gateway API CRDs..."
kubectl apply --server-side -f /root/manifests/gateway-crds.yaml

echo "[setup-gateway] Applying NGINX Gateway Fabric CRDs..."
kubectl apply --server-side -f /root/manifests/ngf-crds.yaml

echo "[setup-gateway] Deploying NGINX Gateway Fabric controller..."
kubectl apply -f /root/manifests/ngf-deploy.yaml

echo "[setup-gateway] Waiting for cert-generator job to complete..."
kubectl wait --for=condition=complete job/nginx-gateway-cert-generator -n nginx-gateway --timeout=60s || true

echo "[setup-gateway] Waiting for NGINX Gateway Fabric deployment..."
kubectl rollout status deployment/nginx-gateway -n nginx-gateway --timeout=90s

echo "[setup-gateway] Waiting for GatewayClass 'nginx' to be accepted..."
for i in {1..30}; do
  STATUS=$(kubectl get gatewayclass nginx -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}' 2>/dev/null || echo "Unknown")
  if [ "$STATUS" = "True" ]; then
    echo "[setup-gateway] GatewayClass 'nginx' accepted successfully!"
    break
  fi
  sleep 2
done

echo "[setup-gateway] NGINX Gateway Fabric initialization complete!"

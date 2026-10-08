#!/bin/bash
# Verify both Helm and Kustomize workloads are active with 3 replicas

# Check Helm deployment
HELM_REPLICAS=$(kubectl get deployment my-nginx -o jsonpath='{.spec.replicas}' 2>/dev/null)
HELM_READY=$(kubectl get deployment my-nginx -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$HELM_REPLICAS" != "3" ] || [ "$HELM_READY" != "3" ]; then
  exit 1
fi

# Check Kustomize deployment
KUST_REPLICAS=$(kubectl get deployment nginx-kustomize -o jsonpath='{.spec.replicas}' 2>/dev/null)
KUST_READY=$(kubectl get deployment nginx-kustomize -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$KUST_REPLICAS" != "3" ] || [ "$KUST_READY" != "3" ]; then
  exit 1
fi

exit 0

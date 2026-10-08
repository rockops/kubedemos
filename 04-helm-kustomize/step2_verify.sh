#!/bin/bash
# Verify Kustomize deployment exists and has 3 ready replicas

# Check deployment existence and replica count
REPLICAS=$(kubectl get deployment nginx-kustomize -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" != "3" ]; then
  exit 1
fi

# Check pods readiness
READY=$(kubectl get deployment nginx-kustomize -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY" != "3" ]; then
  exit 1
fi

exit 0

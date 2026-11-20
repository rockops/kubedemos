#!/bin/bash
# 1. Deployment must not have the broken image
IMAGE=$(kubectl get deployment webapp -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
echo "$IMAGE" | grep -qv "broken" || exit 1

# 2. No broken v3 pods should remain
V3_COUNT=$(kubectl get pods -l version=v3 --no-headers 2>/dev/null | wc -l)
[ "${V3_COUNT:-0}" -eq 0 ] || exit 1

# 3. Deployment must have 3 ready replicas
READY=$(kubectl get deployment webapp -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
[ "${READY:-0}" -ge 3 ] || exit 1

# 4. Service must respond with v2.0.0
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
curl -s --max-time 3 "http://$SVC_IP" | grep -q "v2.0.0" || exit 1

exit 0

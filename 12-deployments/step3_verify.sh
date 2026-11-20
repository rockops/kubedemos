#!/bin/bash
# 1. Broken pod should exist (or deployment image is broken)
IMAGE=$(kubectl get deployment webapp -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
echo "$IMAGE" | grep -q "broken" || exit 1

# 2. Healthy pods must still be serving v2.0.0
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
curl -s --max-time 3 "http://$SVC_IP" | grep -q "v2.0.0" || exit 1

# 3. Deployment should have at least 3 ready replicas
READY=$(kubectl get deployment webapp -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
[ "${READY:-0}" -ge 3 ] || exit 1

exit 0

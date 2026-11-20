#!/bin/bash
# 1. Deployment must not be paused
PAUSED=$(kubectl get deployment webapp -o jsonpath='{.spec.paused}' 2>/dev/null)
[ "$PAUSED" != "true" ] || exit 1

# 2. Deployment must have 3 ready replicas
READY=$(kubectl get deployment webapp -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
[ "${READY:-0}" -ge 3 ] || exit 1

# 3. Resources must be set on pods
LIMITS=$(kubectl get pod -l app=webapp -o jsonpath='{.items[0].spec.containers[0].resources.limits.memory}' 2>/dev/null)
[ -n "$LIMITS" ] || exit 1

# 4. Service must respond with patched version
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
curl -s --max-time 3 "http://$SVC_IP" | grep -q "v2.1.0-patched" || exit 1

exit 0


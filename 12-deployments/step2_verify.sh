#!/bin/bash
# 1. Deployment must exist with 3 ready replicas
READY=$(kubectl get deployment webapp -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
[ "${READY:-0}" -ge 3 ] || exit 1

# 2. Service must respond with v2.0.0
SVC_IP=$(kubectl get svc webapp-service -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
curl -s --max-time 3 "http://$SVC_IP" | grep -q "v2.0.0" || exit 1

# 3. Two ReplicaSets should exist (v1 scaled to 0, v2 active)
RS_COUNT=$(kubectl get rs -l app=webapp --no-headers 2>/dev/null | wc -l)
[ "${RS_COUNT:-0}" -ge 2 ] || exit 1

exit 0


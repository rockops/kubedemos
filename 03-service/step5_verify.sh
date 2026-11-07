#!/bin/bash
# 1. Service must exist and be of type LoadBalancer
TYPE=$(kubectl get svc webapp-loadbalancer -o jsonpath='{.spec.type}' 2>/dev/null)
[ "$TYPE" = "LoadBalancer" ] || exit 1

# 2. External IP must be populated (not pending)
LB_IP=$(kubectl get svc webapp-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
[ -n "$LB_IP" ] || exit 1

# 3. HTTP request to LoadBalancer IP should succeed
curl -s --max-time 3 "http://$LB_IP" | grep -q "Response from Pod IP" || exit 1

exit 0


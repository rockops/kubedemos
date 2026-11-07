#!/bin/bash
# 1. GatewayClass nginx must be Accepted
kubectl get gatewayclass nginx -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}' 2>/dev/null | grep -qi "True" || exit 1

# 2. Gateway must exist in default namespace
kubectl get gateway my-gateway -n default >/dev/null 2>&1 || exit 1

# 3. Gateway should be Programmed or Accepted
kubectl get gateway my-gateway -n default -o jsonpath='{.status.conditions}' | grep -qiE "Accepted|Programmed" || exit 1

# 4. Gateway must have an assigned address
kubectl get gateway my-gateway -n default -o jsonpath='{.status.addresses[0].value}' 2>/dev/null | grep -q "." || exit 1

exit 0

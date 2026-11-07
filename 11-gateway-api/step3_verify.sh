#!/bin/bash
# 1. Canary deployment must exist
kubectl get deployment store-v2 -n default >/dev/null 2>&1 || exit 1

# 2. HTTPRoute must include store-v2 backendRef and weight
kubectl get httproute web-routes -n default -o yaml | grep -q "store-v2" || exit 1
kubectl get httproute web-routes -n default -o yaml | grep -q "weight" || exit 1

exit 0


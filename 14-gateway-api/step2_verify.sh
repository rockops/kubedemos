#!/bin/bash
# 1. Backends must exist
kubectl get deployment store-v1 -n default >/dev/null 2>&1 || exit 1
kubectl get deployment blog-v1 -n default >/dev/null 2>&1 || exit 1

# 2. HTTPRoute must exist and reference my-gateway
kubectl get httproute web-routes -n default >/dev/null 2>&1 || exit 1
kubectl get httproute web-routes -n default -o yaml | grep -q "my-gateway" || exit 1

exit 0


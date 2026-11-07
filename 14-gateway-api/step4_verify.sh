#!/bin/bash
# 1. HTTPRoute must include header match for X-Version
kubectl get httproute web-routes -n default -o yaml | grep -q "X-Version" || exit 1

exit 0


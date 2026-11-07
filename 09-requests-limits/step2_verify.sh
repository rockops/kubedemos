#!/bin/bash
kubectl get pod rightsized-pod -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Running" && \
  ! kubectl get pod oversized-pod >/dev/null 2>&1


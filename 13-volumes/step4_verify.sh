#!/bin/bash
kubectl get pvc dynamic-pvc -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Bound" || \
  (kubectl get events 2>/dev/null | grep -q -E "dynamic-pvc|pod-dynamic")


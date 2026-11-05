#!/bin/bash
kubectl get pv pv-local-hostpath -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Bound" && \
  kubectl get pvc pvc-static -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Bound"


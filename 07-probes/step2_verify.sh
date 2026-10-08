#!/bin/bash
kubectl get pod pod-probes >/dev/null 2>&1 && \
  kubectl get pod pod-probes -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True"

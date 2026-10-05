#!/bin/bash
kubectl get configmap app-config >/dev/null 2>&1 && \
  kubectl get pod pod-configmap-env >/dev/null 2>&1 && \
  kubectl get pod pod-configmap-env -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True" && \
  kubectl exec pod-configmap-env -- env | grep -q "APPLICATION_ENVIRONMENT=production"

#!/bin/bash
kubectl get pod pod-configmap-volume >/dev/null 2>&1 && \
  kubectl get pod pod-configmap-volume -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True" && \
  kubectl exec pod-configmap-volume -- test -f /etc/config/app.properties && \
  kubectl exec pod-configmap-volume -- cat /etc/config/app.properties | grep -q "max.connections=100"

#!/bin/bash
kubectl get pod web-portal -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q "True" && \
  kubectl get svc db-service >/dev/null 2>&1


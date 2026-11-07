#!/bin/bash
kubectl get pod web-portal >/dev/null 2>&1 && \
  kubectl get pod web-portal -o jsonpath='{.status.initContainerStatuses[0].name}' | grep -q "wait-for-db"


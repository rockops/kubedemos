#!/bin/bash
kubectl get pod multi-init-web -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q "True" && \
  test $(kubectl get pod multi-init-web -o jsonpath='{.status.initContainerStatuses[*].state.terminated.reason}' | grep -o "Completed" | wc -l) -eq 2


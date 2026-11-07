#!/bin/bash
kubectl get pod memory-fixed -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Running" || \
  (kubectl get events 2>/dev/null | grep -q "memory-fixed" && ! kubectl get pod memory-fixed >/dev/null 2>&1)


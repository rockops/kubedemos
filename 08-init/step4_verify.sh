#!/bin/bash
kubectl get pod faulty-pod -o jsonpath='{.status.initContainerStatuses[0]}' 2>/dev/null | grep -q -E "Error|CrashLoopBackOff|exitCode" || \
  (kubectl get events 2>/dev/null | grep -q "faulty-pod" && ! kubectl get pod faulty-pod >/dev/null 2>&1)


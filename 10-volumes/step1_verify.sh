#!/bin/bash
kubectl get pod shared-emptydir >/dev/null 2>&1 || \
  (kubectl get events 2>/dev/null | grep -q "shared-emptydir")


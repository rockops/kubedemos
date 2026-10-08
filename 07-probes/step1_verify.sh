#!/bin/bash
kubectl get pod pod-probes >/dev/null 2>&1 && \
  kubectl exec pod-probes -- test -f /tmp/started >/dev/null 2>&1

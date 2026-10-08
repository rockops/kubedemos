#!/bin/bash
until kubectl get nodes >/dev/null 2>&1; do sleep 1; done
if ! kubectl get pod curl-test-pod >/dev/null 2>&1; then
  kubectl run curl-test-pod --image=alpine/curl --image-pull-policy=IfNotPresent -- sleep 3600
  kubectl wait --for=condition=Ready pod/curl-test-pod --timeout=60s
fi

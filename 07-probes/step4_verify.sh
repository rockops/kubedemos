#!/bin/bash
kubectl get pod http-probe-pod >/dev/null 2>&1 && \
  kubectl get svc http-probe-service >/dev/null 2>&1

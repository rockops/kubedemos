#!/bin/bash
kubectl get pod pod-secret-demo >/dev/null 2>&1 && \
  kubectl get pod pod-secret-demo -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "True" && \
  kubectl exec pod-secret-demo -- env | grep -q "DATABASE_USER=db_admin" && \
  kubectl exec pod-secret-demo -- env | grep -q "DATABASE_PASS=SuperSecretPassword123!" && \
  kubectl exec pod-secret-demo -- test -f /etc/secrets/DB_PASSWORD && \
  test "$(kubectl exec pod-secret-demo -- cat /etc/secrets/DB_PASSWORD)" = "SuperSecretPassword123!"

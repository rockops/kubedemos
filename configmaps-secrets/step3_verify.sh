#!/bin/bash
kubectl get secret db-credentials >/dev/null 2>&1 && \
  test "$(kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode)" = "SuperSecretPassword123!" && \
  test "$(kubectl get secret db-credentials -o jsonpath='{.data.DB_USERNAME}' | base64 --decode)" = "db_admin"

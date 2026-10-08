#!/bin/bash
# Verify step 2: Validating webhook registered, compliant deployment admitted in prod, oversized rejected in prod, oversized admitted in dev

# 1. Check ValidatingWebhookConfiguration exists
kubectl get validatingwebhookconfiguration replica-limit-webhook >/dev/null 2>&1 || exit 1

# 2. Check valid-app deployment exists in prod with 3 replicas
PROD_VALID_REPLICAS=$(kubectl get deployment valid-app -n prod -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$PROD_VALID_REPLICAS" != "3" ]; then
  exit 1
fi

# 3. Check oversized-app deployment does NOT exist in prod (should be blocked)
if kubectl get deployment oversized-app -n prod >/dev/null 2>&1; then
  exit 1
fi

# 4. Check oversized-app deployment exists in dev (unlabeled namespace bypass)
kubectl get deployment oversized-app -n dev >/dev/null 2>&1 || exit 1

exit 0

#!/bin/bash
# Verify step 1: Webhook server deployed, mutating webhook registered, sidecar injected in prod

# 1. Check webhook-tls secret exists
kubectl get secret webhook-tls -n webhook-system >/dev/null 2>&1 || exit 1

# 2. Check admission-webhook deployment is ready
READY_REPLICAS=$(kubectl get deployment admission-webhook -n webhook-system -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$READY_REPLICAS" != "1" ]; then
  exit 1
fi

# 3. Check MutatingWebhookConfiguration exists
kubectl get mutatingwebhookconfiguration sidecar-injector-webhook >/dev/null 2>&1 || exit 1

# 4. Check namespaces
kubectl get ns dev >/dev/null 2>&1 || exit 1
kubectl get ns prod >/dev/null 2>&1 || exit 1

# 5. Check prod label
PROD_LABEL=$(kubectl get ns prod -o jsonpath='{.metadata.labels.sidecar-injection}' 2>/dev/null)
if [ "$PROD_LABEL" != "enabled" ]; then
  exit 1
fi

# 6. Check dev pod has 1 container
DEV_COUNT=$(kubectl get pod web-app -n dev -o jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' 2>/dev/null | wc -l)
if [ "$DEV_COUNT" -ne 1 ]; then
  exit 1
fi

# 7. Check prod pod has sidecar-agent injected
PROD_CONTAINERS=$(kubectl get pod web-app -n prod -o jsonpath='{range .spec.containers[*]}{.name}{" "}{end}' 2>/dev/null)
echo "$PROD_CONTAINERS" | grep -q "web" || exit 1
echo "$PROD_CONTAINERS" | grep -q "sidecar-agent" || exit 1

# 8. Check prod pod is Running
PROD_PHASE=$(kubectl get pod web-app -n prod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$PROD_PHASE" != "Running" ]; then
  exit 1
fi

exit 0

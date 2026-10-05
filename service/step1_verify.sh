#!/bin/bash
PHASE=$(kubectl get pod my-nginx -o jsonpath='{.status.phase}' 2>/dev/null)
test "$PHASE" = "Running"

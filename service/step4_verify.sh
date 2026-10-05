#!/bin/bash
READY=$(kubectl get deployment webapp -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
test "${READY:-0}" -ge 2 && kubectl get svc webapp-service >/dev/null 2>&1

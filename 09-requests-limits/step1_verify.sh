#!/bin/bash
kubectl get pod oversized-pod -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Pending"


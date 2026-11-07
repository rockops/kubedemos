#!/bin/bash
kubectl get pod memory-hog -o jsonpath='{.status.containerStatuses[0]}' 2>/dev/null | grep -q -E "OOMKilled|137"


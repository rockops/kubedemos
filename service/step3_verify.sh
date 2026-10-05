#!/bin/bash
TYPE=$(kubectl get svc my-nginx-nodeport -o jsonpath='{.spec.type}' 2>/dev/null)
test "$TYPE" = "NodePort"

#!/bin/bash
TYPE=$(kubectl get svc my-nginx-clusterip -o jsonpath='{.spec.type}' 2>/dev/null)
test "$TYPE" = "ClusterIP"

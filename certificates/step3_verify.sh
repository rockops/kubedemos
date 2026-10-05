#!/bin/bash
[ -f /root/public-sa.kubeconfig ] && \
kubectl get pods --kubeconfig=/root/public-sa.kubeconfig -n public >/dev/null 2>&1 && \
! kubectl get pods --kubeconfig=/root/public-sa.kubeconfig -n private >/dev/null 2>&1

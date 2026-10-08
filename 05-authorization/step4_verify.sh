#!/bin/bash
[ -f /root/public-sa.kubeconfig ] && \
! kubectl get rolebinding public-reader-binding -n public >/dev/null 2>&1 && \
! kubectl get pods --kubeconfig=/root/public-sa.kubeconfig -n public >/dev/null 2>&1

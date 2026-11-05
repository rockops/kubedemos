#!/bin/bash
[ -f /tmp/public-sa.kubeconfig ] && \
! kubectl get rolebinding public-reader-binding -n public >/dev/null 2>&1 && \
! kubectl get pods --kubeconfig=/tmp/public-sa.kubeconfig -n public >/dev/null 2>&1

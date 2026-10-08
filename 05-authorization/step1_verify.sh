#!/bin/bash
kubectl get ns public >/dev/null 2>&1 && \
kubectl get ns private >/dev/null 2>&1 && \
kubectl get sa public-sa -n public >/dev/null 2>&1 && \
kubectl get role public-reader -n public >/dev/null 2>&1 && \
kubectl get rolebinding public-reader-binding -n public >/dev/null 2>&1

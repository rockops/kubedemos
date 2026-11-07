#!/bin/bash
kubectl get nodes >/dev/null 2>&1 && \
kubectl get ns dev >/dev/null 2>&1 && \
kubectl get ns prod >/dev/null 2>&1

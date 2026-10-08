#!/bin/bash
[ -f /root/public-sa.key ] && \
[ -f /root/public-sa.crt ] && \
kubectl get csr public-sa-csr -o jsonpath='{.status.certificate}' >/dev/null 2>&1 && \
openssl verify -CAfile /etc/kubernetes/pki/ca.crt /root/public-sa.crt >/dev/null 2>&1

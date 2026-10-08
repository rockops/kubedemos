#!/bin/bash
set -e

# Ensure namespace exists
kubectl create ns webhook-system --dry-run=client -o yaml | kubectl apply -f -

# Temporary directory for cert generation
CERT_DIR=$(mktemp -d)
trap 'rm -rf "$CERT_DIR"' EXIT

# Generate self-signed CA
openssl req -nodes -new -x509 -days 365 \
  -keyout "${CERT_DIR}/ca.key" \
  -out "${CERT_DIR}/ca.crt" \
  -subj "/CN=Admission Webhook CA" >/dev/null 2>&1

# Generate server private key and CSR
openssl req -nodes -newkey rsa:2048 \
  -keyout "${CERT_DIR}/webhook.key" \
  -out "${CERT_DIR}/webhook.csr" \
  -subj "/CN=admission-webhook.webhook-system.svc" >/dev/null 2>&1

# Extensions file with Subject Alternative Names (SAN)
cat <<EOF > "${CERT_DIR}/webhook.ext"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = admission-webhook
DNS.2 = admission-webhook.webhook-system
DNS.3 = admission-webhook.webhook-system.svc
DNS.4 = admission-webhook.webhook-system.svc.cluster.local
DNS.5 = sidecar-injector
DNS.6 = sidecar-injector.webhook-system
DNS.7 = sidecar-injector.webhook-system.svc
DNS.8 = sidecar-injector.webhook-system.svc.cluster.local
EOF

# Sign the server certificate with CA
openssl x509 -req -days 365 \
  -in "${CERT_DIR}/webhook.csr" \
  -CA "${CERT_DIR}/ca.crt" \
  -CAkey "${CERT_DIR}/ca.key" \
  -CAcreateserial \
  -out "${CERT_DIR}/webhook.crt" \
  -extfile "${CERT_DIR}/webhook.ext" >/dev/null 2>&1

# Create or update Secret in webhook-system namespace
kubectl create secret tls webhook-tls \
  --cert="${CERT_DIR}/webhook.crt" \
  --key="${CERT_DIR}/webhook.key" \
  -n webhook-system \
  --dry-run=client -o yaml | kubectl apply -f -

# Populate caBundle in webhook configurations
CA_BUNDLE=$(base64 -w0 < "${CERT_DIR}/ca.crt" 2>/dev/null || base64 < "${CERT_DIR}/ca.crt" | tr -d '\r\n')

for TARGET in /root/manifests/mutating-webhook.yaml /root/manifests/validating-webhook.yaml /root/manifests/webhook-config.yaml; do
  if [ -f "$TARGET" ]; then
    sed -i "s|__CA_BUNDLE__|$CA_BUNDLE|g" "$TARGET"
  fi
done

touch /tmp/webhook-tls-ready
echo "TLS setup completed: webhook-tls Secret created in webhook-system namespace."

#!/bin/bash
set -eu

START=$(date +%s)

cd /rockdemo
mkdir -p kind
cd kind

echo 'Waiting for Docker to be ready...'
until docker info >/dev/null 2>&1; do sleep 1; done
echo 'Docker is ready.'

ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"

echo "=================================================="
echo "         Install tools...              "
echo "=================================================="
echo ""
test -f kubectl || wget "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
chmod +x kubectl
cp kubectl /usr/local/bin/kubectl

test -f helm || {
    wget https://get.helm.sh/helm-v4.3.0-linux-${ARCH}.tar.gz
    tar -zxf helm-v4.3.0-linux-${ARCH}.tar.gz
    mv linux-${ARCH}/helm .
    chmod +x helm
}

cp helm /usr/local/bin/helm


echo "=================================================="
echo "         Initializing kind Cluster...             "
echo "=================================================="
echo ""

test -f kind-linux-${ARCH} || wget https://github.com/kubernetes-sigs/kind/releases/download/v0.33.0/kind-linux-${ARCH}
chmod +x kind-linux-${ARCH}
cp kind-linux-${ARCH} /usr/local/bin/kind

mkdir -p ~/.kube
if kind get clusters 2>/dev/null | grep -qw rockdemo; then
    kind delete cluster --name rockdemo
fi

kind create cluster --name rockdemo

END=$(date +%s)

kubectl cluster-info
echo ""
echo "=================================================="
echo "  kind Cluster is Ready in $((END-START)) seconds!                  "
echo "=================================================="
echo "Click 'START' to test your new kind cluster!"
echo ""

sleep 1

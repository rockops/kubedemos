#!/bin/bash
set -eu

START=$(date +%s)

cd /rockdemo
mkdir -p kind
cd kind

echo 'Waiting for Docker to be ready...'
until docker info >/dev/null 2>&1; do sleep 1; done
echo 'Docker is ready.'

echo "=================================================="
echo "         Install tools...              "
echo "=================================================="
echo ""
test -f kubectl || wget "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
cp kubectl /usr/local/bin/kubectl

test -f helm || {
    wget https://get.helm.sh/helm-v4.3.0-linux-amd64.tar.gz
    tar -zxf helm-v4.3.0-linux-amd64.tar.gz
    mv linux-amd64/helm .
    chmod +x helm
}

cp helm /usr/local/bin/helm


echo "=================================================="
echo "         Initializing kind Cluster...             "
echo "=================================================="
echo ""

test -f kind-linux-amd64 || wget https://github.com/kubernetes-sigs/kind/releases/download/v0.33.0/kind-linux-amd64
chmod +x kind-linux-amd64
cp kind-linux-amd64 /usr/local/bin/kind

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

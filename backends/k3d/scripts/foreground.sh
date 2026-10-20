#!/bin/bash
set -eu

START=$(date +%s)

cd /rockdemo
mkdir -p k3d
cd k3d

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
echo "         Initializing k3d Cluster...              "
echo "=================================================="
echo ""

test -f k3d-linux-amd64 || wget https://github.com/k3d-io/k3d/releases/download/v5.9.0/k3d-linux-amd64
chmod +x k3d-linux-amd64
cp k3d-linux-amd64 /usr/local/bin/k3d

mkdir -p ~/.kube
if k3d cluster list | grep -qw rockdemo; then
    k3d cluster delete rockdemo
fi

k3d cluster create rockdemo

END=$(date +%s)

kubectl cluster-info
echo ""
echo "=================================================="
echo "  k3d Cluster is Ready in $((END-START)) seconds!                  "
echo "=================================================="
echo "Click 'START' to test your new k3d cluster!"
echo ""

sleep 1
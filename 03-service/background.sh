#!/bin/bash

# Wait for Kubernetes cluster to be responsive
while ! kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

# Initialize dedicated virtual interface for LoadBalancer IPs
ip link add kube-lb type dummy 2>/dev/null || true
ip link set kube-lb up 2>/dev/null || true

# Run Cloud Controller simulator in background
(
  IP_COUNTER=100
  while true; do
    DEV=$(ip -o route show default 2>/dev/null | awk '{print $5}')
    DEV=${DEV:-eth0}

    for svc in $(kubectl get svc -A -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}' 2>/dev/null); do
      if [ -n "$svc" ]; then
        NS="${svc%/*}"
        NAME="${svc#*/}"
        CURRENT_IP=$(kubectl get svc -n "$NS" "$NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -z "$CURRENT_IP" ]; then
          LB_IP="192.168.1.${IP_COUNTER}"

          # Bind the external IP to interfaces for local and network reachability
          ip addr add "${LB_IP}/32" dev lo 2>/dev/null || true
          ip addr add "${LB_IP}/32" dev "$DEV" 2>/dev/null || true
          ip addr add "${LB_IP}/32" dev kube-lb 2>/dev/null || true

          kubectl patch svc -n "$NS" "$NAME" --subresource=status --type=merge \
            -p "{\"status\":{\"loadBalancer\":{\"ingress\":[{\"ip\":\"$LB_IP\"}]}}}" 2>/dev/null || true

          IP_COUNTER=$((IP_COUNTER + 1))
        fi
      fi
    done
    sleep 2
  done
) >/var/log/cloud-controller.log 2>&1 &

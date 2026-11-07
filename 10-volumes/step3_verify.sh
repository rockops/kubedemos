#!/bin/bash
test -f /mnt/data/node-file.txt || \
  (kubectl get events 2>/dev/null | grep -q "pod-static-storage")


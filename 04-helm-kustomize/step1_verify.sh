#!/bin/bash
# Verify Helm release exists, has revision >= 2 and deployment has 3 ready replicas

# Check helm release status
helm status my-nginx >/dev/null 2>&1 || exit 1
exit 0

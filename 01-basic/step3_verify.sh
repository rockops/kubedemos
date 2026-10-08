#!/bin/bash
! kubectl get pod demo -n dev >/dev/null 2>&1 && kubectl get pod demo -n prod >/dev/null 2>&1

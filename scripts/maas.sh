#!/bin/bash

set -eo pipefail

CWD="$(pwd)"
cd build

# fetch repositories
stat maas >/dev/null || git clone https://review.opendev.org/airship/maas
stat openstack-helm >/dev/null || git clone https://review.opendev.org/openstack/openstack-helm

# patchset refs/changes/17/939717/35
cd maas
git config --global --add safe.directory "${PWD}"
git fetch origin refs/changes/17/939717/35
git reset --hard FETCH_HEAD

# prereq
kubectl label node --all ucp-control-plane=enabled
cat <<eof | kubectl apply -f -
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  selfSigned: {}
eof

# deploy maas
kubectl create ns ucp --dry-run=client -o=yaml | kubectl apply -f -
bash -c "./tools/maas/009-setup-apparmor.sh" || true
bash -c "./tools/maas/120-postgresql.sh"
bash -c "./tools/maas/121-maas.sh"

cd "${CWD}"

#!/bin/bash

set -eo pipefail

CONFIG_SSH=false
DEPLOY_MAAS=false

config_ssh() {
  mkdir -p "${HOME}/.ssh"
  stat "${SSH_KEY_PATH}" >/dev/null && return
  rm -f "${HOME}/.ssh/config"
  envsubst <config/config.ssh >"${HOME}/.ssh/config"
  ssh-keygen -t ed25519 -C "${SSH_USERNAME}" -N "" -f "${SSH_KEY_PATH}"
  cat "${SSH_KEY_PATH}".pub >>~/.ssh/authorized_keys
}

while [[ $# -gt 0 ]]; do
  case ${1} in
  --configure-ssh)
    CONFIG_SSH=true
    shift
    ;;
  *)
    echo "Unknown argument: ${1}"
    exit 1
    ;;
  esac
done

# configure ssh
[[ ${CONFIG_SSH} == true ]] && config_ssh

if ! k0s status >/dev/null 2>&1; then
  # cilium workaround in container
  sudo mount --make-rshared /

  # patch containerd
  sudo mkdir -p /etc/k0s
  containerd config default | sudo tee /etc/k0s/containerd.toml >/dev/null
  sudo bash -c 'patch /etc/k0s/containerd.toml <config/containerd.k0s.patch'

  # add manifests
  sudo mkdir -p /var/lib/k0s/manifests/{crd,gateway}
  kustomize build deployment/crd | sudo tee /var/lib/k0s/manifests/crd/crds.yaml >/dev/null
  kustomize build deployment/gateway | sudo tee /var/lib/k0s/manifests/gateway/gateways.yaml >/dev/null

  # create cluster
  # fixme: stuck in 'Connect to hosts' if no SSH_AUTH_SOCK=""
  envsubst < config/cluster.yaml >build/cluster.yaml
  SSH_AUTH_SOCK="" k0sctl apply --config build/cluster.yaml
  SSH_AUTH_SOCK="" k0sctl kubeconfig --config config/cluster.yaml >build/kubeconfig.yaml
fi

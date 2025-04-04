# syntax=docker/dockerfile:1.7.0
FROM ubuntu:20.04

ARG HELM_VERSION="3.17.2"
ARG K0S_VERSION="1.32.3+k0s.0"
ARG K0SCTL_VERSION="0.22.0"
ARG KUBERNETES_VERSION="1.32.3"
ARG KUSTOMIZE_VERSION="5.6.0"

ENV DEBIAN_FRONTEND=noninteractive

COPY config/journal-to-tty.service /lib/systemd/system/journal-to-tty.service

#checkov:skip=CKV2_DOCKER_1
RUN <<EOF
ARCH="$(dpkg --print-architecture)"
apt-get update -yq
apt-get install -y --no-install-recommends \
  apparmor \
  bash \
  ca-certificates \
  conntrack \
  containerd \
  cron \
  curl \
  dbus \
  ethtool \
  file \
  fuse-overlayfs \
  gettext \
  git \
  gnupg2 \
  iproute2 \
  iptables \
  jq \
  kmod \
  libseccomp2 \
  mount \
  nfs-common \
  nftables \
  open-iscsi \
  openssl \
  patch \
  pigz \
  procps \
  software-properties-common \
  ssh \
  sudo \
  systemd \
  udev \
  util-linux \
  vim \
  zsh
systemctl enable journal-to-tty.service
useradd -m devcontainer
echo "devcontainer ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/devcontainer
chmod 0440 /etc/sudoers.d/devcontainer
curl -fsSLo /tmp/k0s "https://github.com/k0sproject/k0s/releases/download/v${K0S_VERSION}/k0s-v${K0S_VERSION}-${ARCH}"
curl -fsSLo /tmp/k0sctl "https://github.com/k0sproject/k0sctl/releases/download/v${K0SCTL_VERSION}/k0sctl-linux-${ARCH}"
curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/v${KUBERNETES_VERSION}/bin/linux/${ARCH}/kubectl"
curl -fsSLo /tmp/kustomize.tgz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz"
curl -fsSLo /tmp/helm.tgz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz"
tar -xzf /tmp/helm.tgz -C /tmp/
tar -xzf /tmp/kustomize.tgz -C /usr/local/bin
install -m 755 "/tmp/linux-${ARCH}/helm" /usr/local/bin/helm
install -m 755 /tmp/k0s /usr/local/bin/k0s
install -m 755 /tmp/k0sctl /usr/local/bin/k0sctl
install -m 755 /tmp/kubectl /usr/local/bin/kubectl
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

CMD [ "/sbin/init" ]
USER devcontainer
HEALTHCHECK NONE

FROM frolvlad/alpine-glibc:latest

# Allows us to compile for different architectures
ARG QEMU_ARCH
COPY qemu-${QEMU_ARCH}-static /usr/bin

ARG K8S_VERSION
ARG K8S_ARCH

# Add kubelet dependencies
RUN apk add --no-cache coreutils findutils

# Add kube-proxy dependencies (iptables stuff also used by kubelet)
RUN apk add --no-cache conntrack-tools iptables ip6tables

# Add the kubernetes server binaries
RUN set -euxo pipefail && \
    apk add --no-cache curl && \
    curl -sSL --fail "https://dl.k8s.io/${K8S_VERSION}/kubernetes-server-linux-${K8S_ARCH}.tar.gz" | tar xz -C / && \
    cd /kubernetes/server/bin && \
    find . -type f -executable -print0 | xargs -0 -n1 -I{} mv {} /usr/local/bin/{} && \
    cd / && \
    rm -rf /kubernetes && \
    apk del --no-cache curl

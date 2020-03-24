FROM frolvlad/alpine-glibc:latest

# Allows us to compile for different architectures
ARG QEMU_ARCH
COPY qemu-${QEMU_ARCH}-static /usr/bin

ARG K8S_VERSION
ARG K8S_ARCH

RUN set -euxo pipefail && \
    apk add --no-cache curl && \
    curl -sSL --fail "https://dl.k8s.io/${K8S_VERSION}/kubernetes-server-linux-${K8S_ARCH}.tar.gz" | tar xz -C / && \
    curl -sSL --fail "https://github.com/upx/upx/releases/download/v3.96/upx-3.96-${K8S_ARCH}_linux.tar.xz" | tar xJ --strip-components=1 -C /bin/ upx-3.96-${K8S_ARCH}_linux/upx && \
    cd /kubernetes/server/bin && \
    find . -type f -executable -print0 | xargs -0 -n1 -I{} upx -9 -q -o /usr/local/bin/{} {} && \
    cd / && \
    rm -rf /kubernetes /bin/upx && \
    apk del --no-cache curl

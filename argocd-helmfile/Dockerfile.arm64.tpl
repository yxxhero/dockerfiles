FROM argoproj/argocd:v{{ .argocd_version }}

LABEL version="{{ .argocd_version }}-{{ .helmfile_version }}"
LABEL maintainer="shinya@chatwork.com"

# Switch to root for the ability to perform install
USER root

ARG HELMFILE_VERSION=v{{ .helmfile_version }}
ARG HELM_VERSION=v{{ .helm_version }}
ARG HELM_LOCATION="https://get.helm.sh"
ARG HELM_FILENAME="helm-${HELM_VERSION}-linux-arm64.tar.gz"
ARG KUBECTL_VERSION=1.21.11
ARG SOPS_VERSION=3.7.2
ARG HELM_DIFF_VERSION=3.4.2
ARG HELM_SECRETS_VERSION=3.12.0

# Install tools needed for your repo-server to retrieve & decrypt secrets, render manifests
# (e.g. curl, awscli, gpg, sops)

# helm
# helmfile, sops, kubectl
RUN apt-get update && \
    apt-get install -y curl gpg apt-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # kubectl
    curl -o /usr/local/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/arm64/kubectl && \
    # helm
    curl -OL ${HELM_LOCATION}/${HELM_FILENAME} && \
    echo Extracting ${HELM_FILENAME}... && \
    tar zxvf ${HELM_FILENAME} && mv ./linux-arm64/helm /usr/local/bin/ && \
    rm ${HELM_FILENAME} && rm -r ./linux-arm64 && \
    # helmfile
    curl -o /usr/local/bin/helmfile -L https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_arm64 && \
    # sops
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.arm64 && \
    chmod +x /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helmfile && \
    chmod +x /usr/local/bin/sops

# Switch back to non-root user
USER argocd

RUN helm plugin install https://github.com/databus23/helm-diff --version v${HELM_DIFF_VERSION} && \
    helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS_VERSION} && \
    helm plugin install https://github.com/hypnoglow/helm-s3.git && \
    helm plugin install https://github.com/mumoshu/helm-x  && \
    helm plugin install https://github.com/aslafy-z/helm-git.git


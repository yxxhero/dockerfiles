FROM alpine:3.16 as downloads
WORKDIR /downloads

ARG TARGETPLATFORM

ARG EKSCTL_VERSION=0.116.0
ARG KUBECTL_VERSION=1.23.12
LABEL version="${EKSCTL_VERSION}"

RUN wget -O - https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}/eksctl_Linux_${TARGETPLATFORM#*/}.tar.gz | tar zxvf -

RUN wget https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETPLATFORM#*/}/kubectl

FROM chatwork/aws:latest

ARG EKSCTL_VERSION=0.116.0
LABEL version="${EKSCTL_VERSION}"
LABEL maintainer="sakamoto@chatwork.com"

COPY --from=downloads  /downloads/eksctl /usr/local/bin
COPY --from=downloads  /downloads/kubectl /usr/local/bin

RUN chmod +x /usr/local/bin/eksctl
RUN chmod +x /usr/local/bin/kubectl

ENTRYPOINT ["/usr/local/bin/eksctl"]
CMD ["help"]

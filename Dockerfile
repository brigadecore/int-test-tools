FROM lachlanevenson/k8s-kubectl:v1.20.4 as kubectl

FROM golang:1.17.0-alpine3.13 as golang

FROM docker:20.10.9-dind

ARG KIND_VERSION=v0.11.1
ARG BUILDX_VERSION=v0.6.3
ARG HELM_VERSION=v3.7.0

COPY --from=kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=golang /usr/local/go /usr/local/go

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV HELM_EXPERIMENTAL_OCI=1

RUN apk add \
    bash \
    curl \
    git \
    make \
  && curl -L -o /usr/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-amd64 \
  && chmod 755 /usr/bin/kind \
  && mkdir -p /usr/libexec/docker/cli-plugins \
  && curl -L -o /usr/libexec/docker/cli-plugins/docker-buildx \
    https://github.com/docker/buildx/releases/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64 \
  && chmod 755 /usr/libexec/docker/cli-plugins/docker-buildx \
  && docker buildx install \
  && cd /usr/local/bin \
  && curl https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz | tar xvz linux-amd64/helm --strip-components=1

WORKDIR $GOPATH

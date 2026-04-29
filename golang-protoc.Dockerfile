# first stage to build the protobuf files and go project
FROM golang:1.23-alpine AS builder
ARG PLATFORM
ARG PROTOC_VERSION="28.3"

RUN apk add --no-cache \
    wget \
    unzip

# -----------------
# set up container for building protobuf

# By default Intel chipset (x86_64) is assumed but if the host device is an Apple
# silicon (arm) chipset based then a relevant (aarch_64) release file is used.

WORKDIR /workdir

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.35.1 && \
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1

RUN export GOPATH=$(go env GOPATH) && \ 
  echo "GOPATH is: $GOPATH"

RUN set -ex; \
    export ZIP=x86_64 && \
    if [ ${PLATFORM} = "arm64" ]; then export ZIP=aarch_64; fi && \
    if [ ${PLATFORM} = "amd64" ]; then export ZIP=x86_64; fi && \
    wget --quiet https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-${ZIP}.zip && \
    unzip -o protoc-${PROTOC_VERSION}-linux-${ZIP}.zip -d /usr/local bin/protoc && \
    unzip -o protoc-${PROTOC_VERSION}-linux-${ZIP}.zip -d /usr/local 'include/*' && \
    rm protoc-${PROTOC_VERSION}-linux-${ZIP}.zip

RUN protoc --version

RUN which protoc-gen-go && \
    which protoc-gen-go-grpc

FROM alpine:latest
COPY --from=builder /usr/local/bin/protoc /usr/local/bin/
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /go/bin/protoc-gen-go /usr/local/bin/
COPY --from=builder /go/bin/protoc-gen-go-grpc /usr/local/bin/

RUN protoc --version

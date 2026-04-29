#!/bin/bash -eu

echo "The following script will build the talksik/golang-protoc image and push to docker both architectures: amd64 & arm64"

read -p "Press 'y' to confirm: " -n 1 confirm

DOCKER_HUB_REPOSITORY=talksik/golang-protoc:latest

if [[ "$confirm" == "y" ]]; then
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg PLATFORM=$(echo $BUILDPLATFORM | cut -d '/' -f 2) \
    --push \
    -f ./golang-protoc.Dockerfile \
    -t $DOCKER_HUB_REPOSITORY . \
    --progress=plain 
else
  echo "Confirmation canceled."
fi


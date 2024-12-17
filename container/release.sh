#!/bin/bash

set -e

PGO_VERSION=$(cat ../.PGO_VERSION)

printf '%s\n' "Building pgoc version ${PGO_VERSION}"

# docker buildx create \
#   --name container \
#   --driver=docker-container

# https://github.com/docker/buildx/issues/1335
docker run --privileged multiarch/qemu-user-static:latest --reset -p yes --credential yes

# docker buildx version
# docker buildx stop
# docker buildx rm container
# docker buildx create --name container --use --bootstrap
# docker buildx version

    # --progress=plain \
    # --no-cache \
docker buildx build \
    -t mawinkler/pgoc:${PGO_VERSION} \
    -t mawinkler/pgoc:latest \
    --build-arg uid=$(id -u) \
    --build-arg gid=$(id -g) \
    --build-arg version=${PGO_VERSION} \
    --platform linux/amd64,linux/arm64/v8 \
    --no-cache \
    --push \
    .

cd ..
git tag ${PGO_VERSION}
git push --tags

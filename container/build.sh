#!/bin/bash
PGO_VERSION=$(cat .PGO_VERSION)

printf '%s\n' "Building mcs version ${PGO_VERSION}"

# docker run --privileged multiarch/qemu-user-static:latest --reset -p yes --credential yes

    # --progress=plain \
    # --no-cache \
docker buildx build \
    -t mawinkler/pgoc:${PGO_VERSION} \
    -t mawinkler/pgoc:latest \
    --build-arg uid=$(id -u) \
    --build-arg gid=$(id -g) \
    --build-arg version=${PGO_VERSION} \
    --platform linux/amd64,linux/arm64/v8 \
    --push \
    .

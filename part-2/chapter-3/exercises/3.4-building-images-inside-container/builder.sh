#!/bin/bash
set -e

D="/tmp/docker_builder_$$"
mkdir -p "$D" && cd "$D"

[ $# -ne 2 ] && { echo "Usage: $0 <github_repo> <docker_hub_repo>"; exit 1; }

# Login to Docker Hub using environment variables
if [ -n "$DOCKER_USER" ] && [ -n "$DOCKER_PWD" ]; then
    echo "$DOCKER_PWD" | docker login -u "$DOCKER_USER" --password-stdin
fi

git clone "https://github.com/$1.git" . || exit 1
[ -f Dockerfile ] || exit 1

docker build -t "$2:latest" .
docker push "$2:latest"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
docker tag "$2:latest" "$2:$TIMESTAMP"
docker push "$2:$TIMESTAMP"

rm -rf "$D"
echo "Success: $2:latest pushed to Docker Hub"

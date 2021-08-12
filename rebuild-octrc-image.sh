#!/usr/bin/env bash

set -euo pipefail

git submodule update --init --recursive
git submodule update

docker rmi octrc || true
# ./oss-review-toolkit-ort/ort.sh rm-docker-images
docker build . --tag octrc

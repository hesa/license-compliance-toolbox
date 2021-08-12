#!/usr/bin/env bash

set -euo pipefail

git submodule update --init --recursive
git submodule update

# docker rmi -f octrc || true
# ../oss-review-toolkit-ort/ort.sh rm-docker-images
docker build .. -f ./Dockerfile --tag octrc

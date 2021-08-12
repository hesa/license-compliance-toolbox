#!/usr/bin/env bash

set -euo pipefail

docker rmi octrc || true
# ./oss-review-toolkit-ort/ort.sh rm-docker-images
docker build . --tag octrc

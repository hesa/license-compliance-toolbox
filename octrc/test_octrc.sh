#!/usr/bin/env bash
set -euo pipefail

./rebuild-octrc-image.sh
# rm -r _out || true
mkdir -p _out
docker run -it --rm \
    -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -u 1000:1000 \
    -v /home/mhuber/.ort/dockerHome:/home/mhuber \
    -v "$(readlink -f vinland-technology-compliance-tool-collection):/inputs:ro" \
    -v "$(readlink -f _out):/outputs"\
    octrc

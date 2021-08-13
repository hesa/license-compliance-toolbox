#!/usr/bin/env bash
set -euo pipefail

tag="octrc:latest"

prepareDotOrt() {
    declare -a types=("analyzer" "downloader" "scanner" "config" )
    for type in ${types[@]}; do
        mkdir -p "$HOME/.ort/dockerHome/.ort/$type"
        if [[ ! -e "$HOME/.ort/$type" ]]; then
            ln -s "$HOME/.ort/dockerHome/.ort/$type" "$HOME/.ort/$type"
        fi
    done
    cat <<EOF > "$HOME/.ort/dockerHome/.ort/config/ort.conf"
ort {
  analyzer {
    allowDynamicVersions = true
  }
  scanner {
    storages {
      clearlyDefined {
        serverUrl = "https://api.clearlydefined.io"
      }
      fileBasedStorage {
        backend {
          localFileStorage {
            directory = "${HOME}/.ort/scanner/scan-results"
            compression = false
          }
        }
      }
    }

    storageReaders: [
      "fileBasedStorage"
    ]

    storageWriters: [
      "fileBasedStorage"
    ]
  }
}
EOF
}

buildImage() {
    export DOCKER_BUILDKIT=1
    if [[ "$(docker images -q ort:latest 2> /dev/null)" == "" ]]; then
        ORT=$(mktemp -d)
        trap "rm -rf $ORT" EXIT
        git clone https://github.com/oss-review-toolkit/ort $ORT

        docker build \
            --network=host \
            -t ort:latest $ORT
    else
        >&2 echo "docker base image already build, at $(docker inspect -f '{{ .Created }}' ort:latest)"
    fi


    (
        cd "$( dirname "${BASH_SOURCE[0]}" )"

        git submodule update --init --recursive
        git submodule update

        docker build .. -f ./octrc.Dockerfile --tag octrc
    )
}

run() {
    local input="$(readlink -f "$1")"; shift
    local output
    if [[ $# -eq 0 ]]; then
        output="${input%_octrc}_octrc"
    else
        output="$(readlink -f "$1")"; shift
    fi
    mkdir -p "$output"

    local dockerArgs=("-i" "--rm")
    dockerArgs+=("-v" "/etc/group:/etc/group:ro" "-v" "/etc/passwd:/etc/passwd:ro" "-u" "$(id -u $USER):$(id -g $USER)")
    dockerArgs+=("-v" "$HOME/.ort/dockerHome:$HOME")
    mkdir -p ".dependency-check/data/cache"
    dockerArgs+=("-v" "$HOME/.dependency-check/data/:/opt/dependency-check/data/")
    dockerArgs+=("-v" "$input:/inputs:ro")
    dockerArgs+=("-v" "$output:/outputs")
    dockerArgs+=("--net=host")

    (set -x;
     docker run \
         "${dockerArgs[@]}" \
         "$tag";
     >&2 times
     )
}

if [[ "$1" == "--build" ]]; then
    shift
    buildImage
fi

prepareDotOrt

input="$1"; shift
run "$input" $@

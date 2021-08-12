#!/usr/bin/env bash
set -euo pipefail

extract() (
    workdir="$1"; shift

    set -x
    extractcode \
        --verbose
        "$workdir"
)

workdir="$1"; shift

extract "$workdir"

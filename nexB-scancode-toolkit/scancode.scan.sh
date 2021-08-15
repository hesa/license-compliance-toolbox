#!/usr/bin/env bash
set -euo pipefail

getNumberOfThreads() {
    cores=$(nproc)
    if [[ "$cores" -ge 3 ]]; then
        echo $((cores - 2))
    else
        echo 1
    fi
}

getOutFolder() {
    local workdir="$(readlink -f "$1")"
    local out="${workdir%_scancode}_scancode"
    mkdir -p "$out"
    echo "$out"
}

scan() (
    workdir="$1"; shift
    outdir="$1"; shift

    set -x
    scancode \
        -n "$(getNumberOfThreads)" \
        --license --copyright --package --info \
        "$workdir" \
        --license-text --license-text-diagnostics \
        --json "$outdir/scancode.json" \
        --json-pp "$outdir/scancode.pp.json" \
        `#--csv "$outdir/scancode.csv"` \
        --spdx-rdf "$outdir/scancode.rdf.xml" \
        --spdx-tv "$outdir/scancode.spdx" \
        --html-app "$outdir/scancode.html" \
        --strip-root
)


workdir="$1"; shift
if [[ $# -eq 0 ]]; then
    outdir="$(getOutFolder "$workdir")"
else
    outdir="$1"; shift
fi

scan "$workdir" "$outdir"

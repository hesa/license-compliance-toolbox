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
    outdir="$(getOutFolder "$workdir")"
    bn="$(basename "$workdir")"

    set -x
    scancode \
        -n "$(getNumberOfThreads)" \
        --license --copyright --package --info \
        /workdir \
        --license-text --license-text-diagnostics \
        --json "$outdir/${bn}.scancode.json" \
        --json-pp "$outdir/${bn}.scancode.pp.json" \
        --csv "$outdir/${bn}.scancode.csv" \
        --spdx-rdf "$outdir/${bn}.scancode.rdf.xml" \
        --spdx-tv "$outdir/${bn}.scancode.spdx" \
        --html-app "$outdir/${bn}.scancode.html" \
        --strip-root
)


workdir="$1"; shift
if [[ $# -eq 0 ]]; then
    outdir="$(getOutFolder "$workdir")"
else
    outdir="$1"; shift
fi

scan "$workdir" "$outdir"

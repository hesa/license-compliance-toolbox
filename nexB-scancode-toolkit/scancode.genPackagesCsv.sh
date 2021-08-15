#!/usr/bin/env bash
set -euo pipefail

cat "$1" |
    jq ".files[].packages"|
    jq 'reduce inputs as $i (.; . += $i)' |
    jq '. | map({purl: .purl, dependency: .dependencies[]})' |
    jq -r 'map([.purl, .dependency.purl, .dependency.requirement, .dependency.scope, .dependency.is_runtime])[] | @csv'

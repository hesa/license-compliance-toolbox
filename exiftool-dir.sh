#!/usr/bin/env bash
set -euo pipefail

main() {
    local input="$1"; shift

    cd "$input"

    find . -type f -print0 |
        while IFS= read -r -d "" file; do
            exiftool -j "$file" || true
        done | jq '.[]' | jq -s 'map( { (.SourceFile|tostring): . } ) | add'
}

output=$(main "$1") && echo "$output" > "${2:-/dev/stdout}"
